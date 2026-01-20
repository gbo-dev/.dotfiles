#!/bin/bash

# Custom workspace script that only shows workspaces with windows
# Based on your requirement to hide empty workspace indexes

get_workspaces_with_windows() {
    # Get all workspaces with their window count
    hyprctl workspaces -j | jq -r '.[] | "\(.id):\(.windows)"' | sort -n
}

get_active_workspace() {
    hyprctl activeworkspace -j | jq -r '.id'
}

main() {
    local active_workspace
    active_workspace=$(get_active_workspace)
    
    local workspaces_info
    workspaces_info=$(get_workspaces_with_windows)
    
    local workspace_text=""
    local tooltip_text="Workspaces with windows:\n"
    
    while IFS=':' read -r workspace_id window_count; do
        if [ "$window_count" -gt 0 ]; then
            # Add styling for active workspace
            if [ "$workspace_id" = "$active_workspace" ]; then
                workspace_text="${workspace_text}<span weight='bold' color='#89b4fa'>${workspace_id}</span>\n"
            else
                workspace_text="${workspace_text}${workspace_id}\n"
            fi
            tooltip_text="${tooltip_text}Workspace ${workspace_id}: ${window_count} windows\n"
        fi
    done <<< "$workspaces_info"
    
    # Remove trailing newline
    workspace_text=$(echo "$workspace_text" | sed 's/\\n$//')
    
    # Remove trailing newline from tooltip
    tooltip_text=$(echo "$tooltip_text" | sed 's/\\n$//')
    
    # If no workspaces have windows, show current workspace
    if [ -z "$workspace_text" ]; then
        workspace_text="<span weight='bold' color='#89b4fa'>${active_workspace}</span>"
        tooltip_text="Current workspace: ${active_workspace}\nNo windows in any workspace"
    fi
    
    echo "{\"text\": \"${workspace_text}\", \"tooltip\": \"${tooltip_text}\"}"
}

main