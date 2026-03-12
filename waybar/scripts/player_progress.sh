#!/bin/bash

# Helper function to generate a lean progress bar
get_progress_bar() {
    # Get position and length in seconds
    local pos=$(playerctl position 2>/dev/null | cut -d'.' -f1)
    local len=$(playerctl metadata mpris:length 2>/dev/null)

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
    echo "$bar"
}

PROGRESS_BAR=$(get_progress_bar)

# Line 1: Shows on the bar
echo "$(get_progress_bar)"
