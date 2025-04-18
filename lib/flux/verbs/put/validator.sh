#!/bin/bash

validate_url() {
    local url="$1"
    
    if [[ -z "$url" ]]; then
        echo -e "${CYBER_RED}Error: URL is required${RESET}"
        show_put_help
        return 1
    fi

    if [[ ! "$url" =~ ^https?:// ]]; then
        echo -e "${CYBER_RED}Error: URL must start with http:// or https://${RESET}"
        return 1
    fi

    return 0
}