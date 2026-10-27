#!/bin/bash

# Cores Cyberpunk
CYBER_GREEN='\033[38;5;118m'
CYBER_RED='\033[38;5;196m'
CYBER_PINK='\033[38;5;199m'
CYBER_BLUE='\033[38;5;45m'
CYBER_YELLOW='\033[38;5;227m'
CYBER_PURPLE='\033[38;5;93m'
NC='\033[0m'

# ASCII Art Header
show_header() {
  clear
  echo -e "${CYBER_PINK}"
  echo -e " █▀▀ ▄▀█ █▀▄▀█ █▀▀ █▀█ ▄▀█ █▀▀ █▀▀ ▀█▀"
  echo -e " █▄▄ █▀█ █░▀░█ ██▄ █▀▄ █▀█ █▄▄ ██▄ ░█░"
  echo -e "${CYBER_BLUE}"
  echo -e "╔════════════════════════════════════════╗"
  echo -e "║   ${CYBER_PINK}⚡ ${CYBER_YELLOW}SERVICE HACKER v2.0 ${CYBER_BLUE}⚡   "
  echo -e "╚════════════════════════════════════════╝${NC}"
  echo
}

# Lista serviços com estilo cyberpunk
list_services() {
  echo -e "\n${CYBER_PURPLE}▓▓▓▓▓▓▓▓▓▓▓▓▓ ${CYBER_BLUE}SYSTEM SERVICES ${CYBER_PURPLE}▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"

  sudo systemctl list-units --type=service --all --no-pager | \
  grep -E 'service.*loaded' | \
  while read -r line; do
    service=$(echo "$line" | awk '{print $1}')
    status=$(echo "$line" | awk '{print $4}')

    if [ "$status" = "active" ]; then
      echo -e "${CYBER_GREEN}◉ ${service} ${CYBER_BLUE}>>> ${CYBER_GREEN}ALIVE${NC}"
    else
      echo -e "${CYBER_RED}◉ ${service} ${CYBER_BLUE}>>> ${CYBER_RED}DEAD${NC}"
    fi
  done | head -n 20

  echo -e "\n${CYBER_YELLOW}HACKER TIP: Use 'systemctl list-units --type=service' for full list${NC}"
}

# Menu cyberpunk
show_menu() {
  show_header
  echo -e "${CYBER_PINK}┌────────────────────────────────────────────┐"
  echo -e "│ ${CYBER_BLUE}1) ${CYBER_GREEN}SCAN SYSTEM SERVICES ${CYBER_PINK}               "
  echo -e "│ ${CYBER_BLUE}2) ${CYBER_GREEN}ACTIVATE SERVICE ${CYBER_PINK}                   "
  echo -e "│ ${CYBER_BLUE}3) ${CYBER_RED}TERMINATE SERVICE ${CYBER_PINK}                    "
  echo -e "│ ${CYBER_BLUE}4) ${CYBER_YELLOW}REBOOT SERVICE ${CYBER_PINK}                    "
  echo -e "│ ${CYBER_BLUE}5) ${CYBER_BLUE}SERVICE DIAGNOSTICS ${CYBER_PINK}                 "
  echo -e "│ ${CYBER_BLUE}6) ${CYBER_RED}EXIT TO MATRIX ${CYBER_PINK}                       "
  echo -e "└────────────────────────────────────────────┘${NC}"
}

