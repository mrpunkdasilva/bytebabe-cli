#!/bin/bash

# Cores Cyberpunk
CYBER_RED='\033[38;5;196m'
CYBER_GREEN='\033[38;5;118m'
CYBER_BLUE='\033[38;5;45m'
CYBER_YELLOW='\033[38;5;227m'
CYBER_PURPLE='\033[38;5;93m'
NC='\033[0m'

_sysinfo_divider() {
  echo -e "${CYBER_PURPLE}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

_sysinfo_section() {
  echo -e "\n${CYBER_YELLOW}$1${NC}"
}

_sysinfo_row() {
  printf "  ${CYBER_BLUE}%-12s${NC} %s\n" "$1" "$2"
}

_sysinfo_bar() {
  local label=$1 pct=${2:-0} width=20 filled i bar=""
  (( pct > 100 )) && pct=100
  filled=$(( pct * width / 100 ))
  for (( i = 0; i < width; i++ )); do
    if (( i < filled )); then bar+="█"; else bar+="░"; fi
  done
  printf "  ${CYBER_BLUE}%-12s${NC} ${CYBER_PURPLE}[${CYBER_GREEN}%s${CYBER_PURPLE}]${NC} %3s%%\n" "$label" "$bar" "$pct"
}

_sysinfo_header() {
  echo -e "${CYBER_RED} █▀ █▄█ █▀ ▀█▀ █▀▀ █▀▄▀█   █ █▄░█ █▀▀ █▀█"
  echo -e " ▄█ ░█░ ▄█ ░█░ ██▄ █░▀░█   █ █░▀█ █▀░ █▄█${NC}"
  echo -e "${CYBER_PURPLE}▓▒░▒▓▓▒░▒▓▓▒░▒▓▓▒░▒▓▓▒░▒▓▓▒░▒▓▓▒░▒▓▓▒░▒▓▓▒░▒▓${NC}"
}

show_os_info() {
  local os_name kernel arch host uptime_text
  os_name=$(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-desconhecido}")
  kernel=$(uname -r)
  arch=$(uname -m)
  host=$(uname -n 2>/dev/null || echo "desconhecido")
  uptime_text=$(uptime -p 2>/dev/null || echo "desconhecido")

  _sysinfo_section "🖥️  SISTEMA"
  _sysinfo_row "Host:" "$host"
  _sysinfo_row "SO:" "$os_name"
  _sysinfo_row "Kernel:" "$kernel"
  _sysinfo_row "Arquitetura:" "$arch"
  _sysinfo_row "Uptime:" "$uptime_text"
}

show_hardware_info() {
  local cpu_model cores ram_total ram_mb ram_used_mb ram_pct gpu

  cpu_model=$(awk -F': ' '/model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null)
  cores=$(nproc 2>/dev/null || echo "desconhecido")
  ram_total=$(free -h 2>/dev/null | awk '/Mem:/ {print $2}')
  read -r ram_mb ram_used_mb <<< "$(free -m 2>/dev/null | awk '/Mem:/ {print $2, $3}')"
  ram_pct=$(( ${ram_mb:-0} > 0 ? ram_used_mb * 100 / ram_mb : 0 ))

  _sysinfo_section "🧠 HARDWARE"
  _sysinfo_row "CPU:" "${cpu_model:-desconhecida}"
  _sysinfo_row "Núcleos:" "$cores"
  _sysinfo_row "RAM total:" "${ram_total:-desconhecida}"
  _sysinfo_bar "RAM uso:" "$ram_pct"

  if command -v lspci &>/dev/null; then
    gpu=$(lspci 2>/dev/null | grep -iE 'vga|3d|display' | sed 's/^[^:]*: //' | head -n1)
    _sysinfo_row "GPU:" "${gpu:-não detectada}"
  fi
}

show_storage_info() {
  local root_line root_pct

  root_line=$(df -h / 2>/dev/null | awk 'NR==2 {print $2 " total, " $3 " usados, " $4 " livres (" $5 " em uso)"}')
  root_pct=$(df / --output=pcent 2>/dev/null | tail -n1 | tr -dc '0-9')

  _sysinfo_section "💽 ARMAZENAMENTO"
  _sysinfo_row "Raiz (/):" "${root_line:-desconhecido}"
  _sysinfo_bar "Disco uso:" "${root_pct:-0}"
}

show_environment_info() {
  local user_name shell_name

  user_name=$(whoami 2>/dev/null || echo "desconhecido")
  shell_name=$(basename "${SHELL:-desconhecido}")

  _sysinfo_section "👤 AMBIENTE"
  _sysinfo_row "Usuário:" "$user_name"
  _sysinfo_row "Shell:" "$shell_name"
  _sysinfo_row "Desktop:" "${XDG_CURRENT_DESKTOP:-não detectado}"
  _sysinfo_row "Terminal:" "${TERM:-desconhecido}"
}

show_network_info() {
  local local_ip

  local_ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1)

  _sysinfo_section "🌐 REDE"
  _sysinfo_row "IP local:" "${local_ip:-não detectado}"
}

show_sysinfo_help() {
  echo -e "${CYBER_BLUE}USO:${NC} prime sysinfo"
  echo -e "Mostra informações gerais do sistema: SO, hardware, armazenamento, ambiente e rede."
}

run_sysinfo() {
  case "$1" in
    --help|-h)
      show_sysinfo_help
      return 0
      ;;
  esac

  _sysinfo_header
  show_os_info
  show_hardware_info
  show_storage_info
  show_environment_info
  show_network_info
  echo
  _sysinfo_divider
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  run_sysinfo "$@"
fi
