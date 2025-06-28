#!/bin/bash

# Set BASE_DIR if not already set (for direct execution)
if [ -z "$BASE_DIR" ]; then
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# Importa os módulos necessários
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"
source "${BASE_DIR}/lib/flux/display.sh"
source "${BASE_DIR}/lib/flux/ui.sh"
source "${BASE_DIR}/lib/flux/verbs/get/main.sh"
source "${BASE_DIR}/lib/flux/verbs/postFeature/main.sh"
source "${BASE_DIR}/lib/flux/verbs/put/main.sh"
source "${BASE_DIR}/lib/flux/verbs/delete/main.sh"
source "${BASE_DIR}/lib/flux/history.sh"  # Importa o módulo de histórico diretamente
source "${BASE_DIR}/lib/flux/request.sh"

# Cores
export CYBER_BLUE='\033[38;5;45m'
export CYBER_GREEN='\033[38;5;118m'
export CYBER_YELLOW='\033[38;5;227m'
export CYBER_RED='\033[38;5;196m'
export CYBER_PURPLE='\033[38;5;93m'
export CYBER_PINK='\033[38;5;198m'
export CYBER_CYAN='\033[38;5;51m'
export RESET='\033[0m'
export BOLD='\033[1m'

main() {
    local verb="$1"
    shift

    clear
    show_flux_header

    case "$verb" in
        "get")
            execute_get "$@"
            ;;
        "post")
            execute_post "$@"
            ;;
        "put")
            execute_put "$@"
            ;;
        "delete")
            execute_delete "$@"
            ;;
        "history")
            show_history_menu
            ;;
        "server")
            # Verifica se o script json-server.sh é executável
            local server_script="${BASE_DIR}/commands/json-server.sh"
            if [ ! -x "$server_script" ]; then
                echo -e "${CYBER_YELLOW}[i] Corrigindo permissões do script json-server.sh...${RESET}"
                chmod +x "$server_script"
                if [ $? -ne 0 ]; then
                    echo -e "${CYBER_RED}[✗] Falha ao definir permissões. Tente manualmente:${RESET}"
                    echo -e "${CYBER_CYAN}    chmod +x $server_script${RESET}"
                    exit 1
                fi
                echo -e "${CYBER_GREEN}[✓] Permissões corrigidas${RESET}"
            fi
            
            # Inicia o servidor JSON
            "$server_script" "$@"
            ;;
        *)
            show_flux_help
            ;;
    esac
}


main "$@"