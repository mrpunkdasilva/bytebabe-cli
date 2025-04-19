#!/bin/bash

# Importa os módulos necessários usando caminho absoluto
source "${BASE_DIR}/lib/flux/verbs/delete/executor.sh"
source "${BASE_DIR}/lib/flux/verbs/delete/parser.sh"
source "${BASE_DIR}/lib/flux/verbs/delete/validator.sh"
source "${BASE_DIR}/lib/flux/verbs/delete/help.sh"

execute_delete() {
    local url="$1"
    shift

    # Debug: mostrar argumentos recebidos
    echo "DEBUG: URL recebida: '$url'"
    echo "DEBUG: Argumentos restantes: '$@'"
    echo "DEBUG: BASE_DIR: ${BASE_DIR}"
    
    # Verifica se é pedido de ajuda
    if [[ -z "$url" ]]; then
        echo "DEBUG: URL está vazia"
        show_delete_help
        return 0
    fi

    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "DEBUG: Pedido de ajuda detectado"
        show_delete_help
        return 0
    fi

    # Valida URL
    if ! validate_url "$url"; then
        return 1
    fi

    # Parse argumentos
    local parsed_args
    if ! parsed_args=$(parse_delete_args "$@"); then
        return 1
    fi

    # Separa parâmetros e estilo de loading
    IFS='|' read -r params loading_style <<< "$parsed_args"

    # Valida argumentos específicos do DELETE
    if ! validate_delete_args "$params"; then
        return 1
    fi

    # Executa a requisição
    perform_delete_request "$url" "$params" "$loading_style"
}