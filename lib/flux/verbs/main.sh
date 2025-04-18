#!/bin/bash

# Definição das cores
CYBER_RED='\033[1;31m'
CYBER_GREEN='\033[1;32m'
CYBER_BLUE='\033[1;34m'
RESET='\033[0m'

# Carrega todos os verbos HTTP
source "$BASE_DIR/lib/flux/verbs/get/main.sh"
source "$BASE_DIR/lib/flux/verbs/post/main.sh"
source "$BASE_DIR/lib/flux/verbs/put/main.sh"
source "$BASE_DIR/lib/flux/verbs/delete/main.sh"

# Função para executar o verbo correto
execute_verb() {
    local verb="$1"
    shift

    case "${verb,,}" in
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
        *)
            echo -e "${CYBER_RED}Error: Unknown verb '${verb}'${RESET}"
            show_flux_help
            return 1
            ;;
    esac
}