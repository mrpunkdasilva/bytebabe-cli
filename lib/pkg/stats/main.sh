#!/bin/bash

# Cores Cyberpunk
CYBER_PURPLE='\033[38;5;93m'
CYBER_GREEN='\033[38;5;118m'
CYBER_RED='\033[38;5;196m'
CYBER_BLUE='\033[38;5;45m'
CYBER_YELLOW='\033[38;5;227m'
NC='\033[0m'

# Efeitos
BOLD='\033[1m'
FLASH='\033[5m'
RESET='\033[0m'

# ASCII Art Header
show_header() {
  clear
  echo -e "${CYBER_PURPLE}"
  echo -e " █▀█ █▀▀ █▀ ▀█▀ █▀█ █▀█ ▀█▀ █▀▀ █▀▀ ▀█▀"
  echo -e " █▄█ ██▄ ▄█ ░█░ █▄█ █▀▄ ░█░ ██▄ ██▄ ░█░"
  echo -e "${CYBER_BLUE}"
  echo -e "╔════════════════════════════════════════╗"
  echo -e "║   ${CYBER_PURPLE}⚡ ${CYBER_YELLOW}SYSTEM VITALS v3.0 ${CYBER_BLUE}⚡   ║"
  echo -e "╚════════════════════════════════════════╝${NC}"
  echo
}

# Barra de progresso cyberpunk
progress_bar() {
  local percent=$1
  local color=$2
  local width=30
  local filled=$(($percent * $width / 100))
  local empty=$(($width - $filled))

  printf "${color}["
  printf "%${filled}s" | tr ' ' '■'
  printf "%${empty}s" | tr ' ' ' '
  printf "]${NC} %3d%%\n" "$percent"
}

# Mostra uso de CPU
show_cpu_stats() {
  local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
  local cpu_temp=$(($(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n1) / 1000))

  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_YELLOW}🧠 CPU STATS${NC}"
  echo -e "  ${CYBER_BLUE}Usage:${NC} $(progress_bar $cpu_usage $CYBER_GREEN)"

  if [ -n "$cpu_temp" ]; then
    if [ "$cpu_temp" -gt 70 ]; then
      echo -e "  ${CYBER_BLUE}Temp:${NC} ${CYBER_RED}${cpu_temp}°C${NC} ${CYBER_RED}⚠ HOT! ⚠${NC}"
    elif [ "$cpu_temp" -gt 50 ]; then
      echo -e "  ${CYBER_BLUE}Temp:${NC} ${CYBER_YELLOW}${cpu_temp}°C${NC}"
    else
      echo -e "  ${CYBER_BLUE}Temp:${NC} ${CYBER_GREEN}${cpu_temp}°C${NC}"
    fi
  fi

  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Mostra uso de memória
show_mem_stats() {
  local mem_total=$(free -m | awk '/Mem:/ {print $2}')
  local mem_used=$(free -m | awk '/Mem:/ {print $3}')
  local mem_percent=$((mem_used * 100 / mem_total))
  local swap_total=$(free -m | awk '/Swap:/ {print $2}')
  local swap_used=$(free -m | awk '/Swap:/ {print $3}')

  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_YELLOW}💾 MEMORY STATS${NC}"
  echo -e "  ${CYBER_BLUE}RAM:${NC} $(progress_bar $mem_percent $CYBER_BLUE) ${CYBER_GREEN}${mem_used}MB${NC}/${CYBER_BLUE}${mem_total}MB${NC}"

  if [ "$swap_total" -gt 0 ]; then
    local swap_percent=$((swap_used * 100 / swap_total))
    echo -e "  ${CYBER_BLUE}SWAP:${NC} $(progress_bar $swap_percent $CYBER_PURPLE) ${CYBER_GREEN}${swap_used}MB${NC}/${CYBER_BLUE}${swap_total}MB${NC}"
  else
    echo -e "  ${CYBER_BLUE}SWAP:${NC} ${CYBER_YELLOW}Not configured${NC}"
  fi

  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Mostra uso de disco
show_disk_stats() {
  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_YELLOW}💽 DISK STATS${NC}"

  df -h | grep -v "tmpfs" | awk 'NR>1 {print $6 " " $5 " " $2 " " $3}' | while read -r mount usage total used; do
    local percent=${usage%\%}
    echo -e "  ${CYBER_BLUE}${mount}:${NC} $(progress_bar $percent $CYBER_YELLOW) ${CYBER_GREEN}${used}${NC}/${CYBER_BLUE}${total}${NC}"
  done

  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Mostra rede
show_network_stats() {
  local public_ip=$(curl -s ifconfig.me)
  local local_ip=$(hostname -I | awk '{print $1}')
  local rx_bytes=$(($(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | paste -sd '+')))
  local tx_bytes=$(($(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | paste -sd '+')))

  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_YELLOW}🌐 NETWORK STATS${NC}"
  echo -e "  ${CYBER_BLUE}Public IP:${NC} ${CYBER_GREEN}${public_ip}${NC}"
  echo -e "  ${CYBER_BLUE}Local IP:${NC} ${CYBER_GREEN}${local_ip}${NC}"
  echo -e "  ${CYBER_BLUE}Download:${NC} ${CYBER_GREEN}$((rx_bytes / 1024 / 1024)) MB${NC}"
  echo -e "  ${CYBER_BLUE}Upload:${NC} ${CYBER_GREEN}$((tx_bytes / 1024 / 1024)) MB${NC}"
  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Mostra uptime e carga
show_system_stats() {
  local uptime=$(uptime -p)
  local load=$(uptime | awk -F 'load average: ' '{print $2}')
  local users=$(who | wc -l)

  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_YELLOW}🖥️ SYSTEM STATS${NC}"
  echo -e "  ${CYBER_BLUE}Uptime:${NC} ${CYBER_GREEN}${uptime}${NC}"
  echo -e "  ${CYBER_BLUE}Load:${NC} ${CYBER_GREEN}${load}${NC}"
  echo -e "  ${CYBER_BLUE}Users:${NC} ${CYBER_GREEN}${users}${NC}"
  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Menu interativo
interactive_menu() {
  while true; do
    show_header
    echo -e "${CYBER_PURPLE}1) ${CYBER_GREEN}CPU Stats"
    echo -e "${CYBER_PURPLE}2) ${CYBER_BLUE}Memory Stats"
    echo -e "${CYBER_PURPLE}3) ${CYBER_YELLOW}Disk Stats"
    echo -e "${CYBER_PURPLE}4) ${CYBER_CYAN}Network Stats"
    echo -e "${CYBER_PURPLE}5) ${CYBER_GREEN}System Info"
    echo -e "${CYBER_PURPLE}6) ${CYBER_RED}Exit${NC}"
    echo -e "\n${CYBER_YELLOW}Select an option:${NC} "

    read -r choice
    case $choice in
      1) show_cpu_stats ;;
      2) show_mem_stats ;;
      3) show_disk_stats ;;
      4) show_network_stats ;;
      5) show_system_stats ;;
      6) exit 0 ;;
      *) echo -e "${CYBER_RED}Invalid option!${NC}" ;;
    esac

    read -p "$(echo -e "${CYBER_PURPLE}Press ENTER to continue...${NC}")" _
  done
}

# Mostra todas as estatísticas
show_all_stats() {
  show_header
  show_cpu_stats
  show_mem_stats
  show_disk_stats
  show_network_stats
  show_system_stats
}

# Função principal
run_stats() {
  if [ "$1" = "interactive" ]; then
    interactive_menu
  else
    show_all_stats
  fi
}

run_stats "$@"
