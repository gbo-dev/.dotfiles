#!/usr/bin/env bash
set -euo pipefail

# Minimal bluetooth toggle for Waybar right-click.
# No device management here; left-click opens bluetui via Waybar config.

if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
    bluetoothctl power off >/dev/null
    notify-send "Bluetooth" "Disabled" -i "bluetooth-disabled" >/dev/null 2>&1 || true
else
    bluetoothctl power on >/dev/null
    notify-send "Bluetooth" "Enabled" -i "bluetooth-active" >/dev/null 2>&1 || true
fi
