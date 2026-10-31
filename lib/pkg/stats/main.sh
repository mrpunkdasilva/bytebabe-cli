#!/bin/bash

# Cores Cyberpunk
CYBER_PURPLE='\033[38;5;93m'
CYBER_GREEN='\033[38;5;118m'
CYBER_RED='\033[38;5;196m'
CYBER_BLUE='\033[38;5;45m'
CYBER_YELLOW='\033[38;5;227m'
CYBER_CYAN='\033[38;5;51m'
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
  echo -e "║        ${CYBER_PURPLE}⚡ ${CYBER_YELLOW}SYSTEM VITALS v3.0 ${CYBER_PURPLE}⚡${CYBER_BLUE}        ║"
  echo -e "╚════════════════════════════════════════╝${NC}"
  echo
}

# Barra de progresso cyberpunk
STATS_DIVIDER="▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓"

_stats_divider() {
  echo -e "${CYBER_PURPLE}${BOLD}${STATS_DIVIDER}${NC}"
}

_stats_section() {
  echo
  _stats_divider
  echo -e "${CYBER_YELLOW}$1${NC}"
}

_stats_label() {
  # printf conta bytes; padding manual mantém alinhados rótulos acentuados
  local pad=$(( 11 - ${#1} ))
  (( pad < 0 )) && pad=0
  printf "  ${CYBER_BLUE}%s%*s${NC} " "$1" "$pad" ""
}

_stats_row() {
  _stats_label "$1"
  printf "${CYBER_GREEN}%s${NC}\n" "$2"
}

progress_bar() {
  local percent=${1%%.*}
  local color=$2
  local width=20 i bar=""
  [[ "$percent" =~ ^[0-9]+$ ]] || percent=0
  (( percent > 100 )) && percent=100
  local filled=$(( percent * width / 100 ))

  for (( i = 0; i < width; i++ )); do
    if (( i < filled )); then bar+="█"; else bar+="░"; fi
  done

  printf "${CYBER_PURPLE}[${color}%s${CYBER_PURPLE}]${NC} %3d%%" "$bar" "$percent"
}

# Uso de CPU via /proc/stat (duas amostras)
_cpu_usage() {
  local _ user nice system idle iowait irq softirq steal
  local total1 idle1 total2 idle2
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  total1=$(( user + nice + system + idle + iowait + irq + softirq + steal ))
  idle1=$(( idle + iowait ))
  sleep 0.5
  read -r _ user nice system idle iowait irq softirq steal _ < /proc/stat
  total2=$(( user + nice + system + idle + iowait + irq + softirq + steal ))
  idle2=$(( idle + iowait ))
  (( total2 > total1 )) || { echo 0; return; }
  echo $(( 100 * ((total2 - total1) - (idle2 - idle1)) / (total2 - total1) ))
}

# Mostra uso de CPU
show_cpu_stats() {
  local cpu_usage cpu_model cpu_freq load cores
  cpu_usage=$(_cpu_usage 2>/dev/null)
  cpu_model=$(awk -F: '/model name/ {sub(/^ +/, "", $2); print $2; exit}' /proc/cpuinfo 2>/dev/null)
  cpu_freq=$(awk -F: '/cpu MHz/ {s += $2; n++} END {if (n) printf "%.0f MHz", s / n}' /proc/cpuinfo 2>/dev/null)
  cores=$(nproc 2>/dev/null)
  read -r load _ < /proc/loadavg
  local cpu_temp raw_temp
  raw_temp=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n1)
  [[ "$raw_temp" =~ ^[0-9]+$ ]] && cpu_temp=$((raw_temp / 1000))

  _stats_section "🧠 CPU STATS"
  _stats_label "Uso:"; echo -e "$(progress_bar "$cpu_usage" "$CYBER_GREEN")"
  _stats_row "Modelo:" "${cpu_model:-desconhecido}"
  _stats_row "Núcleos:" "${cores:-?}"
  [ -n "$cpu_freq" ] && _stats_row "Frequência:" "$cpu_freq"
  _stats_row "Load (1m):" "${load:-?}"

  if [ -n "$cpu_temp" ]; then
    if [ "$cpu_temp" -gt 70 ]; then
      _stats_label "Temp:"; echo -e "${CYBER_RED}${cpu_temp}°C ⚠ HOT! ⚠${NC}"
    elif [ "$cpu_temp" -gt 50 ]; then
      _stats_label "Temp:"; echo -e "${CYBER_YELLOW}${cpu_temp}°C${NC}"
    else
      _stats_label "Temp:"; echo -e "${CYBER_GREEN}${cpu_temp}°C${NC}"
    fi
  fi
}

# Mostra uso de memória
show_mem_stats() {
  local mem_total mem_used mem_cache mem_avail swap_total swap_used
  read -r mem_total mem_used mem_cache mem_avail <<< "$(free -m | awk '/Mem:/ {print $2, $3, $6, $7}')"
  read -r swap_total swap_used <<< "$(free -m | awk '/Swap:/ {print $2, $3}')"
  local mem_percent=$(( ${mem_total:-0} > 0 ? mem_used * 100 / mem_total : 0 ))

  _stats_section "💾 MEMORY STATS"
  printf "  ${CYBER_BLUE}%-11s${NC} %s ${CYBER_GREEN}%sMB${NC}/${CYBER_BLUE}%sMB${NC}\n" "RAM:" "$(progress_bar "$mem_percent" "$CYBER_BLUE")" "$mem_used" "$mem_total"

  if [ "${swap_total:-0}" -gt 0 ]; then
    local swap_percent=$((swap_used * 100 / swap_total))
    printf "  ${CYBER_BLUE}%-11s${NC} %s ${CYBER_GREEN}%sMB${NC}/${CYBER_BLUE}%sMB${NC}\n" "SWAP:" "$(progress_bar "$swap_percent" "$CYBER_PURPLE")" "$swap_used" "$swap_total"
  else
    _stats_row "SWAP:" "não configurado"
  fi
  _stats_row "Disponível:" "${mem_avail:-?}MB"
  _stats_row "Cache:" "${mem_cache:-?}MB"
}

# Mostra uso de disco
show_disk_stats() {
  _stats_section "💽 DISK STATS"

  # Ignora montagens internas do WSL/systemd e repete cada dispositivo uma só vez
  df -h -x tmpfs -x devtmpfs -x squashfs -x overlay --output=source,target,pcent,size,used 2>/dev/null \
    | awk 'NR>1 && $2 !~ /^\/(usr\/lib|run|init|dev|mnt\/wsl)/ && !seen[$1]++ {print $2, $3, $4, $5}' \
    | while read -r mount usage total used; do
    local percent=${usage%\%}
    printf "  ${CYBER_BLUE}%-11s${NC} %s ${CYBER_GREEN}%s${NC}/${CYBER_BLUE}%s${NC}\n" "$mount" "$(progress_bar "$percent" "$CYBER_YELLOW")" "$used" "$total"
  done
}

# Mostra rede
show_network_stats() {
  local public_ip=$(curl -s --max-time 5 ifconfig.me)
  local iface local_ip
  iface=$(ip -4 route show default 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "dev") {print $(i + 1); exit}}')
  if [ -n "$iface" ]; then
    local_ip=$(ip -4 -o addr show dev "$iface" 2>/dev/null | awk '{split($4, a, "/"); print a[1]; exit}')
  fi
  [ -n "$local_ip" ] || local_ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '{split($4, a, "/"); print a[1]; exit}')
  local rx_bytes=$(($(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | paste -sd '+')))
  local tx_bytes=$(($(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | paste -sd '+')))

  _stats_section "🌐 NETWORK STATS"
  _stats_row "Interface:" "${iface:-não detectada}"
  _stats_row "IP local:" "${local_ip:-não detectado}"
  _stats_row "IP público:" "${public_ip:-não detectado}"
  _stats_row "Download:" "$((rx_bytes / 1024 / 1024)) MB"
  _stats_row "Upload:" "$((tx_bytes / 1024 / 1024)) MB"
}

