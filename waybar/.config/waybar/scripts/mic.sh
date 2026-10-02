#!/bin/bash
set -euo pipefail
export LC_ALL=C
SCRIPT_DIR=$(dirname -- "${BASH_SOURCE[0]}")

unavailable() {
    printf '%s\n' '{"text":"󰍬","tooltip":"Microphone: Unavailable","class":"unavailable"}'
}

if ! SOURCE=$(timeout 3 pactl get-default-source 2>/dev/null) || [[ -z "$SOURCE" ]] ||
   ! mute=$(timeout 3 pactl get-source-mute "$SOURCE" 2>/dev/null); then
    unavailable
    exit 0
fi
case "$mute" in
    'Mute: yes') state=muted; icon='󰍭'; action=unmute; value=0 ;;
    'Mute: no') state=unmuted; icon='󰍬'; action=mute; value=1 ;;
    *) unavailable; exit 0 ;;
esac
if [[ ${1:-} == toggle ]]; then
    if timeout 3 pactl set-source-mute "$SOURCE" "$value"; then
        bash "$SCRIPT_DIR/notify-replace.sh" mic --app-name='Waybar microphone' \
            --expire-time=1500 "Microphone: ${action}d" || true
    else
        unavailable
    fi
else
    jq -cn --arg text "$icon" --arg class "$state" \
        --arg tooltip "Microphone: $state"$'\n\n'"Click for settings"$'\n'"Right-click to $action" \
        '{text:$text, tooltip:$tooltip, class:$class}'
fi
