#!/bin/bash

# Persistent file to store the current player
CURRENT_PLAYER_FILE="/tmp/current_player.txt"
WAYBAR_SIGNAL="SIGRTMIN+10"

# Define a mapping of long player names to custom labels
declare -A PLAYER_NAME_MAP=(
    ["plasma-browser-integration"]=""
    ["chromium"]=""
    ["spotify"]=""
    ["vlc"]="󰕼"
    ["kdeconnect"]=""
    # Add more mappings as needed
)

# Helper function to generate a lean progress bar
get_progress_bar() {
    local player=$1
    # Get position and length in seconds
    local pos=$(playerctl -p "$player" position 2>/dev/null | cut -d'.' -f1)
    local len=$(playerctl -p "$player" metadata mpris:length 2>/dev/null)

    # If length is missing (common in some streams), return empty
    if [[ -z "$len" || "$len" -eq 0 ]]; then echo ""; return; fi

    # Convert microseconds to seconds
    len=$((len / 1000000))
    
    # Calculate percentage (0-6)
    local percent=$(( (pos * 6) / len ))
    local bar=""

# Total width of 10 segments
    for i in {0..6}; do
        if [ "$i" -eq 0 ]; then
            # Start Cap
            [[ "$i" -le "$percent" ]] && bar+="" || bar+=""
        elif [ "$i" -eq 6 ]; then
            # End Cap
            [[ "$i" -le "$percent" ]] && bar+="" || bar+=""
        else
            # Middle Segments
            [[ "$i" -le "$percent" ]] && bar+="" || bar+=""
        fi
    done
    echo " $bar"
}

# 1. Automatic Switching Logic
ACTIVE_PLAYING_PLAYER=$(playerctl -l 2>/dev/null | grep -v 'playerctld' | while read -r p; do
    if [[ $(playerctl -p "$p" status 2>/dev/null) == "Playing" ]]; then
        echo "$p"
        break
    fi
done)

if [[ -f "$CURRENT_PLAYER_FILE" ]]; then
    SAVED_PLAYER=$(cat "$CURRENT_PLAYER_FILE")
else
    SAVED_PLAYER=$(playerctl -l 2>/dev/null | head -n 1)
fi

if [[ -n "$ACTIVE_PLAYING_PLAYER" && "$ACTIVE_PLAYING_PLAYER" != "$SAVED_PLAYER" ]]; then
    PLAYER="$ACTIVE_PLAYING_PLAYER"
    echo "$PLAYER" > "$CURRENT_PLAYER_FILE"
else
    PLAYER="$SAVED_PLAYER"
fi

# 2. Handle Click Arguments
case $1 in
    play-pause) playerctl -p "$PLAYER" play-pause && pkill -$WAYBAR_SIGNAL waybar ;;
    next)       playerctl -p "$PLAYER" next && pkill -$WAYBAR_SIGNAL waybar ;;
    previous)   playerctl -p "$PLAYER" previous && pkill -$WAYBAR_SIGNAL waybar ;;
    switch-player)
        players=($(playerctl -l 2>/dev/null | grep -v 'playerctld'))
        for i in "${!players[@]}"; do
            if [[ "${players[$i]}" == "$PLAYER" ]]; then
                next_index=$(( (i + 1) % ${#players[@]} ))
                PLAYER="${players[$next_index]}"
                echo "$PLAYER" > "$CURRENT_PLAYER_FILE"
                break
            fi
        done
        pkill -$WAYBAR_SIGNAL waybar
        ;;
esac

# 3. Output for Waybar
PLAYERS=$(playerctl -l 2>/dev/null)
if [[ -z "$PLAYERS" ]]; then
    exit 0
fi

PLAYER_NAME_RAW=$(playerctl -p "$PLAYER" metadata --format "{{playerName}}" 2>/dev/null)
PLAYER_NAME="${PLAYER_NAME_MAP[$PLAYER_NAME_RAW]:-$PLAYER_NAME_RAW}"

TRACK_INFO=$(playerctl -p "$PLAYER" metadata --format "{{title}} - {{artist}}" 2>/dev/null)
[[ -z "$TRACK_INFO" ]] && TRACK_INFO="No Track Playing"

STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)
case "$STATUS" in
    "Playing") STATUS_ICON="" ;;
    "Paused")  STATUS_ICON="" ;;
    *)         STATUS_ICON="" ;;
esac

PROGRESS_BAR=$(get_progress_bar "$PLAYER")

# Line 1: Shows on the bar (Icon | Player | Progress)
echo "$STATUS_ICON $PLAYER_NAME $PROGRESS_BAR"
# Line 2: Shows in the tooltip
echo "$TRACK_INFO"
