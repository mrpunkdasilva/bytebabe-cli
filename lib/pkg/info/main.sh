#!/bin/bash


CYBER_BLUE='\033[38;5;45m'
CYBER_GREEN='\033[38;5;118m'
CYBER_YELLOW='\033[38;5;227m'
CYBER_RED='\033[38;5;196m'
CYBER_PURPLE='\033[38;5;93m'
NC='\033[0m'


BOLD='\033[1m'
FLASH='\033[5m'
RESET='\033[0m'


show_header() {
  clear
  echo -e "${CYBER_BLUE}"
  echo -e " █▀▄ █▀█ █▀▀ █▀▀ ▄▀█ █▀▀ ▀█▀ █▀█ █▀█"
  echo -e " █▄▀ █▄█ █▄▄ ██▄ █▀█ █▄▄ ░█░ █▄█ █▀▄"
  echo -e "${CYBER_PURPLE}"
  echo -e "╔════════════════════════════════════════╗"
  echo -e "║   ${CYBER_BLUE}⚡ ${CYBER_YELLOW}PACKAGE INSPECTOR v5.0 ${CYBER_PURPLE}⚡   ║"
  echo -e "╚════════════════════════════════════════╝${NC}"
  echo
}


show_package_info() {
  local pkg=$1

  echo -e "\n${CYBER_BLUE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_YELLOW}🔍 SCANNING PACKAGE: ${CYBER_PURPLE}$pkg${NC}\n"

  # Detecta o gerenciador de pacotes
  if command -v apt &>/dev/null; then
    # APT (Debian/Ubuntu)
    echo -e "${CYBER_GREEN}📦 PACKAGE INFO:${NC}"
    apt show "$pkg" 2>/dev/null | grep -E 'Package|Version|Priority|Section|Maintainer|Depends|Description' | \
    awk -F':' -v blue="$CYBER_BLUE" -v nc="$NC" '{printf "%s%-15s%s %s\n", blue, $1, nc, $2}'

    echo -e "\n${CYBER_GREEN}📂 FILE LIST:${NC}"
    dpkg -L "$pkg" 2>/dev/null | head -n 20
    echo -e "${CYBER_YELLOW}(showing first 20 files, use '--all' for complete list)${NC}"

  elif command -v dnf &>/dev/null; then
    # DNF (Fedora)
    echo -e "${CYBER_GREEN}📦 PACKAGE INFO:${NC}"
    dnf info "$pkg" 2>/dev/null | grep -E 'Name|Version|Release|Architecture|Size|License|Summary' | \
    awk -F':' -v blue="$CYBER_BLUE" -v nc="$NC" '{printf "%s%-15s%s %s\n", blue, $1, nc, $2}'

    echo -e "\n${CYBER_GREEN}📂 FILE LIST:${NC}"
    rpm -ql "$pkg" 2>/dev/null | head -n 20
    echo -e "${CYBER_YELLOW}(showing first 20 files, use '--all' for complete list)${NC}"

  elif command -v pacman &>/dev/null; then
    # Pacman (Arch)
    echo -e "${CYBER_GREEN}📦 PACKAGE INFO:${NC}"
    pacman -Qi "$pkg" 2>/dev/null | grep -E 'Name|Version|Description|Architecture|URL|Depends On' | \
    awk -F':' -v blue="$CYBER_BLUE" -v nc="$NC" '{printf "%s%-15s%s %s\n", blue, $1, nc, $2}'

    echo -e "\n${CYBER_GREEN}📂 FILE LIST:${NC}"
    pacman -Ql "$pkg" 2>/dev/null | head -n 20 | cut -d' ' -f2
    echo -e "${CYBER_YELLOW}(showing first 20 files, use '--all' for complete list)${NC}"

  else
    echo -e "${CYBER_RED}No supported package manager found!${NC}"
  fi

  echo -e "${CYBER_BLUE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}


show_package_files() {
  local pkg=$1

  echo -e "\n${CYBER_BLUE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_YELLOW}📂 FULL FILE LIST FOR: ${CYBER_PURPLE}$pkg${NC}\n"

  if command -v apt &>/dev/null; then
    dpkg -L "$pkg"
  elif command -v dnf &>/dev/null; then
    rpm -ql "$pkg"
  elif command -v pacman &>/dev/null; then
    pacman -Ql "$pkg" | cut -d' ' -f2
  fi

  echo -e "${CYBER_BLUE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}


show_dependencies() {
  local pkg=$1

  echo -e "\n${CYBER_BLUE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_YELLOW}🔄 DEPENDENCY TREE FOR: ${CYBER_PURPLE}$pkg${NC}\n"

  if command -v apt &>/dev/null; then
    apt-cache depends "$pkg" | \
    awk -v green="$CYBER_GREEN" -v blue="$CYBER_BLUE" -v nc="$NC" '
      /Depends:/ {printf "%sDepends:%s %s\n", green, nc, $2}
      /Recommends:/ {printf "%sRecommends:%s %s\n", blue, nc, $2}
    '
  elif command -v dnf &>/dev/null; then
    dnf repoquery --requires --resolve "$pkg" | \
    awk -v green="$CYBER_GREEN" '{printf "%s%s\n", green, $0}'
  elif command -v pacman &>/dev/null; then
    pactree "$pkg" | \
    awk -v green="$CYBER_GREEN" -v yellow="$CYBER_YELLOW" -v nc="$NC" '
      /^├─/ {printf "%s%s\n", green, $0 nc}
      /^└─/ {printf "%s%s\n", yellow, $0 nc}
    '
  fi

  echo -e "${CYBER_BLUE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}


show_help() {
  echo -e "\n${CYBER_YELLOW}${BOLD}USAGE:${RESET}"
  echo -e "  ${CYBER_GREEN}info <package>${NC}       - Show package information"
  echo -e "  ${CYBER_GREEN}info files <package>${NC} - List all package files"
  echo -e "  ${CYBER_GREEN}info deps <package>${NC}  - Show package dependencies"
  echo -e "\n${CYBER_YELLOW}${BOLD}EXAMPLES:${RESET}"
  echo -e "  ${CYBER_BLUE}info nginx"
  echo -e "  ${CYBER_BLUE}info files python3"
  echo -e "  ${CYBER_BLUE}info deps nodejs${NC}"
}


run_info() {
  show_header

  case "$1" in
    "files")
      if [ -z "$2" ]; then
        echo -e "${CYBER_RED}Error: Please specify a package name${NC}"
        show_help
      else
        show_package_files "$2"
      fi
      ;;
    "deps"|"depends")
      if [ -z "$2" ]; then
        echo -e "${CYBER_RED}Error: Please specify a package name${NC}"
        show_help
      else
        show_dependencies "$2"
      fi
      ;;
    "")
      show_help
      ;;
    *)
      if [[ "$1" == "--help" ]]; then
        show_help
      else
        show_package_info "$1"
      fi
      ;;
  esac
}


run_info "$@"