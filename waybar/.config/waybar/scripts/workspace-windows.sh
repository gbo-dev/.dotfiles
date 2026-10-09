#!/bin/bash
set -euo pipefail

mode=${1:-count}
[[ $mode == count || $mode == names ]] || exit 2

# Display names come from installed .desktop files (Name=), keyed by file id and
# StartupWMClass, plus the host of Chromium-style --app=URL launchers. Built once
# at startup; earlier directories win, so user entries override system ones.
desktop_names() {
    local IFS=: dir
    for dir in "${XDG_DATA_HOME:-$HOME/.local/share}" ${XDG_DATA_DIRS:-/usr/local/share:/usr/share}; do
        printf '%s\n' "$dir/applications"
    done | while read -r dir; do
        compgen -G "$dir/*.desktop" >/dev/null || continue
        awk '
            function flush() {
                if (name == "") return
                print tolower(id) "\t" name
                if (wm != "") print tolower(wm) "\t" name
                if (host != "") print "web:" tolower(host) "\t" name
            }
            FNR == 1 { flush(); name = wm = host = ""; sect = ""; id = FILENAME
                       sub(".*/", "", id); sub(/\.desktop$/, "", id) }
            /^\[/ { sect = $0; next }
            sect != "[Desktop Entry]" { next }
            /^Name=/ && name == "" { name = substr($0, 6) }
            /^StartupWMClass=/ { wm = substr($0, 16) }
            /^Exec=/ && match($0, /--app=https?:\/\/[^\/ ]+/) {
                host = substr($0, RSTART, RLENGTH); sub(/.*:\/\//, "", host) }
            END { flush() }
        ' "$dir"/*.desktop
    done | jq -Rsc '[split("\n")[] | select(length > 0) | split("\t")]
        | reduce .[] as $p ({}; if has($p[0]) then . else .[$p[0]] = $p[1] end)'
}

# The event stream supplies the initial state and subsequent changes; no polling.
# Match the active workspace on this bar's output, or focused workspace in a terminal.
if command -v niri >/dev/null && command -v jq >/dev/null; then
    desktop=$(desktop_names 2>/dev/null) || desktop='{}'
    niri msg -j event-stream | jq --unbuffered -cn \
        --arg output "${WAYBAR_OUTPUT_NAME:-}" --arg mode "$mode" \
        --argjson desktop "${desktop:-{\}}" '
        # Overrides for names the .desktop file words too verbosely.
        def overrides:
            {"firefox": "Firefox", "mpv": "mpv", "org.gnome.Nautilus": "Files"};

        # Last resort when no .desktop file matches: Chromium app windows are
        # "chrome-<host>__<path>-<profile>"; reverse-DNS ids use their last segment.
        def fallback:
            if test("^(chrome|chromium|brave|helium)-") then
                sub("^[a-z]+-"; "") | split("__")[0] | ascii_downcase as $host |
                ($desktop["web:" + $host]
                 // ($host | sub("^(www|web|app|m)\\."; "") | split(".")[0]
                          | (.[0:1] | ascii_upcase) + .[1:]))
            elif contains(".") then
                split(".") | last | (.[0:1] | ascii_upcase) + .[1:]
            else . end;

        def app_name:
            (.app_id // "") as $id |
            if $id == "" then "Unknown"
            else overrides[$id] // $desktop[$id | ascii_downcase] // ($id | fallback) end;

        def payload:
            (.workspaces | map(select(
                if $output == "" then .is_focused
                else .is_active and .output == $output end
            )) | first | .id) as $workspace |
            if $workspace == null then
                {text: "–", class: "unavailable", tooltip: "Workspace unavailable"}
            else
                (.windows | map(select(.workspace_id == $workspace)) | sort_by(.id)) as $windows |
                ($windows | length) as $count |
                {text: (if $mode == "names" then ($windows | map(app_name) | join("  ·  "))
                        else ($count | tostring) end),
                 class: (if $count == 0 then "empty" else "populated" end),
                 tooltip: ("Open windows on this workspace: " + ($count | tostring))}
            end;

        foreach inputs as $event (
            {workspaces: null, windows: null, payload: null};
            .previous = .payload |
            if $event.WorkspacesChanged then
                .workspaces = $event.WorkspacesChanged.workspaces
            elif $event.WindowsChanged then
                .windows = $event.WindowsChanged.windows
            elif $event.WindowOpenedOrChanged then
                $event.WindowOpenedOrChanged.window as $window |
                .windows = ((.windows // [] | map(select(.id != $window.id))) + [$window])
            elif $event.WindowClosed then
                .windows |= map(select(.id != $event.WindowClosed.id))
            elif $event.WorkspaceActivated then
                $event.WorkspaceActivated as $activation |
                (.workspaces | map(select(.id == $activation.id)) | first | .output) as $monitor |
                .workspaces |= map(
                    if .output == $monitor then .is_active = (.id == $activation.id) else . end |
                    if $activation.focused then .is_focused = (.id == $activation.id) else . end
                )
            else . end |
            if .workspaces != null and .windows != null then .payload = payload else . end;
            select(.payload != null and .payload != .previous) | .payload
        )
    ' || true
fi

# Waybar restarts this helper after disconnection; do not report a false zero.
printf '%s\n' '{"text":"–","class":"unavailable","tooltip":"Niri disconnected"}'
