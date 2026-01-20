#!/bin/bash

# Microphone control script for Waybar
# Shows microphone status and toggles mute

# Get default source
SOURCE=$(pactl get-default-source)

case "$1" in
    toggle)
        # Toggle mute
        if pactl get-source-mute "$SOURCE" | grep -q "Mute: yes"; then
            pactl set-source-mute "$SOURCE" 0
            notify-send "Microphone Unmuted" -i "audio-input-microphone"
        else
            pactl set-source-mute "$SOURCE" 1
            notify-send "Microphone Muted" -i "audio-input-microphone-muted"
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