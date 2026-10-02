#!/bin/bash
set -euo pipefail
export LC_ALL=C
SCRIPT_DIR=$(dirname -- "${BASH_SOURCE[0]}")
notify() {
    bash "$SCRIPT_DIR/notify-replace.sh" bluetooth --app-name='Waybar Bluetooth' \
        --expire-time=1500 'Bluetooth' "$1" >/dev/null 2>&1 || true
}
if ! status=$(timeout 3 bluetoothctl show 2>/dev/null); then
    notify 'Controller unavailable'
    exit 0
fi
if [[ "$status" == *'Powered: yes'* ]]; then
    power=off; message=Disabled
elif [[ "$status" == *'Powered: no'* ]]; then
    power=on; message=Enabled
else
    notify 'Controller unavailable'
    exit 0
fi
if result=$(timeout 3 bluetoothctl power "$power" 2>&1) &&
   [[ "$result" != *'Failed'* && "$result" != *'not available'* ]] &&
   status=$(timeout 3 bluetoothctl show 2>/dev/null) &&
   { [[ "$power" == on && "$status" == *'Powered: yes'* ]] ||
     [[ "$power" == off && "$status" == *'Powered: no'* ]]; }; then
    notify "$message"
else
    notify 'Could not change controller power'
fi
