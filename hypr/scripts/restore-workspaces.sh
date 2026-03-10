#!/usr/bin/env bash

CONF="$HOME/.config/hypr/workspaces.conf"

have() { command -v "$1" >/dev/null 2>&1; }

notify_summary() {
    local title="$1"
    local body="$2"
    if have notify-send && { [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; }; then
        notify-send "$title" "$body"
    fi
}

if [[ ! -f "$CONF" ]]; then
    echo "Error: $CONF not found."
    exit 1
fi

# Build monitor name -> monitor ID map from Hyprland output.
declare -A MONITOR_IDS
while IFS= read -r line; do
    if [[ "$line" =~ ^Monitor[[:space:]]+([^[:space:]]+)[[:space:]]+\(ID[[:space:]]+([0-9]+)\): ]]; then
        MONITOR_IDS["${BASH_REMATCH[1]}"]="${BASH_REMATCH[2]}"
    fi
done < <(hyprctl monitors)

if [[ ${#MONITOR_IDS[@]} -eq 0 ]]; then
    echo "Error: no monitors detected from hyprctl."
    exit 1
fi

moved_count=0
failed_count=0
missing_monitor_count=0
parse_error_count=0

while IFS= read -r line; do
    # Skip empty or comment lines
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Expected line format: workspace=<id>,monitor:<name>[,...]
    if [[ "$line" =~ ^workspace=([0-9]+),monitor:([^,[:space:]]+) ]]; then
        workspace_id="${BASH_REMATCH[1]}"
        monitor_name="${BASH_REMATCH[2]}"
        monitor_id="${MONITOR_IDS[$monitor_name]}"

        if [[ -z "$monitor_id" ]]; then
            echo "Warning: monitor '$monitor_name' not found, skipping workspace $workspace_id"
            ((missing_monitor_count++))
            continue
        fi

        echo "Workspace $workspace_id -> Monitor $monitor_name (ID $monitor_id)"

        if hyprctl dispatch moveworkspacetomonitor "$workspace_id" "$monitor_id" >/dev/null; then
            ((moved_count++))
        else
            echo "Warning: failed to move workspace $workspace_id to monitor ID $monitor_id"
            ((failed_count++))
        fi
    else
        echo "Warning: could not parse line: $line"
        ((parse_error_count++))
    fi

done < "$CONF"

summary="Moved: $moved_count | Failed: $failed_count | Missing monitor: $missing_monitor_count | Parse errors: $parse_error_count"

echo "Workspace-to-monitor assignments restored. $summary"
notify_summary "Hyprland Workspaces Restored" "$summary"

