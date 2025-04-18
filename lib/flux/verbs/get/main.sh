#!/bin/bash

# Importa os módulos necessários
source "$BASE_DIR/lib/flux/display.sh"
source "$BASE_DIR/lib/flux/verbs/get/executor.sh"
source "$BASE_DIR/lib/flux/verbs/get/parser.sh"
source "$BASE_DIR/lib/flux/verbs/get/validator.sh"
source "$BASE_DIR/lib/flux/verbs/get/help.sh"

execute_get() {
    # Primeiro verifica se é pedido de help
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_get_help
        return 0
    fi

    # Verifica se tem URL
    local url="$1"
    if [[ -z "$url" ]]; then
        echo -e "${CYBER_RED}Error: URL is required${RESET}"
        show_get_help
        return 1
    fi
    shift

    if ! validate_url "$url"; then
        return 1
    fi

    local params
    if ! params=$(parse_get_args "$@"); then
        return 1
    fi

    perform_get_request "$url" "$params"
}