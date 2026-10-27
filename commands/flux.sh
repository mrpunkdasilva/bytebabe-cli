#!/bin/bash

# Set BASE_DIR if not already set (for direct execution)
if [ -z "$BASE_DIR" ]; then
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"
source "${BASE_DIR}/lib/flux/engine.sh"
source "${BASE_DIR}/lib/flux/request.sh"
source "${BASE_DIR}/lib/flux/verbs/get/main.sh"
source "${BASE_DIR}/lib/flux/verbs/post/main.sh"
source "${BASE_DIR}/lib/flux/verbs/put/main.sh"
source "${BASE_DIR}/lib/flux/verbs/delete/main.sh"

main() {
    local verb="${1:-}"

    if [[ $# -gt 0 ]]; then
        shift
    fi

    case "$verb" in
        ""|help|-h|--help)
            show_flux_help
            return 0
            ;;
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
            local server_script="${BASE_DIR}/commands/json-server.sh"
            if [[ ! -x "$server_script" ]]; then
                echo -e "${CYBER_YELLOW}[i] Corrigindo permissões do script json-server.sh...${RESET}"
                if ! chmod +x "$server_script"; then
                    echo -e "${CYBER_RED}[✗] Falha ao definir permissões. Tente manualmente:${RESET}"
                    echo -e "${CYBER_CYAN}    chmod +x $server_script${RESET}"
                    return 1
                fi
                echo -e "${CYBER_GREEN}[✓] Permissões corrigidas${RESET}"
            fi

            "$server_script" "$@"
            ;;
        *)
            show_flux_help
            return 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
