#!/bin/bash

# Define an array of wallpaper paths (use absolute paths)
wallpapers=(
    "$HOME/Pictures/wallpapers/listentoyourheart.jpg"
    "$HOME/Pictures/wallpapers/forestlake.jpg"
    "$HOME/Pictures/wallpapers/forest-fall-nature-trees-4K-107.jpg"
    "$HOME/Pictures/wallpapers/forestlake.jpg"
    "$HOME/Pictures/wallpapers/listentoyourheart.jpg"
    "$HOME/Pictures/wallpapers/listentoyourheart.jpg"
    # Add more wallpapers as needed
)

# Get the list of monitor names (e.g., HDMI-A-1, eDP-1)
monitors=$(hyprctl monitors | grep 'Monitor' | awk '{ print $2 }')

# Convert the monitors string into an array
monitor_array=($monitors)

# Preload wallpapers (only once, regardless of how many monitors)
for wallpaper in "${wallpapers[@]}"; do
    hyprctl hyprpaper preload "$wallpaper"
done

# Assign wallpapers to monitors
monitor_count=${#monitor_array[@]}
wallpaper_count=${#wallpapers[@]}

# Iterate over the monitors and assign wallpapers
for ((i=0; i<monitor_count; i++)); do
    # Cycle through wallpapers if there are more monitors than wallpapers
    wallpaper_index=$((i % wallpaper_count))
    monitor="${monitor_array[$i]}"
    wallpaper="${wallpapers[$wallpaper_index]}"
    
    # Debug output
    echo "Monitor $i: $monitor"
    echo "Assigned Wallpaper: $wallpaper"
    
    # Set the wallpaper for this monitor
    hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
done

