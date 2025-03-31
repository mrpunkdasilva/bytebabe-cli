#!/bin/bash

# Carrega paths absolutos
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Importa módulos
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/utils/headers.sh"


### █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
### █▓▒░ MAIN DISPATCHER ░▒▓█
### █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

case $1 in
  # 📦 PACKAGE MANAGEMENT
  upgrade|up)
    shift
    source "$BASE_DIR/lib/pkg/upgrade/main.sh"
    show_header_custom "SYSTEM ENHANCEMENT PROTOCOL" "🔄" "${CYBER_GREEN}"
    run_upgrade "$@"
    ;;

  install|in|i)
    shift
    source "$BASE_DIR/lib/pkg/install/main.sh"
    show_header_custom "CYBERWARE INSTALLATION" "⚡" "${CYBER_BLUE}"
    run_install "$@"
    ;;

  remove|rm)
    shift
    show_header_custom "LEGACY MODULE PURGE" "☠️" "${CYBER_RED}"
    run_remove "$@"
    ;;

  # 🛡️ SECURITY SUITE
  scan)
    shift
    show_header_custom "THREAT ASSESSMENT SCAN" "🔍" "${CYBER_YELLOW}"
    run_scan "$@"
    ;;

  # TODO: FALTA SÓ ESSE
  firewall|fw)
    shift
    show_header_custom "NETWORK FIREWALL" "🛡️" "${CYBER_PURPLE}"
    run_firewall "$@"
    ;;
  # TODO: FALTA SÓ ESSE
  quarantine|q)
    shift
    show_header_custom "MALWARE QUARANTINE" "☣️" "${CYBER_RED}"
    run_quarantine "$@"
    ;;

  # 🛠️ SYSTEM UTILITIES
  clean)
    shift
    source "$BASE_DIR/lib/pkg/clean/main.sh"
    ;;

  backup)
    shift
    source "$BASE_DIR/lib/pkg/backup/main.sh"
    ;;

  # 🌐 NETWORK MODULE
  network|net)
    shift
    source "$BASE_DIR/lib/pkg/network/main.sh"
    show_header_custom "NETWORK DIAGNOSTICS" "🌐" "${CYBER_BLUE}"
    run_network "$@"
    ;;
  # TODO: FALTA SÓ ESSE

  # 📜 LOG MODULE
  log)
    shift
    show_header_custom "SYSTEM LOGS" "📜" "${CYBER_YELLOW}"
    run_log "$@"
    ;;

  # ⚙️ SERVICE CONTROL
  service|svc)
    shift
    source "$BASE_DIR/lib/pkg/service/main.sh"
    ;;

  # ℹ️ SYSTEM INFO
  list|ls)
    shift
    source "$BASE_DIR/lib/pkg/list/main.sh"
    ;;
  # TODO: FALTA SÓ ESSE

  info)
    shift
    show_header_custom "PACKAGE SPECS" "🔎" "${CYBER_BLUE}"
    run_info "$@"
    ;;
  # TODO: FALTA SÓ ESSE

  stats)
    shift
    show_header_custom "SYSTEM VITALS" "📊" "${CYBER_PURPLE}"
    run_stats "$@"
    ;;

  # 🆘 HELP SYSTEM
  help|--help|-h)
    show_help
    ;;
  # TODO: FALTA SÓ ESSE

  # 🎮 EASTER EGG
  neo)
    shift
    show_header_custom "RED PILL ACTIVATED" "💊" "${CYBER_RED}"
    run_neo_mode
    ;;

  *)
    show_invalid_command_prime
    ;;
esac

exit 0