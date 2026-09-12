#!/usr/bin/env bash
set -euo pipefail

# Minimal bluetooth toggle for Waybar right-click.
# No device management here; left-click opens bluetui via Waybar config.

SCRIPT_DIR=$(dirname -- "${BASH_SOURCE[0]}")

# Use timeout to prevent hanging when bluetoothctl hasn't connected to daemon yet
if timeout 3 bash -c 'echo "show" | bluetoothctl 2>/dev/null' | grep -q "Powered: yes"; then
    bluetoothctl power off >/dev/null 2>&1 || true
    bash "$SCRIPT_DIR/notify-replace.sh" bluetooth \
        --app-name="Waybar Bluetooth" \
        --icon="bluetooth-disabled" \
        --expire-time=1500 \
        "Bluetooth" "Disabled" >/dev/null 2>&1 || true
else
    bluetoothctl power on >/dev/null 2>&1 || true
    bash "$SCRIPT_DIR/notify-replace.sh" bluetooth \
        --app-name="Waybar Bluetooth" \
        --icon="bluetooth-active" \
        --expire-time=1500 \
        "Bluetooth" "Enabled" >/dev/null 2>&1 || true
fi
