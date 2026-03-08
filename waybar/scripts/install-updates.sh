#!/usr/bin/env bash
#  ___           _        _ _   _   _           _       _             
# |_ _|_ __  ___| |_ __ _| | | | | | |_ __   __| | __ _| |_ ___  ___  
#  | || '_ \/ __| __/ _` | | | | | | | '_ \ / _` |/ _` | __/ _ \/ __| 
#  | || | | \__ \ || (_| | | | | |_| | |_) | (_| | (_| | ||  __/\__ \ 
# |___|_| |_|___/\__\__,_|_|_|  \___/| .__/ \__,_|\__,_|\__\___||___/ 
#                                    |_|                              
# Minimal cross-distro updater (Arch= yay, Ubuntu/Debian= apt)
# No Timeshift. Optional UX: figlet, gum, notify-send.

set -Eeuo pipefail
trap 'echo; echo ":: ERROR: Something went wrong. Exiting."; exit 1' ERR

# ---------- Helpers ----------
have() { command -v "$1" >/dev/null 2>&1; }

notify() {
  if have notify-send && [ -n "${DISPLAY:-}" ]; then
    notify-send "$@"
  fi
}

banner() {
  clear || true
  if have figlet; then figlet "Updates"; else echo "=== Updates ==="; fi
  echo
}

confirm() {
  if have gum; then
    gum confirm "$1"
  else
    read -rp "$1 [y/N]: " reply
    [[ "${reply:-N}" =~ ^[Yy]$ ]]
  fi
}

input_text() {
  if have gum; then
    gum input --placeholder "$1" || true
  else
    read -rp "$1: " _ans
    echo "${_ans:-}"
  fi
}

pause() {
  echo "Press [ENTER] to close."
  read -r || true
}

detect_distro() {
  local id='' like=''
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    id="${ID:-}"; like="${ID_LIKE:-}"
  fi

  # Arch-like?
  if have yay || [[ "${id}" == "arch" ]] || [[ "${like}" == *"arch"* ]] || have pacman; then
    echo "arch"
    return
  fi

  # Debian/Ubuntu-like?
  if have apt || [[ "${id}" =~ (ubuntu|debian) ]] || [[ "${like}" =~ (ubuntu|debian) ]]; then
    echo "debian"
    return
  fi

  # Fallback: infer by manager presence
  if have apt; then echo "debian"; return; fi
  if have pacman || have yay; then echo "arch"; return; fi

  echo "unknown"
}

# ---------- Start ----------
sleep 0.5
banner

# Confirm start
if ! confirm "DO YOU WANT TO START THE UPDATE NOW?"; then
  echo ":: Update canceled."
  exit 0
fi
echo ":: Update started."
echo

# Detect distro family
family="$(detect_distro)"
if [[ "$family" == "unknown" ]]; then
  echo ":: Could not detect supported distro family."
  echo ":: This script supports Arch (yay/pacman) and Ubuntu/Debian (apt)."
  exit 1
fi

# Optional preview of updates
show_preview() {
  echo ":: Checking available updates..."
  if [[ "$family" == "arch" ]]; then
    if have checkupdates; then
      echo "-- Repo updates:"
      checkupdates || true
    fi
    if have yay && yay -Qua >/dev/null 2>&1; then
      echo
      echo "-- AUR updates:"
      yay -Qua || true
    fi
  else
    # debian/ubuntu
    echo "-- Refreshing package lists (dry preview may be limited)..."
    sudo apt update -o Dir::Etc::sourcelist="sources.list" -o Dir::Etc::sourceparts="sources.list.d" >/dev/null || true
    echo "-- Upgradable packages:"
    apt list --upgradable 2>/dev/null | sed '1,1d' || true
  fi
  echo
}

# Ask whether to preview
if confirm "Show a preview of pending updates?"; then
  show_preview
fi

# ---------- Perform updates ----------
if [[ "$family" == "arch" ]]; then
  # Require yay or fallback to pacman
  if have yay; then
    echo ":: Running repo update..."
    yay -Syu --repo --noconfirm

    echo
    echo ":: Running AUR update..."
    # Remove --noconfirm if you want to review PKGBUILDs
    yay -Sua --noconfirm
  elif have pacman; then
    echo ":: yay not found. Using pacman for repos only."
    sudo pacman -Syu --noconfirm
  else
    echo ":: Neither yay nor pacman found. Cannot update."
    exit 1
  fi
else
  # Debian/Ubuntu family using apt
  echo ":: Updating package lists..."
  sudo apt update

  echo
  echo ":: Upgrading packages..."
  # Use full-upgrade to handle kernel/meta changes; change to 'upgrade' if preferred
  sudo apt -y full-upgrade

  echo
  # Optional cleanup
  if confirm "Run 'apt autoremove' and 'apt autoclean'?"; then
    sudo apt -y autoremove
    sudo apt autoclean
    echo
  fi
fi

notify "Update complete"
echo ":: Update complete"
echo
pause
