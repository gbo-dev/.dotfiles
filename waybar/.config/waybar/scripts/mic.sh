#!/bin/bash

# Microphone control script for Waybar
# Shows microphone status and toggles mute

# Get default source
SOURCE=$(pactl get-default-source)
SCRIPT_DIR=$(dirname -- "${BASH_SOURCE[0]}")

case "$1" in
    toggle)
        # Toggle mute
        if pactl get-source-mute "$SOURCE" | grep -q "Mute: yes"; then
            pactl set-source-mute "$SOURCE" 0
            bash "$SCRIPT_DIR/notify-replace.sh" mic \
                --app-name="Waybar microphone" \
                --icon="microphone-sensitivity-high-symbolic" \
                --expire-time=1500 \
                "Microphone Unmuted"
        else
            pactl set-source-mute "$SOURCE" 1
            bash "$SCRIPT_DIR/notify-replace.sh" mic \
                --app-name="Waybar microphone" \
                --icon="microphone-sensitivity-muted-symbolic" \
                --expire-time=1500 \
                "Microphone Muted"
        fi
        ;;
    *)
        # Get mute status
        if pactl get-source-mute "$SOURCE" | grep -q "Mute: yes"; then
            icon="󰍭"
            state="muted"
            tooltip="Microphone: Muted\n\nClick for settings\nRight-click to unmute"
        else
            icon="󰍬"
            state="unmuted"
            tooltip="Microphone: Unmuted\n\nClick for settings\nRight-click to mute"
        fi
        
        echo "{\"text\": \"$icon\", \"tooltip\": \"$tooltip\", \"class\": \"$state\"}"
        ;;
esac
