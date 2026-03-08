#!/usr/bin/env bash
#  _   _           _       _             
# | | | |_ __   __| | __ _| |_ ___  ___  
# | | | | '_ \ / _` |/ _` | __/ _ \/ __| 
# | |_| | |_) | (_| | (_| | ||  __/\__ \ 
#  \___/| .__/ \__,_|\__,_|\__\___||___/ 
#       |_|                              
#
# Waybar custom-updates module
# by Stephan Raabe (2023) - refined for Arch + Ubuntu/Debian
# ------------------------------------------------------------
# Arch requires: pacman-contrib (for checkupdates), yay (for AUR)
# Ubuntu/Debian: uses apt
# ------------------------------------------------------------

set -euo pipefail

# -----------------------------
# Configurable thresholds
# -----------------------------
threshold_green=0
threshold_yellow=25
threshold_red=100

# -----------------------------
# Helpers
# -----------------------------
have() { command -v "$1" >/dev/null 2>&1; }

detect_family() {
  local id like
  id=""; like=""
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    id="${ID:-}"; like="${ID_LIKE:-}"
  fi
  # Arch-like?
  if have pacman || have yay || [[ "${id}" == "arch" ]] || [[ "${like:-}" == *"arch"* ]]; then
    echo "arch"; return
  fi
  # Debian/Ubuntu-like?
  if have apt || [[ "${id}" =~ (ubuntu|debian) ]] || [[ "${like:-}" =~ (ubuntu|debian) ]]; then
    echo "debian"; return
  fi
  # Fallback by tool presence
  if have apt; then echo "debian"; return; fi
  if have pacman || have yay; then echo "arch"; return; fi
  echo "unknown"
}

# -----------------------------
# Count updates
# -----------------------------
count_updates_arch() {
  local repo_count=0 aur_count=0 total=0

  if have checkupdates; then
    # checkupdates exits nonzero when no updates; we just wc -l its output
    if ! repo_count=$(checkupdates 2>/dev/null | wc -l); then
      repo_count=0
    fi
  fi

  if have yay; then
    # -Qua: quiet list of AUR updates
    if ! aur_count=$(yay -Qua 2>/dev/null | wc -l); then
      aur_count=0
    fi
  fi

  total=$(( repo_count + aur_count ))
  echo "$total"
}

count_updates_debian() {
  # We avoid apt-get update here to keep this lightweight in a status bar.
  # The count may be stale until apt lists are refreshed elsewhere.
  local cnt=0
  if have apt; then
    # 'apt list --upgradable' prints a header line; we remove it.
    # We ignore errors for older apt versions that behave slightly differently.
    if ! cnt=$(apt list --upgradable 2>/dev/null | sed '1d' | wc -l); then
      cnt=0
    fi
  fi
  echo "$cnt"
}

# -----------------------------
# Main
# -----------------------------
family="$(detect_family)"

updates=0
case "$family" in
  arch)   updates="$(count_updates_arch)" ;;
  debian) updates="$(count_updates_debian)" ;;
  *)      updates=0 ;;
esac

# Determine CSS class by thresholds
css_class="green"
if [ "$updates" -gt "$threshold_yellow" ]; then
  css_class="yellow"
fi
if [ "$updates" -gt "$threshold_red" ]; then
  css_class="red"
fi

# Output JSON for Waybar custom module
if [ "$updates" -gt "$threshold_green" ]; then
  # text and alt show the number; tooltip hints action; class controls color
  printf '{"text": "%s", "alt": "%s", "tooltip": "Click to update your system", "class": "%s"}' \
    "$updates" "$updates" "$css_class"
else
  printf '{"text": "0", "alt": "0", "tooltip": "No updates available", "class": "green"}'
fi
