#!/bin/bash

# Carrega configurações e cores
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/docker/servers.sh"


# ======================
# HANDLER DE COMANDOS
# ======================

case "$1" in
    up|start)
        if [ -n "$2" ]; then
            start_servers "$2"
        else
            start_servers
        fi
        ;;
    down|stop)
        if [ -n "$2" ]; then
            stop_servers "$2"
        else
            stop_servers
        fi
        ;;
    status)
        if [ -n "$2" ]; then
            server_status "$2"
        else
            server_status
        fi
        ;;
    setup|init)
        generate_docker_compose
        ;;
    *)
        echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
        echo -e "${CYBER_BLUE}╭─────────────────────────────────────────────╮"
        echo -e "│ ${CYBER_YELLOW}BYTEBABE SERVER MANAGEMENT${RESET}                   "
        echo -e "│                                                   "
        echo -e "│ ${CYBER_GREEN}Uso:${RESET}                                       "
        echo -e "│ ${CYBER_GREEN}bytebabe servers up${RESET}     - Inicia servidores"
        echo -e "│ ${CYBER_GREEN}bytebabe servers down${RESET}   - Para servidores  "
        echo -e "│ ${CYBER_GREEN}bytebabe servers status${RESET} - Mostra status    "
        echo -e "│ ${CYBER_GREEN}bytebabe servers setup${RESET}  - Configuração     "
        echo -e "╰─────────────────────────────────────────────╯${RESET}"
        echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
        exit 1
        ;;
esac
