#!/bin/bash

# Read the player name from the file
PLAYER=$(cat /tmp/current_player.txt)

# Use playerctl with the specified player
playerctl -p "$PLAYER" "$@"
