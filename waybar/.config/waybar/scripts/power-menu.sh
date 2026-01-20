#!/bin/bash
set -euo pipefail

# Get network info for tooltip
get_network_info() {
    local iface essid ipaddr signal

    # Check for WiFi first
    iface=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+' || echo "")
    
    if [[ -z "$iface" ]]; then
        echo "Network: Disconnected"
        return
    fi

    ipaddr=$(ip -4 addr show "$iface" 2>/dev/null | grep -oP 'inet \K[\d.]+' || echo "N/A")

    # Check if wireless
    if [[ -d "/sys/class/net/$iface/wireless" ]]; then
        essid=$(iwgetid -r 2>/dev/null || echo "Unknown")
        signal=$(awk 'NR==3 {printf "%.0f", $3 * 100 / 70}' /proc/net/wireless 2>/dev/null || echo "N/A")
        echo "Network: $essid"
        echo "IP: $ipaddr"
        echo "Signal: ${signal}%"
    else
        echo "Interface: $iface"
        echo "IP: $ipaddr"
    fi
}

network_info=$(get_network_info)

# Escape newlines for JSON
network_info_escaped=$(echo "$network_info" | sed ':a;N;$!ba;s/\n/\\n/g')

# Output JSON for waybar
tooltip="Power Menu\\n\\n$network_info_escaped"

printf '{"text": "", "tooltip": "%s"}\n' "$tooltip"
