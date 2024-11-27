#!/bin/bash

# Persistent file to store the current player
CURRENT_PLAYER_FILE="/tmp/current_player.txt"

# Define a mapping of long player names to custom labels
declare -A PLAYER_NAME_MAP=(
    ["plasma-browser-integration"]=""
    ["chromium"]=""
    ["spotify"]=""
    ["vlc"]="󰕼"
    ["kdeconnect"]=""
    # Add more mappings as needed
)

# Signal for Waybar refresh (customize SIGRTMIN+10 as needed)
WAYBAR_SIGNAL="SIGRTMIN+10"

# Initialize or read the current player from file
if [[ ! -f "$CURRENT_PLAYER_FILE" ]]; then
    PLAYER=$(playerctl -l 2>/dev/null | head -n 1)
    echo "$PLAYER" > "$CURRENT_PLAYER_FILE"
else
    PLAYER=$(cat "$CURRENT_PLAYER_FILE")
fi

# Helper function to emit Waybar signal
emit_signal() {
    pkill -$WAYBAR_SIGNAL waybar
}

# Helper function to switch to the next available player
switch_player() {
    players=($(playerctl -l 2>/dev/null | grep -v '^playerctld$'))
    if [ "${#players[@]}" -eq 0 ]; then
        PLAYER=""
        echo "" > "$CURRENT_PLAYER_FILE"
    else
        if [[ ! " ${players[@]} " =~ " $PLAYER " ]]; then
            PLAYER="${players[0]}"
        else
            for i in "${!players[@]}"; do
                if [[ "${players[$i]}" == "$PLAYER" ]]; then
                    next_index=$(( (i + 1) % ${#players[@]} ))
                    PLAYER="${players[$next_index]}"
                    break
                fi
            done
        fi
        echo "$PLAYER" > "$CURRENT_PLAYER_FILE"
    fi
    emit_signal  # Emit signal after switching players
}

# Check the argument passed by Waybar for handling clicks
case $1 in
    play-pause) 
        playerctl -p "$PLAYER" play-pause && emit_signal 
        ;;
    next) 
        playerctl -p "$PLAYER" next && emit_signal 
        ;;
    previous) 
        playerctl -p "$PLAYER" previous && emit_signal 
        ;;
    switch-player) 
        switch_player 
        ;;
    advance) 
        playerctl -p "$PLAYER" position 15+ && emit_signal 
        ;;
    rewind) 
        playerctl -p "$PLAYER" position 15- && emit_signal 
        ;;
esac

# Check if there are any players available
PLAYERS=$(playerctl -l 2>/dev/null)
if [[ -z "$PLAYERS" ]]; then
    exit 0  # No players available, output nothing to hide the module
fi

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
    exit 0  # No active player, so output nothing to hide the module
else
    echo "$STATUS_ICON | $PLAYER_NAME"
    echo "$TRACK_INFO"
fi

