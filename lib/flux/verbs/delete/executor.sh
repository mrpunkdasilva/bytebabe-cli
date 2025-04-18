#!/bin/bash

perform_delete_request() {
    local url="$1"
    local params="$2"
    local curl_cmd="curl -s -X DELETE"

    # Adicionar headers padrão
    curl_cmd+=" -H 'User-Agent: Flux-HTTP-Client/1.0'"
    
    # Adicionar parâmetros extras se existirem
    if [[ -n "$params" ]]; then
        curl_cmd+=" $params"
    fi

    # Adicionar URL
    curl_cmd+=" '$url'"

    # Executar request
    echo -e "${CYBER_BLUE}Executing DELETE request...${RESET}"
    eval "$curl_cmd" | jq '.' 2>/dev/null || cat
}