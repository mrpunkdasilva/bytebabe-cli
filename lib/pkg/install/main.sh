#!/bin/bash
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

# Cores Cyberpunk
CYBER_RED='\033[38;5;196m'
CYBER_GREEN='\033[38;5;46m'
CYBER_BLUE='\033[38;5;45m'
CYBER_YELLOW='\033[38;5;226m'
CYBER_PURPLE='\033[38;5;129m'
CYBER_CYAN='\033[38;5;51m'
RESET='\033[0m'

show_header() {
  clear
  echo -e "${CYBER_BLUE}╔═══════════════════════════════════════╗${RESET}"
  echo -e "  ${CYBER_GREEN}BYTEBABE INSTALL ${CYBER_PURPLE}» ${CYBER_CYAN}Package management system${RESET} "
  echo -e "${CYBER_BLUE}╚═══════════════════════════════════════╝${RESET}"
  echo
}

ensure_flatpak() {
  if ! command -v flatpak &>/dev/null; then
    echo -e "${CYBER_YELLOW}» Installing Flatpak...${RESET}"

    if command -v apt &>/dev/null; then
      sudo apt install -y flatpak
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    elif command -v dnf &>/dev/null; then
      sudo dnf install -y flatpak
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    elif command -v pacman &>/dev/null; then
      sudo pacman -S --noconfirm flatpak
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    else
      echo -e "${CYBER_RED}✖ Cannot install Flatpak automatically${RESET}"
      return 1
    fi

    echo -e "${CYBER_GREEN}✓ Flatpak installed successfully${RESET}"
  fi
  return 0
}

install_package() {
  local pkg="$1"
  echo -e "${CYBER_BLUE}» Installing ${pkg}...${RESET}"

  # Try Flatpak first
  if command -v flatpak &>/dev/null; then
    if flatpak install -y flathub "$pkg" 2>/dev/null; then
      echo -e "${CYBER_GREEN}✓ Installed via Flatpak${RESET}"
      return 0
    fi
  fi

  # Fallback to native package manager
  if command -v apt &>/dev/null; then
    sudo apt install -y "$pkg" && return 0
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$pkg" && return 0
  elif command -v pacman &>/dev/null; then
    sudo pacman -S --noconfirm "$pkg" && return 0
  fi

  echo -e "${CYBER_RED}✖ Failed to install ${pkg}${RESET}"
  return 1
}

show_installed_packages() {
  show_header
  echo -e "${CYBER_PURPLE}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
  echo -e "${CYBER_CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ INSTALLED PACKAGES ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
  echo -e "${CYBER_PURPLE}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
  echo

  # Flatpak packages
  echo -e "${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${CYBER_BLUE}║ ${CYBER_GREEN}»»»»»»»»»»»»»»»»»»» ${CYBER_YELLOW}FLATPAK APPLICATIONS ${CYBER_GREEN}«««««««««««««««««««${CYBER_BLUE} ${RESET}"
  echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"

  if command -v flatpak &>/dev/null; then
    flatpak list --app --columns=name,application | while read -r line; do
      name=$(echo "$line" | awk '{print $1}')
      appid=$(echo "$line" | awk '{print $2}')
      echo -e "${CYBER_BLUE} ${CYBER_CYAN}▪ ${CYBER_GREEN}$(printf "%-30s" "$name") ${CYBER_PURPLE}→ ${CYBER_YELLOW}$appid${CYBER_BLUE} ${RESET}"
    done | head -10
  else
    echo -e "${CYBER_BLUE} ${CYBER_RED} Flatpak not installed ${CYBER_BLUE}${RESET}"
  fi
  echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
  echo

  # Native packages
  echo -e "${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${CYBER_PURPLE}║ ${CYBER_GREEN}»»»»»»»»»»»»»»»»»» ${CYBER_YELLOW}NATIVE PACKAGES ${CYBER_GREEN}««««««««««««««««««${CYBER_PURPLE} ${RESET}"
  echo -e "${CYBER_PURPLE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"

  if command -v apt &>/dev/null; then
    echo -e "${CYBER_PURPLE}║ ${CYBER_CYAN}Status${RESET} | ${CYBER_CYAN}Name${RESET}${CYBER_PURPLE} ${RESET}"
    dpkg --list | while read -r line; do
      status=$(echo "$line" | awk '{print $1}')
      pkg=$(echo "$line" | awk '{print $2}')
      version=$(echo "$line" | awk '{print $3}')
      arch=$(echo "$line" | awk '{print $4}')

      # Color coding based on status
      case $status in
        "ii") status_color="${CYBER_GREEN}✓${RESET}" ;;
        "iF") status_color="${CYBER_RED}✖${RESET}" ;;
        *) status_color="${CYBER_YELLOW}?${RESET}" ;;
      esac

      echo -e "${CYBER_PURPLE}║ ${status_color} ${CYBER_CYAN}$(printf "%-6s" "$status") ${CYBER_GREEN}$(printf "%-4s" "$pkg") ${CYBER_YELLOW}$version ${CYBER_PINK}$arch${CYBER_PURPLE} ${RESET}"
    done | head -10
  elif command -v dnf &>/dev/null; then
    dnf list installed | while read -r line; do
      pkg=$(echo "$line" | awk '{print $1}')
      version=$(echo "$line" | awk '{print $2}')
      repo=$(echo "$line" | awk '{print $3}')
      echo -e "${CYBER_PURPLE}║ ${CYBER_GREEN}$(printf "%-40s" "$pkg") ${CYBER_YELLOW}$version ${CYBER_PINK}($repo)${CYBER_PURPLE} ${RESET}"
    done | head -10
  elif command -v pacman &>/dev/null; then
    pacman -Q | while read -r line; do
      pkg=$(echo "$line" | awk '{print $1}')
      version=$(echo "$line" | awk '{print $2}')
      echo -e "${CYBER_PURPLE}║ ${CYBER_GREEN}$(printf "%-40s" "$pkg") ${CYBER_YELLOW}$version${CYBER_PURPLE} ${RESET}"
    done | head -10
  else
    echo -e "${CYBER_PURPLE}║ ${CYBER_RED} Unsupported package manager ${CYBER_PURPLE}║${RESET}"
  fi
  echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
  echo

  # Footer
  echo -e "${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
  echo -e "${CYBER_BLUE}║ ${CYBER_CYAN}»»»» ${CYBER_PINK}Press ${CYBER_GREEN}ENTER ${CYBER_PINK}to continue or ${CYBER_RED}Q ${CYBER_PINK}to quit ${CYBER_CYAN}««««${CYBER_BLUE} ${RESET}"
  echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"

  read -n 1 -s input
  [[ "$input" == "q" ]] && return 1
}

run_install() {
  if [[ $# -gt 0 ]]; then
    install_package "$@"
    return
  fi

  while true; do
    show_header

    echo -e "${CYBER_YELLOW}» Main Menu:${RESET}"

    options=(
      "Install Package"
      "List Installed Packages"
      "Exit"
    )

    PS3=$'\033[38;5;45m»»\033[0m '
    select opt in "${options[@]}"; do
      case $opt in
        "Install Package")
          read -p $'\033[38;5;45m»»\033[0m Enter package name: ' pkg
          install_package "$pkg"
          break
          ;;
        "List Installed Packages")
          show_installed_packages
          break
          ;;
        "Exit")
          return 0
          ;;
        *)
          echo -e "${CYBER_RED}✖ Invalid option${RESET}"
          break
          ;;
      esac
    done
  done
}