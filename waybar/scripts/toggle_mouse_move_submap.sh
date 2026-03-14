#!/usr/bin/env sh

current_submap="$(hyprctl submap 2>/dev/null | awk 'NR == 1 { print $1 }')"

if [ "$current_submap" = "mouseMove" ]; then
    hyprctl dispatch submap reset
else
    hyprctl dispatch submap mouseMove
fi