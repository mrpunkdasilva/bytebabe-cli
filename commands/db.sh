#!/bin/bash

# ======================
# DOCKER SERVER MANAGER - BYTEBABE EDITION
# ======================

# Carrega configurações e cores
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/database/db_services.sh"


# ======================
# HANDLER DE COMANDOS
# ======================

case "$1" in
    setup)
        db_setup
        ;;
    install)
        db_install "$2"
        ;;
    start|up)
        db_start "$2"
        ;;
    stop|down)
        db_stop "$2"
        ;;
    status)
        db_status "$2"
        ;;
    log)
        db_log "$2" "$3" "$4"
        ;;
    *)
        echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
        echo -e "${CYBER_BLUE}╭─────────────────────────────────────────────╮"
        echo -e "│ ${CYBER_YELLOW}BYTEBABE DATABASE MANAGEMENT${RESET}                 "
        echo -e "│                                                   "
        echo -e "│ ${CYBER_GREEN}Uso:${RESET}                                       "
        echo -e "│ ${CYBER_GREEN}bytebabe db setup${RESET}   - Configura bancos     "
        echo -e "│ ${CYBER_GREEN}bytebabe db install${RESET} - Adiciona um banco    "
        echo -e "│ ${CYBER_GREEN}bytebabe db start${RESET}   - Inicia os bancos     "
        echo -e "│ ${CYBER_GREEN}bytebabe db stop${RESET}    - Para bancos          "
        echo -e "│ ${CYBER_GREEN}bytebabe db status${RESET}  - Mostra status        "
        echo -e "╰─────────────────────────────────────────────╯${RESET}"
        exit 1
        ;;
esac