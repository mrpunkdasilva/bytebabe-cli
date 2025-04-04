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

  remove|rm|purge)
    shift
    source "$BASE_DIR/lib/pkg/remove/main.sh"
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
      show_remove_help
    else
      if [[ "$0" == *"purge"* ]]; then
        run_remove --purge "$@"
      else
        run_remove "$@"
      fi
    fi
    ;;

  # 🛡️ SECURITY SUITE
  scan)
    shift
    source "$BASE_DIR/lib/pkg/scan/main.sh"
    run_scan "$@"
    ;;

  firewall|fw)
    shift
    source "$BASE_DIR/lib/pkg/firewall/main.sh"
    show_header_custom "     NETWORK FIREWALL" "🛡️" "${CYBER_PURPLE}"
    run_firewall "$@"
    ;;

  # TODO: FALTA SÓ ESSE
  quarantine|q)
    shift
    source "$BASE_DIR/lib/pkg/quarantine/main.sh"
    show_header_custom "MALWARE QUARANTINE" "☣️" "${CYBER_RED}"
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
    run_network "$@"
    ;;

  # 📜 LOG MODULE
  log)
    shift
    source "$BASE_DIR/lib/pkg/log/main.sh"
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

  info)
    shift
    source "$BASE_DIR/lib/pkg/info/main.sh"
    ;;

  stats)
    shift
    source "$BASE_DIR/lib/pkg/stats/main.sh"
    show_header_custom "SYSTEM VITALS" "📊" "${CYBER_PURPLE}"
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