#!/bin/bash
set -euo pipefail

key="$1"
shift

id_file="${XDG_RUNTIME_DIR:-/tmp}/waybar-notification-${UID}-${key}.id"
replace_id=0

if [[ -r "$id_file" ]]; then
    read -r replace_id < "$id_file" || replace_id=0
fi

notify-send \
    --print-id \
    --replace-id="$replace_id" \
    "$@" > "$id_file"
