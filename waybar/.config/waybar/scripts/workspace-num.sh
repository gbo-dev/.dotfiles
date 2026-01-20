#!/bin/bash

workspace=$(hyprctl activeworkspace -j 2>/dev/null | jq -r '.id' 2>/dev/null || echo "1")

echo "{\"text\": \"$(echo $workspace | sed 's/./&\n/g' | tr '\n' ' ' | sed 's/ $//')\"}"
