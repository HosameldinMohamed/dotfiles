#!/bin/bash

# Persistent file to store the current player
CURRENT_PLAYER_FILE="/tmp/current_player.txt"

# Define a mapping of long player names to custom labels
declare -A PLAYER_NAME_MAP=(
    ["plasma-browser-integration"]=""
    ["chromium"]=""
    ["spotify"]=""
    ["vlc"]="󰕼"
    # Add more mappings as needed
)

# Initialize or read the current player from file
if [[ ! -f "$CURRENT_PLAYER_FILE" ]]; then
    PLAYER=$(playerctl -l 2>/dev/null | head -n 1)
    echo "$PLAYER" > "$CURRENT_PLAYER_FILE"
else
    PLAYER=$(cat "$CURRENT_PLAYER_FILE")
fi

# Helper function to switch to the next available player
switch_player() {
    players=($(playerctl -l 2>/dev/null | grep -v '^playerctld$'))
    if [ "${#players[@]}" -eq 0 ]; then
        PLAYER=""
    else
        # Find the current player's index in the list
        for i in "${!players[@]}"; do
            if [[ "${players[$i]}" == "$PLAYER" ]]; then
                next_index=$(( (i + 1) % ${#players[@]} ))
                PLAYER="${players[$next_index]}"
                echo "$PLAYER" > "$CURRENT_PLAYER_FILE"
                break
            fi
        done
    fi
}

# Check the argument passed by Waybar for handling clicks
case $1 in
    play-pause) playerctl -p "$PLAYER" play-pause ;;
    next) playerctl -p "$PLAYER" next ;;
    previous) playerctl -p "$PLAYER" previous ;;
    switch-player) switch_player ;;
esac

# Main loop to continuously update player status
while true; do
    # Get the player name and apply the custom label if it exists in the mapping
    PLAYER_NAME_RAW=$(playerctl -p "$PLAYER" metadata --format "{{playerName}}" 2>/dev/null)
    PLAYER_NAME="${PLAYER_NAME_MAP[$PLAYER_NAME_RAW]:-$PLAYER_NAME_RAW}"

    # Get track title and artist
    TRACK_INFO=$(playerctl -p "$PLAYER" metadata --format "{{title}} - {{artist}}" 2>/dev/null)
    TRACK_INFO="${TRACK_INFO:-No Track Playing}"

    # Get the playback status and set icon accordingly
    STATUS=$(playerctl -p "$PLAYER" status 2>/dev/null)
    case "$STATUS" in
        "Playing") STATUS_ICON="" ;;  # Pause icon when playing
        "Paused") STATUS_ICON="" ;;   # Play icon when paused
        *) STATUS_ICON="" ;;         # Stop icon otherwise
    esac

    # Output for Waybar
    if [[ -z "$PLAYER_NAME" ]]; then
        echo "No Player"
        echo "No media player available"
    else
        echo "$STATUS_ICON | $PLAYER_NAME"
        echo "$TRACK_INFO"
    fi

    # Sleep for 0.5 seconds before refreshing
    sleep 0.5
done

