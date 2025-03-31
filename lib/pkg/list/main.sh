#!/bin/bash

# Cores Cyberpunk
CYBER_CYAN='\033[38;5;51m'
CYBER_GREEN='\033[38;5;118m'
CYBER_YELLOW='\033[38;5;227m'
CYBER_PURPLE='\033[38;5;93m'
CYBER_RED='\033[38;5;196m'
NC='\033[0m'

# Efeitos
BOLD='\033[1m'
RESET='\033[0m'

# ASCII Art Header
show_header() {
  clear
  echo -e "${CYBER_CYAN}"
  echo -e " █▀ █▀▀ █▀█ █ █▀▄▀█ █▀▀ █▀▄ █▀▀ █▀█"
  echo -e " ▄█ ██▄ █▀▄ █ █░▀░█ ██▄ █▄▀ ██▄ █▀▄"
  echo -e "${CYBER_PURPLE}"
  echo -e "╔════════════════════════════════════════╗"
  echo -e "║   ${CYBER_CYAN}⚡ ${CYBER_YELLOW}CYBERWARE CATALOG v3.0 ${CYBER_PURPLE}⚡   ║"
  echo -e "╚════════════════════════════════════════╝${NC}"
  echo
}

# Lista pacotes instalados
list_packages() {
  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_CYAN}🔍 SCANNING INSTALLED CYBERWARE...${NC}\n"

  # Detecta o gerenciador de pacotes
  if command -v apt &>/dev/null; then
    echo -e "${CYBER_YELLOW}APT PACKAGES:${NC}"
    apt list --installed 2>/dev/null | head -n 20 | awk -F/ '{printf "%-40s %s\n", $1, "'${CYBER_GREEN}'✓ installed'${NC}'"}'

  elif command -v dnf &>/dev/null; then
    echo -e "${CYBER_YELLOW}DNF PACKAGES:${NC}"
    dnf list installed 2>/dev/null | head -n 20 | awk '{printf "%-40s %s\n", $1, "'${CYBER_GREEN}'✓ installed'${NC}'"}'

  elif command -v pacman &>/dev/null; then
    echo -e "${CYBER_YELLOW}PACMAN PACKAGES:${NC}"
    pacman -Q 2>/dev/null | head -n 20 | awk '{printf "%-40s %s\n", $1, "'${CYBER_GREEN}'✓ installed'${NC}'"}'

  else
    echo -e "${CYBER_RED}No supported package manager found!${NC}"
  fi

  echo -e "\n${CYBER_YELLOW}Use '--all' flag to see complete list${NC}"
  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Lista todos os pacotes (sem limitação)
list_all_packages() {
  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_CYAN}🔍 FULL CYBERWARE SCAN...${NC}\n"

  if command -v apt &>/dev/null; then
    apt list --installed 2>/dev/null | awk -F/ '{printf "%-40s %s\n", $1, "'${CYBER_GREEN}'✓ installed'${NC}'"}'

  elif command -v dnf &>/dev/null; then
    dnf list installed 2>/dev/null | awk '{printf "%-40s %s\n", $1, "'${CYBER_GREEN}'✓ installed'${NC}'"}'

  elif command -v pacman &>/dev/null; then
    pacman -Q 2>/dev/null | awk '{printf "%-40s %s\n", $1, "'${CYBER_GREEN}'✓ installed'${NC}'"}'
  fi

  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Lista serviços do sistema
list_services() {
  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_CYAN}🛠️ ACTIVE SYSTEM SERVICES:${NC}\n"

  systemctl list-units --type=service --state=running --no-pager --no-legend | \
  head -n 15 | \
  awk '{printf "%-35s %s%s%s\n", $1, "'${CYBER_GREEN}'", "● running", "'${NC}'"}'

  echo -e "\n${CYBER_YELLOW}Use '--all' flag to see inactive services${NC}"
  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Função principal
run_list() {
  show_header

  case "$1" in
    ""|"--packages")
      if [[ "$2" == "--all" ]]; then
        list_all_packages
      else
        list_packages
      fi
      ;;
    "--services")
      list_services
      ;;
    "--help"|*)
      echo -e "${CYBER_YELLOW}${BOLD}USAGE:${RESET}"
      echo -e "  ${CYBER_CYAN}list [OPTION]${NC}"
      echo -e "\n${CYBER_YELLOW}${BOLD}OPTIONS:${RESET}"
      echo -e "  ${CYBER_GREEN}--packages${NC}    List installed packages (default)"
      echo -e "  ${CYBER_GREEN}--services${NC}    List running services"
      echo -e "  ${CYBER_GREEN}--all${NC}        Show complete lists"
      echo -e "\n${CYBER_YELLOW}${BOLD}EXAMPLES:${RESET}"
      echo -e "  ${CYBER_CYAN}list --packages --all"
      echo -e "  ${CYBER_CYAN}list --services${NC}"
      ;;
  esac
}

run_list "$@"
