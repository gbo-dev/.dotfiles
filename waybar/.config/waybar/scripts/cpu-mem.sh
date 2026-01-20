#!/bin/bash

# Get CPU usage using /proc/stat (reliable method)
PREV_TOTAL=0
PREV_IDLE=0

# Read previous values if they exist
[ -f /tmp/cpu_prev_total ] && PREV_TOTAL=$(cat /tmp/cpu_prev_total)
[ -f /tmp/cpu_prev_idle ] && PREV_IDLE=$(cat /tmp/cpu_prev_idle)

# Get current CPU stats
read -r user nice system idle iowait irq softirq steal guest guest_nice < <(awk '/^cpu /{print $2" "$3" "$4" "$5" "$6" "$7" "$8" "$9" "$10" "$11}' /proc/stat)

# Calculate totals
TOTAL=$((user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice))
IDLE=$((idle + iowait))

# Calculate difference
DIFF_TOTAL=$((TOTAL - PREV_TOTAL))
DIFF_IDLE=$((IDLE - PREV_IDLE))

# Store current values for next iteration
echo "$TOTAL" > /tmp/cpu_prev_total
echo "$IDLE" > /tmp/cpu_prev_idle

# Calculate CPU usage
if [ "$DIFF_TOTAL" -eq 0 ]; then
    cpu_usage=0
else
    cpu_usage=$((100 * (DIFF_TOTAL - DIFF_IDLE) / DIFF_TOTAL))
fi

# Clamp between 0 and 100
[ "$cpu_usage" -lt 0 ] && cpu_usage=0
[ "$cpu_usage" -gt 100 ] && cpu_usage=100

mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')

tooltip="CPU Usage: ${cpu_usage}%\nMemory Usage: ${mem_usage}%\n\nClick to open system monitor"

echo "{\"text\": \"${cpu_usage}%\n${mem_usage}%\", \"tooltip\": \"$tooltip\"}"
