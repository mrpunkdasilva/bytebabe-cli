#!/bin/bash

# Carrega os módulos necessários
source "$BASE_DIR/lib/flux/verbs/post/executor.sh"
source "$BASE_DIR/lib/flux/verbs/post/parser.sh"
source "$BASE_DIR/lib/flux/verbs/post/validator.sh"
source "$BASE_DIR/lib/flux/verbs/post/help.sh"

execute_post() {
    local url="$1"
    shift

    # Verifica se é pedido de ajuda
    if [[ "$1" == "--help" || "$1" == "-h" || -z "$1" ]]; then
        show_post_help
        return 0
    fi

    if ! validate_url "$url"; then
        return 1
    fi

    local parsed_args
    if ! parsed_args=$(parse_post_args "$@"); then
        return 1
    fi

    # Separa os parâmetros e o estilo de loading
    IFS='|' read -r params loading_style <<< "$parsed_args"

    perform_post_request "$url" "$params" "$loading_style"
}