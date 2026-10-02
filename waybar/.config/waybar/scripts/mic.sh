#!/bin/bash
set -euo pipefail
export LC_ALL=C
SCRIPT_DIR=$(dirname -- "${BASH_SOURCE[0]}")

unavailable() {
    printf '%s\n' '{"text":"󰍬","tooltip":"Microphone: Unavailable","class":"unavailable"}'
}

render() {
    local mute state icon action
    if ! mute=$(timeout 3 pactl get-source-mute @DEFAULT_SOURCE@ 2>/dev/null); then
        unavailable; return
    fi
    case "$mute" in
        'Mute: yes') state=muted; icon='󰍭'; action=unmute ;;
        'Mute: no') state=unmuted; icon='󰍬'; action=mute ;;
        *) unavailable; return ;;
    esac
    # Only fixed status strings enter this JSON, so no encoder subprocess is needed.
    printf '{"text":"%s","class":"%s","tooltip":"Microphone: %s\\n\\nClick for settings\\nRight-click to %s"}\n' \
        "$icon" "$state" "$state" "$action"
}

case ${1:-} in
    toggle)
        if timeout 3 pactl set-source-mute @DEFAULT_SOURCE@ toggle; then
            render
        else
            unavailable
        fi ;;
    --watch)
        # Subscribe before the initial read; events during that read stay queued.
        {
            render
            while IFS= read -r event; do
                case "$event" in
                    *' on source #'*|*' on server #'*) render ;;
                esac
            done
            unavailable
        } < <(pactl subscribe 2>/dev/null) ;;
    '') render ;;
    *) exit 2 ;;
esac
