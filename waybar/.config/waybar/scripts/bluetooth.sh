#!/usr/bin/env bash
set -euo pipefail

# Minimal bluetooth toggle for Waybar right-click.
# No device management here; left-click opens bluetui via Waybar config.

# Use timeout to prevent hanging when bluetoothctl hasn't connected to daemon yet
if timeout 3 bash -c 'echo "show" | bluetoothctl 2>/dev/null' | grep -q "Powered: yes"; then
    bluetoothctl power off >/dev/null 2>&1 || true
    notify-send "Bluetooth" "Disabled" -i "bluetooth-disabled" >/dev/null 2>&1 || true
else
    bluetoothctl power on >/dev/null 2>&1 || true
    notify-send "Bluetooth" "Enabled" -i "bluetooth-active" >/dev/null 2>&1 || true
fi
