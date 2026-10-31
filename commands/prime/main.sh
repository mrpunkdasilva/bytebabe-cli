#!/bin/bash

# Importa módulos
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"
source "${BASE_DIR}/lib/utils/headers.sh"


### █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
### █▓▒░ MAIN DISPATCHER ░▒▓█
### █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

main() {
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

  quarantine|q)
    shift
    source "$BASE_DIR/lib/pkg/quarantine/main.sh"
    run_quarantine "$@"
    ;;

  # 🛠️ SYSTEM UTILITIES
  clean)
    shift
    source "$BASE_DIR/lib/pkg/clean/main.sh"
    show_header_custom "SYSTEM PURGE" "🧹" "${CYBER_BLUE}"
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
      show_clean_help
    else
      run_clean "$@"
    fi
    ;;

  backup)
    shift
    source "$BASE_DIR/lib/pkg/backup/main.sh"
    run_backup "$@"
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
    run_log "$@"
    ;;

  # ⚙️ SERVICE CONTROL
  service|svc)
    shift
    source "$BASE_DIR/lib/pkg/service/main.sh"
    if [[ $# -eq 0 ]]; then
      interactive_mode
    else
      direct_mode "$@"
    fi
    ;;

  # ℹ️ SYSTEM INFO
  list|ls)
    shift
    source "$BASE_DIR/lib/pkg/list/main.sh"
    run_list "$@"
    ;;

  info)
    shift
    source "$BASE_DIR/lib/pkg/info/main.sh"
    run_info "$@"
    ;;

  stats)
    shift
    source "$BASE_DIR/lib/pkg/stats/main.sh"
    show_header_custom "SYSTEM VITALS" "📊" "${CYBER_PURPLE}"
    run_stats "$@"
    ;;

  sysinfo|sys)
    shift
    source "$BASE_DIR/lib/pkg/sysinfo/main.sh"
    run_sysinfo "$@"
    ;;

  # 🆘 HELP SYSTEM
  help|--help|-h)
    show_help
    ;;

  # 🎮 EASTER EGG
  neo)
    shift
    source "$BASE_DIR/lib/pkg/neo/main.sh"
    show_header_custom "RED PILL ACTIVATED" "💊" "${CYBER_RED}"
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
      show_neo_help
    else
      run_neo_mode "$@"
    fi
    ;;

  *)
    show_invalid_command_prime "$1"
    return 1
    ;;
esac

return 0
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
