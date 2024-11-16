#!/bin/bash

# Define the folder where the wallpapers are stored
wallpaper_folder="$HOME/Pictures/wallpapers"

# Get the list of wallpaper files in the folder (only files that are images)
wallpapers=($(find "$wallpaper_folder" -type f -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg"))

# Check if the folder contains any valid wallpapers
if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "No valid wallpapers found in $wallpaper_folder"
    exit 1
fi

# Get the list of monitor names (e.g., HDMI-A-1, eDP-1)
monitors=$(hyprctl monitors | grep 'Monitor' | awk '{ print $2 }')

# Convert the monitors string into an array
monitor_array=($monitors)
monitor_count=${#monitor_array[@]}

# Select a small subset of wallpapers (e.g., 5 random ones)
subset_wallpapers=($(shuf -e "${wallpapers[@]}" | head -n 5))

# If there are more monitors than wallpapers in the subset, cycle through them
if [ ${#subset_wallpapers[@]} -lt $monitor_count ]; then
    additional_wallpapers_needed=$((monitor_count - ${#subset_wallpapers[@]}))
    subset_wallpapers+=($(shuf -e "${subset_wallpapers[@]}" | head -n $additional_wallpapers_needed))
fi

# Preload only the subset of wallpapers
for wallpaper in "${subset_wallpapers[@]}"; do
    hyprctl hyprpaper preload "$(realpath "$wallpaper")"
done

# Assign a random wallpaper from the subset to each monitor
for ((i=0; i<monitor_count; i++)); do
    monitor="${monitor_array[$i]}"
    wallpaper="${subset_wallpapers[$i % ${#subset_wallpapers[@]}]}"

    # Ensure absolute path for hyprpaper
    wallpaper_path=$(realpath "$wallpaper")

    # Debug output
    echo "Monitor $i: $monitor"
    echo "Assigned Wallpaper: $wallpaper_path"

    # Set the wallpaper for this monitor
    hyprctl hyprpaper wallpaper "$monitor,$wallpaper_path"

    # Wait a moment to prevent multiple commands from being sent too quickly
    sleep 0.5
done

