#!/bin/bash

# Cores Cyberpunk
CYBER_YELLOW='\033[38;5;227m'
CYBER_RED='\033[38;5;196m'
CYBER_GREEN='\033[38;5;118m'
CYBER_BLUE='\033[38;5;45m'
CYBER_PURPLE='\033[38;5;93m'
NC='\033[0m'

# Efeitos
BOLD='\033[1m'
FLASH='\033[5m'
RESET='\033[0m'

# ASCII Art Header
show_header() {
  clear
  echo -e "${CYBER_YELLOW}"
  echo -e " █▀█ █▀█ █▀▀ ▀█▀ █▀▀ █▀█ ▄▀█ █▀▀ █▀▀"
  echo -e " █▀▄ █▄█ █▄▄ ░█░ ██▄ █▀▄ █▀█ █▄▄ ██▄"
  echo -e "${CYBER_PURPLE}"
  echo -e "╔════════════════════════════════════════╗"
  echo -e "║          ${CYBER_YELLOW}⚡ ${CYBER_BLUE}LOG SCANNER v4.0 ${CYBER_PURPLE}⚡   "
  echo -e "╚════════════════════════════════════════╝${NC}"
  echo
}

# Mostra logs do sistema
show_system_logs() {
  echo -e "\n${CYBER_YELLOW}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_BLUE}📜 SYSTEM LOGS (last 20 entries):${NC}\n"

  sudo journalctl -n 20 --no-pager | \
  awk -v yellow="$CYBER_YELLOW" -v red="$CYBER_RED" -v green="$CYBER_GREEN" -v nc="$NC" \
  '{
    if ($0 ~ /error|fail|crash/)
      print red $0 nc;
    else if ($0 ~ /warning/)
      print yellow $0 nc;
    else if ($0 ~ /start|stop|success/)
      print green $0 nc;
    else
      print $0;
  }'

  echo -e "${CYBER_YELLOW}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Monitora logs em tempo real
monitor_logs() {
  echo -e "\n${CYBER_YELLOW}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_RED}${FLASH}⚠ LIVE LOG MONITORING (Ctrl+C to stop) ⚠${NC}${RESET}"
  echo -e "${CYBER_YELLOW}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}\n"

  sudo tail -f /var/log/syslog | \
  awk -v yellow="$CYBER_YELLOW" -v red="$CYBER_RED" -v green="$CYBER_GREEN" -v nc="$NC" \
  '{
    if ($0 ~ /error|fail|crash/)
      print red $0 nc;
    else if ($0 ~ /warning/)
      print yellow $0 nc;
    else if ($0 ~ /start|stop|success/)
      print green $0 nc;
    else
      print $0;
  }'
}

# Mostra logs de um serviço específico
show_service_logs() {
  local service=$1
  local lines=${2:-15}

  echo -e "\n${CYBER_YELLOW}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_BLUE}🛠️ LOGS FOR SERVICE: ${CYBER_PURPLE}$service ${CYBER_BLUE}(last $lines lines)${NC}\n"

  if ! systemctl is-active "$service" &>/dev/null; then
    echo -e "${CYBER_RED}Service $service is not active!${NC}"
    return 1
  fi

  sudo journalctl -u "$service" -n "$lines" --no-pager | \
  awk -v yellow="$CYBER_YELLOW" -v red="$CYBER_RED" -v green="$CYBER_GREEN" -v nc="$NC" \
  '{
    if ($0 ~ /error|fail|crash/)
      print red $0 nc;
    else if ($0 ~ /warning/)
      print yellow $0 nc;
    else if ($0 ~ /start|stop|success/)
      print green $0 nc;
    else
      print $0;
  }'

  echo -e "${CYBER_YELLOW}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Limpa logs do sistema
clear_logs() {
  echo -e "\n${CYBER_YELLOW}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_RED}${FLASH}⚠ WARNING: THIS WILL CLEAR SYSTEM LOGS! ⚠${NC}${RESET}"

  read -p "$(echo -e "${CYBER_YELLOW}Are you sure? (y/N): ${NC}")" confirm
  if [[ $confirm =~ ^[Yy]$ ]]; then
    echo -e "\n${CYBER_BLUE}🧹 CLEARING SYSTEM LOGS...${NC}"
    sudo journalctl --vacuum-size=100M
    echo -e "${CYBER_GREEN}✅ LOGS CLEARED SUCCESSFULLY!${NC}"
  else
    echo -e "\n${CYBER_BLUE}🚫 OPERATION CANCELLED!${NC}"
  fi

  echo -e "${CYBER_YELLOW}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Menu de ajuda
show_help() {
  echo -e "\n${CYBER_YELLOW}${BOLD}USAGE:${RESET}"
  echo -e "  ${CYBER_GREEN}log system${NC}       - Show system logs"
  echo -e "  ${CYBER_GREEN}log monitor${NC}     - Monitor logs in real-time"
  echo -e "  ${CYBER_GREEN}log service <name>${NC} - Show logs for specific service"
  echo -e "  ${CYBER_GREEN}log clear${NC}       - Clear system logs"
  echo -e "\n${CYBER_YELLOW}${BOLD}EXAMPLES:${RESET}"
  echo -e "  ${CYBER_BLUE}log service nginx"
  echo -e "  ${CYBER_BLUE}log monitor"
  echo -e "  ${CYBER_BLUE}log clear${NC}"
}

# Função principal
run_log() {
  show_header

  case "$1" in
    "system")
      show_system_logs
      ;;
    "monitor")
      monitor_logs
      ;;
    "service")
      if [ -z "$2" ]; then
        echo -e "${CYBER_RED}Error: Please specify a service name${NC}"
        show_help
      else
        show_service_logs "$2" "$3"
      fi
      ;;
    "clear")
      clear_logs
      ;;
    ""|"--help"|*)
      show_help
      ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_log "$@"
fi
