#!/bin/bash
set -euo pipefail

CHOSEN=$(printf "Lock\nReboot\nShutdown\nLog Out" | fuzzel \
    --config "$HOME"/.config/fuzzel/powermenu.ini \
    --dmenu)

case "$CHOSEN" in
	"Lock") hyprlock ;;
	"Reboot") reboot ;;
	"Shutdown") poweroff ;;
	"Log Out") hyprctl dispatch exit ;;
	*) exit 1 ;;
esac
