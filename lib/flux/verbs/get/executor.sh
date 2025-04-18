#!/bin/bash

perform_get_request() {
    local url="$1"
    local params="$2"
    
    # Limpa a tela e mostra o header
    clear
    show_flux_header
    
    local curl_cmd="curl -s -i -w '\n%{http_code}\n%{time_total}'"

    # Mostra cabeçalho da requisição
    show_request_header "GET" "$url"

    # Prepara headers
    local headers=()
    headers+=("User-Agent: Flux-HTTP-Client/1.0")
    headers+=("Accept: application/json")
    
    # Mostra headers da requisição
    show_request_headers "${headers[@]}"
    
    # Adiciona headers ao comando curl
    for header in "${headers[@]}"; do
        curl_cmd+=" -H '${header}'"
    done

    # Adiciona URL
    curl_cmd+=" '$url'"

    # Executa request em background e mostra loading
    eval "$curl_cmd" > /tmp/flux_response.$$ &
    show_loading $!

    # Separa headers e body da resposta
    local response_headers=$(sed '/^\r$/q' /tmp/flux_response.$$)
    local response_body=$(sed '1,/^\r$/d' /tmp/flux_response.$$ | head -n -2)
    local status_code=$(tail -n 2 /tmp/flux_response.$$ | head -n 1)
    local duration=$(tail -n 1 /tmp/flux_response.$$ | awk '{printf "%.0f", $1 * 1000}')

    # Remove arquivo temporário
    rm -f /tmp/flux_response.$$

    # Mostra resposta com headers
    show_response "$status_code" "$response_headers" "$response_body" "$duration"
}
