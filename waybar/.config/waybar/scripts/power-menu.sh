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

render() {
    local network_info
    network_info=$(get_network_info)
    # jq escapes SSIDs, interface names, quotes, backslashes, and newlines.
    jq -cn --arg tooltip "Power Menu"$'\n\n'"$network_info" \
        '{text:"", tooltip:$tooltip}'
}

if [[ ${1:-} == --watch ]]; then
    # Netlink notifications report topology/address changes, not packet traffic.
    {
        render
        while IFS= read -r event; do
            render
        done
        printf '%s\n' '{"text":"","tooltip":"Power Menu\n\nNetwork: Unavailable"}'
    } < <(ip monitor link address route 2>/dev/null)
else
    render
fi