# Ações com mensagens cyberpunk
service_action() {
  local action=$1
  local service=$2

  case "$action" in
    start)
      echo -e "\n${CYBER_GREEN}⌛ INITIATING ${service} SEQUENCE...${NC}"
      sudo systemctl start "$service" && \
      echo -e "${CYBER_GREEN}✅ ${service} ACTIVATION SUCCESSFUL!${NC}" || \
      echo -e "${CYBER_RED}❌ ${service} ACTIVATION FAILED!${NC}"
      ;;
    stop)
      echo -e "\n${CYBER_RED}⌛ TERMINATING ${service} PROCESS...${NC}"
      sudo systemctl stop "$service" && \
      echo -e "${CYBER_GREEN}✅ ${service} TERMINATION SUCCESSFUL!${NC}" || \
      echo -e "${CYBER_RED}❌ ${service} TERMINATION FAILED!${NC}"
      ;;
    restart)
      echo -e "\n${CYBER_YELLOW}⌛ REBOOTING ${service} SYSTEM...${NC}"
      sudo systemctl restart "$service" && \
      echo -e "${CYBER_GREEN}✅ ${service} REBOOT COMPLETE!${NC}" || \
      echo -e "${CYBER_RED}❌ ${service} REBOOT FAILED!${NC}"
      ;;
    status)
      echo -e "\n${CYBER_BLUE}🔍 ${service} SYSTEM DIAGNOSTICS:${NC}"
      sudo systemctl status "$service" --no-pager -l
      ;;
  esac
}

# Modo interativo cyberpunk
interactive_mode() {
  while true; do
    show_menu
    read -p "$(echo -e "${CYBER_PINK}CHOOSE YOUR HACK [1-6]: ${NC}")" choice

    case $choice in
      1) list_services ;;
      2)
        read -p "$(echo -e "${CYBER_GREEN}ENTER SERVICE TO ACTIVATE: ${NC}")" service
        service_action "start" "$service"
        ;;
      3)
        read -p "$(echo -e "${CYBER_RED}ENTER SERVICE TO TERMINATE: ${NC}")" service
        service_action "stop" "$service"
        ;;
      4)
        read -p "$(echo -e "${CYBER_YELLOW}ENTER SERVICE TO REBOOT: ${NC}")" service
        service_action "restart" "$service"
        ;;
      5)
        read -p "$(echo -e "${CYBER_BLUE}ENTER SERVICE TO SCAN: ${NC}")" service
        service_action "status" "$service"
        ;;
      6)
        echo -e "\n${CYBER_PURPLE}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
        echo -e "${CYBER_RED}⚠ WARNING: EXITING THE SYSTEM... ⚠${NC}"
        echo -e "${CYBER_PURPLE}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
        sleep 1
        return 0
        ;;
      *)
        echo -e "\n${CYBER_RED}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
        echo -e " ${CYBER_YELLOW}⚠ INVALID OPTION! TRY AGAIN, HACKER! ⚠${NC}"
        echo -e "${CYBER_RED}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
        ;;
    esac

    read -p "$(echo -e "${CYBER_PINK}PRESS ENTER TO CONTINUE HACKING...${NC}")" _
  done
}

# Modo direto cyberpunk
direct_mode() {
  case "$1" in
    scan) list_services ;;
    activate)
      service_action "start" "$2"
      ;;
    terminate)
      service_action "stop" "$2"
      ;;
    reboot)
      service_action "restart" "$2"
      ;;
    diagnose)
      service_action "status" "$2"
      ;;
    *)
      echo -e "${CYBER_PINK}"
      echo -e "╔════════════════════════════════════════╗"
      echo -e "║ ${CYBER_RED}⚠ INVALID COMMAND STRUCTURE! ⚠ ${CYBER_PINK}"
      echo -e "╚════════════════════════════════════════╝${NC}"
      echo -e "\n${CYBER_BLUE}USAGE:${NC}"
      echo -e " ${CYBER_GREEN}$0 scan${NC}"
      echo -e " ${CYBER_GREEN}$0 activate|terminate|reboot|diagnose <service>${NC}"
      echo -e "\n${CYBER_YELLOW}EXAMPLE:${NC}"
      echo -e " ${CYBER_GREEN}$0 activate nginx${NC}"
      return 1
      ;;
  esac
}

# Main
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [ $# -eq 0 ]; then
    interactive_mode
  else
    direct_mode "$@"
  fi
fi