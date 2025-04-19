#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/../../ui/header.sh"
source "$(dirname "${BASH_SOURCE[0]}")/../../ui/loading.sh"

perform_post_request() {
    local url="$1"
    local params="$2"
    local loading_style="${3:-default}"
    
    # Limpa a tela e mostra o header
    clear
    show_flux_header
    
    # Prepara o comando curl base
    local curl_cmd="curl -s -i -w '\n%{http_code}\n%{time_total}' -X POST"
    
    # Mostra cabeçalho da requisição
    show_request_header "POST" "$url"
    
    # Configura headers padrão
    local headers=()
    headers+=("User-Agent: Flux-HTTP-Client/1.0")
    headers+=("Content-Type: application/json")
    
    # Adiciona headers ao comando curl
    for header in "${headers[@]}"; do
        curl_cmd+=" -H '${header}'"
    done
    
    # Extrai dados do body se existirem
    local body=""
    if [[ -n "$params" ]]; then
        # Extrai o body dos parâmetros
        body=$(echo "$params" | grep -o "\-d '[^']*'" | cut -d"'" -f2)
        
        # Extrai e adiciona headers customizados
        while IFS= read -r header; do
            [[ -n "$header" ]] && curl_cmd+=" -H '${header}'"
        done <<< "$(echo "$params" | grep -o "\-H '[^']*'" | cut -d"'" -f2)"
    fi
    
    # Adiciona URL e body
    curl_cmd+=" '$url'"
    [[ -n "$body" ]] && curl_cmd+=" -d '$body'"
    
    # Mostra preview da requisição
    echo -e "\n${CYBER_BLUE}Request Preview:${RESET}"
    echo -e "${CYBER_YELLOW}URL:${RESET} $url"
    echo -e "${CYBER_YELLOW}Method:${RESET} POST"
    echo -e "${CYBER_YELLOW}Headers:${RESET}"
    echo "$curl_cmd" | grep -o "\-H '[^']*'" | cut -d"'" -f2 | sed 's/^/  /'
    if [[ -n "$body" ]]; then
        echo -e "${CYBER_YELLOW}Body:${RESET}"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
    fi
    
    # Executa request em background
    eval "$curl_cmd" > /tmp/flux_response.$$ &
    
    # Mostra loading animation
    show_loading $! "Making POST request to $url..."
    
    # Processa a resposta
    local response_headers=$(sed '/^\r$/q' /tmp/flux_response.$$)
    local response_body=$(sed '1,/^\r$/d' /tmp/flux_response.$$ | head -n -2)
    local status_code=$(tail -n 2 /tmp/flux_response.$$ | head -n 1)
    local duration=$(tail -n 1 /tmp/flux_response.$$ | awk '{printf "%.0f", $1 * 1000}')
    
    # Remove arquivo temporário
    rm -f /tmp/flux_response.$$
    
    # Formata e mostra a resposta
    echo -e "\n${CYBER_BLUE}Response:${RESET}"
    echo -e "${CYBER_YELLOW}Status:${RESET} $status_code"
    echo -e "${CYBER_YELLOW}Time:${RESET} ${duration}ms"
    echo -e "${CYBER_YELLOW}Headers:${RESET}"
    echo "$response_headers" | grep -v "^$" | sed 's/^/  /'
    
    if [[ -n "$response_body" ]]; then
        echo -e "${CYBER_YELLOW}Body:${RESET}"
        echo "$response_body" | jq '.' 2>/dev/null || echo "$response_body"
    fi
}
