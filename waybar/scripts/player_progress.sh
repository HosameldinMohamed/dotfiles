#!/bin/bash

# Helper function to map progress to a single circle icon
get_progress_bar() {
    # Get position and length in seconds
    local pos=$(playerctl position 2>/dev/null | cut -d'.' -f1)
    local len=$(playerctl metadata mpris:length 2>/dev/null)

    # If length is missing (common in some streams), return empty
    if [[ -z "$len" || "$len" -eq 0 ]]; then echo ""; return; fi

    # Convert microseconds to seconds
    len=$((len / 1000000))
    pos=${pos:-0}

    local -a icons=("󰪞" "󰪟" "󰪠" "󰪡" "󰪢" "󰪣" "󰪤" "󰪥")
    local idx=$(( (pos * 7) / len ))

    # Clamp index to valid range
    (( idx < 0 )) && idx=0
    (( idx > 7 )) && idx=7

    echo "${icons[$idx]}"
}

PROGRESS_BAR=$(get_progress_bar)

# Line 1: Shows on the bar
echo "$(get_progress_bar)"
