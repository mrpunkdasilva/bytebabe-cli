#!/bin/bash

validate_url() {
    local url="$1"
    
    # Verificar se URL foi fornecida
    if [[ -z "$url" ]]; then
        echo -e "${CYBER_RED}Error: URL is required${RESET}"
        show_get_help
        return 1
    fi

    # Verificar formato básico da URL
    if [[ ! "$url" =~ ^https?:// ]]; then
        echo -e "${CYBER_RED}Error: URL must start with http:// or https://${RESET}"
        return 1
    fi

    return 0
}