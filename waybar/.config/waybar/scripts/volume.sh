#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: $0 {up|down|toggle-mute}"
    exit 1
}

cmd=${1:-}

case "$cmd" in
    up)
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
        ;;
    down)
        wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-
        ;;
    toggle-mute)
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        ;;
    *)
        usage
        ;;
esac
