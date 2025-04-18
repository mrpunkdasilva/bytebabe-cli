#!/bin/bash

perform_post_request() {
    local url="$1"
    local params="$2"
    local curl_cmd="curl -s -X POST"

    # Adicionar headers padrão
    curl_cmd+=" -H 'User-Agent: Flux-HTTP-Client/1.0'"
    curl_cmd+=" -H 'Content-Type: application/json'"
    
    # Adicionar parâmetros extras se existirem
    if [[ -n "$params" ]]; then
        curl_cmd+=" $params"
    fi

    # Adicionar URL
    curl_cmd+=" '$url'"

    # Executar request
    echo -e "${CYBER_BLUE}Executing POST request...${RESET}"
    eval "$curl_cmd" | jq '.' 2>/dev/null || cat
}