# Mostra uptime e carga
show_system_stats() {
  local uptime=$(uptime -p)
  local load=$(uptime | awk -F 'load average: ' '{print $2}')
  local users=$(who | wc -l)
  local procs=$(ps -e --no-headers 2>/dev/null | wc -l)
  local boot=$(uptime -s 2>/dev/null)

  _stats_section "🖥️  SYSTEM STATS"
  _stats_row "Uptime:" "$uptime"
  _stats_row "Boot:" "${boot:-desconhecido}"
  _stats_row "Load:" "$load"
  _stats_row "Usuários:" "$users"
  _stats_row "Processos:" "$procs"
}

# Processos que mais consomem CPU
show_top_processes() {
  _stats_section "⚙️  TOP PROCESSOS (CPU)"
  printf "  ${CYBER_BLUE}%-8s %-20s %6s %6s${NC}\n" "PID" "COMANDO" "%CPU" "%MEM"
  ps -eo pid=,%cpu=,%mem=,args= --sort=-%cpu 2>/dev/null | head -n 5 \
    | while read -r pid cpu mem cmd _; do
      printf "  ${CYBER_GREEN}%-8s %-20.20s %6s %6s${NC}\n" "$pid" "${cmd##*/}" "$cpu" "$mem"
    done
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
    echo -e "${CYBER_PURPLE}6) ${CYBER_YELLOW}Top Processes"
    echo -e "${CYBER_PURPLE}7) ${CYBER_RED}Exit${NC}"
    echo -e "\n${CYBER_YELLOW}Select an option:${NC} "

    read -r choice
    case $choice in
      1) show_cpu_stats ;;
      2) show_mem_stats ;;
      3) show_disk_stats ;;
      4) show_network_stats ;;
      5) show_system_stats ;;
      6) show_top_processes ;;
      7) return 0 ;;
      *) echo -e "${CYBER_RED}Invalid option!${NC}" ;;
    esac
    _stats_divider

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
  show_top_processes
  _stats_divider
}

# Função principal
run_stats() {
  if [ "$1" = "interactive" ]; then
    interactive_menu
  else
    show_all_stats
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_stats "$@"
fi
