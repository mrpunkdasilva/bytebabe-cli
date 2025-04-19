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
    
    # Extrai dados do body se existirem
    local body=""
    if [[ -n "$params" ]]; then
        body=$(echo "$params" | grep -o "\-d '[^']*'" | cut -d"'" -f2)
        while IFS= read -r header; do
            [[ -n "$header" ]] && headers+=("$header")
        done <<< "$(echo "$params" | grep -o "\-H '[^']*'" | cut -d"'" -f2)"
    fi
    
    # Mostra headers da requisição
    show_request_headers "${headers[@]}"
    
    # Mostra body da requisição se existir
    if [[ -n "$body" ]]; then
        echo -e "\n${CYBER_BLUE}Body:${RESET}"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
    fi
    
    # Adiciona headers ao comando curl
    for header in "${headers[@]}"; do
        curl_cmd+=" -H '${header}'"
    done
    
    # Adiciona URL e body
    curl_cmd+=" '$url'"
    [[ -n "$body" ]] && curl_cmd+=" -d '$body'"
    
    # Executa request em background
    eval "$curl_cmd" > /tmp/flux_response.$$ &
    
    # Mostra loading animation (substituindo show_lazy_loading por show_loading)
    show_loading $! "Making POST request..."
    
    # Processa a resposta
    local response_headers=$(sed '/^\r$/q' /tmp/flux_response.$$)
    local response_body=$(sed '1,/^\r$/d' /tmp/flux_response.$$ | head -n -2)
    local status_code=$(tail -n 2 /tmp/flux_response.$$ | head -n 1)
    local duration=$(tail -n 1 /tmp/flux_response.$$ | awk '{printf "%.0f", $1 * 1000}')
    
    # Remove arquivo temporário
    rm -f /tmp/flux_response.$$
    
    # Mostra resposta formatada
    show_response "$status_code" "$response_headers" "$response_body" "$duration"
}
