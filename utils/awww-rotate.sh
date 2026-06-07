#!/usr/bin/env bash
set -euo pipefail

# dependencies: fd, awww, libnotify

DIR="${AWWW_WALLPAPER_DIR:-$HOME/.dotfiles/assets/wallpapers}"
STATE="$HOME/.cache/awww-index"

notify_error() {
    local title="$1"
    local body="$2"
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "$title" "$body" -u critical
    fi
    echo "Error: $title - $body" >&2
}

if ! command -v fd >/dev/null 2>&1; then
    notify_error "awww-rotate" "fd is not installed"
    exit 1
fi

if ! command -v awww >/dev/null 2>&1; then
    notify_error "awww-rotate" "awww is not installed"
    exit 1
fi

if [[ ! -d "$DIR" ]]; then
    notify_error "awww-rotate" "Wallpaper directory not found: $DIR"
    exit 1
fi

mapfile -t imgs < <(fd -d 1 -t f -e jpg -e png -e gif -e webp . "$DIR" | sort -V)

if [[ ${#imgs[@]} -eq 0 ]]; then
    notify_error "awww-rotate" "No images found in $DIR"
    exit 1
fi

DIRECTION="${1:-forward}"
case "$DIRECTION" in
    forward) ;;
    backward|backwards) DIRECTION="backward" ;;
    *)
        echo "Usage: $0 [forward|backward]" >&2
        exit 1
        ;;
esac

total=${#imgs[@]}

# STATE stores the index that will be shown on the next "forward" run.
default_i=0
if [[ "$DIRECTION" == "backward" ]]; then
    # So that the very first "backward" (no state yet) shows the last image.
    default_i=1
fi

i=$(cat "$STATE" 2>/dev/null || echo "$default_i")
if ! [[ "$i" =~ ^[0-9]+$ ]]; then
    i=$default_i
fi

i=$(( i % total ))

case "$DIRECTION" in
    forward)
        target=$i
        next=$(( (i + 1) % total ))
        ;;
    backward)
        # STATE stores the "next forward" index (so current is i-1). Backward should show i-2.
        target=$(( (i + total - 2) % total ))
        next=$(( (i + total - 1) % total ))
        ;;
esac

if ! awww img "${imgs[$target]}" --transition-type wipe --transition-angle 30 --transition-fps 90; then
    notify_error "awww-rotate" "awww failed to set wallpaper"
    exit 1
fi

mkdir -p "$(dirname "$STATE")"
echo "$next" > "$STATE"
