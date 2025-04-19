#!/bin/bash

validate_url() {
    local url="$1"
    
    if [[ -z "$url" ]]; then
        echo -e "${CYBER_RED}Error: URL is required${RESET}" >&2
        return 1
    fi
    
    if ! [[ "$url" =~ ^https?:// ]]; then
        echo -e "${CYBER_RED}Error: Invalid URL format. Must start with http:// or https://${RESET}" >&2
        return 1
    fi
    
    return 0
}

validate_delete_args() {
    return 0
}
