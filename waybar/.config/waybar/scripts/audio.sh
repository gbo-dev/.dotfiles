#!/bin/bash

# Audio control script for Waybar
# Handles volume control and device switching

case "$1" in
    up)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        ;;
    toggle)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
    switch)
        # Get list of available sinks
        sinks=$(pactl list sinks | grep -E "Sink #|Description:" | paste - -)
        current_sink=$(pactl get-default-sink)
        
        # Extract sink numbers and descriptions
        echo "$sinks" | while read -r line; do
            sink_num=$(echo "$line" | sed 's/Sink #\([0-9]*\).*/\1/')
            desc=$(echo "$line" | sed 's/.*Description: \(.*\)/\1/')
            
            # Skip current sink
            if pactl list sinks | grep -A 20 "Sink #$sink_num" | grep -q "$current_sink"; then
                continue
            fi
            
            # Switch to next available sink
            pactl set-default-sink "$sink_num"
            notify-send "Audio switched to: $desc" -i "audio-card"
            break
        done
        ;;
    mic-toggle)
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        ;;
    *)
        echo "Usage: $0 {up|down|toggle|switch|mic-toggle}"
        exit 1
        ;;
esac