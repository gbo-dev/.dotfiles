#!/bin/bash

HWMON_PATH="/sys/class/hwmon/hwmon2"

temp1=$(cat "$HWMON_PATH/temp1_input" 2>/dev/null)
temp2=$(cat "$HWMON_PATH/temp2_input" 2>/dev/null)
temp3=$(cat "$HWMON_PATH/temp3_input" 2>/dev/null)

if [ -z "$temp1" ]; then
    echo '{"text": "N/A", "tooltip": "GPU sensors not available", "class": "normal"}'
    exit 0
fi

edge=$((temp1 / 1000))
junction=$((temp2 / 1000))
mem=$((temp3 / 1000))

class="normal"

if [ "$edge" -gt 70 ]; then
    class="warning"
fi

tooltip="GPU: ${edge}°C"

if [ -n "$temp2" ] && [ "$temp2" -gt 0 ]; then
    tooltip="${tooltip}\nHotspot: ${junction}°C"
fi

if [ -n "$temp3" ] && [ "$temp3" -gt 0 ]; then
    tooltip="${tooltip}\nMemory: ${mem}°C"
fi

echo "{\"text\": \"${edge}°C\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
