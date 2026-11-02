#!/bin/sh
"$HOME/.local/bin/hokum" dnd --json --watch | jq --unbuffered -c \
  '{alt:(if .dnd then "dnd-none" else "none" end)}'
