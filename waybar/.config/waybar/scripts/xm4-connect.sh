#!/bin/bash
set -euo pipefail
export LC_ALL=C
SCRIPT_DIR=$(dirname -- "${BASH_SOURCE[0]}")
ADDRESS=80:99:E7:4E:49:64

notify() {
    timeout 4 bash "$SCRIPT_DIR/notify-replace.sh" xm4 --app-name='Waybar Bluetooth' \
        --expire-time="${2:-5000}" 'WH-1000XM4' "$1" >/dev/null 2>&1 || true
}
for dependency in bluetoothctl timeout flock; do
    if ! command -v "$dependency" >/dev/null; then
        notify "Missing command: $dependency"
        exit 0
    fi
done
# Prevent repeated clicks from overlapping a pairing operation.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/waybar-xm4-${UID}.lock"
if ! flock -n 9; then
    notify 'Connection or pairing is already in progress'
    exit 0
fi
scan_pid=''
cleanup() {
    if [[ -n "$scan_pid" ]]; then
        # BlueZ releases this client's discovery session when it exits.
        kill "$scan_pid" 2>/dev/null || true
        wait "$scan_pid" 2>/dev/null || true
    fi
}
trap cleanup EXIT
trap 'exit 0' INT TERM
bt() {
    local seconds=$1 result
    shift
    if ! result=$(timeout "$((seconds + 2))" bluetoothctl --timeout "$seconds" "$@" 2>&1); then
        return 1
    fi
    [[ "$result" != *Failed* && "$result" != *'not available'* && "$result" != *'not found'* ]]
}
connected() {
    local info
    info=$(timeout 4 bluetoothctl info "$ADDRESS" 2>/dev/null) || return 1
    [[ "$info" == *'Connected: yes'* ]]
}
if ! controller=$(timeout 4 bluetoothctl show 2>/dev/null); then
    notify 'Bluetooth controller unavailable'
    exit 0
fi
if [[ "$controller" == *'Powered: no'* ]]; then
    if ! bt 5 power on; then
        notify 'Could not enable Bluetooth'
        exit 0
    fi
elif [[ "$controller" != *'Powered: yes'* ]]; then
    notify 'Bluetooth controller unavailable'
    exit 0
fi
if connected; then
    notify 'Already connected' 1500
    exit 0
fi
notify 'Connecting…'
# Connection status is authoritative, including a connection completed near timeout.
bt 15 connect "$ADDRESS" || true
if connected; then
    notify 'Connected' 1500
    exit 0
fi
notify 'Connection failed. Hold the headset power button for about 7 seconds until “Bluetooth pairing”. Waiting up to 60 seconds…' 15000
# This fallback is deliberate: a timeout does not necessarily mean stale keys.
# Remove only the configured XM4, never another device.
if timeout 4 bluetoothctl info "$ADDRESS" >/dev/null 2>&1; then
    if ! bt 5 remove "$ADDRESS"; then
        notify 'Could not remove the old XM4 pairing'
        exit 0
    fi
fi
# Keep the discovery client alive during pairing; a one-shot scan would stop
# discovery when bluetoothctl exits. Do not stop other clients' scans.
bluetoothctl --timeout 65 scan on >/dev/null 2>&1 9>&- &
scan_pid=$!
deadline=$((SECONDS + 60))
found=false
while (( SECONDS < deadline )); do
    if ! kill -0 "$scan_pid" 2>/dev/null; then
        notify 'Bluetooth scan stopped before finding the XM4'
        exit 0
    fi
    if timeout 3 bluetoothctl info "$ADDRESS" >/dev/null 2>&1; then
        found=true
        break
    fi
    sleep 1
done
if [[ "$found" != true ]]; then
    notify 'XM4 not found. Put it into pairing mode and middle-click again.'
    exit 0
fi
notify 'XM4 found. Pairing…'
if ! bt 30 --agent NoInputNoOutput pair "$ADDRESS"; then
    notify 'Pairing failed. Check that the XM4 says “Bluetooth pairing”, then middle-click again.'
    exit 0
fi
if ! bt 5 trust "$ADDRESS"; then
    notify 'Paired, but could not mark the XM4 as trusted'
    exit 0
fi
if ! connected; then
    bt 15 connect "$ADDRESS" || true
fi
if connected; then
    notify 'Paired and connected' 1500
else
    notify 'Paired, but connection failed. Middle-click to retry.'
fi
