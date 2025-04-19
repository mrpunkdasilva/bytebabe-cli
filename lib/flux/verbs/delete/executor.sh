#!/bin/bash

perform_delete_request() {
    local url="$1"
    local params="$2"
    local loading_style="${3:-default}"
    
    # Header da requisição
    echo -e "\n${CYBER_BLUE}DELETE${RESET} ${CYBER_YELLOW}$url${RESET}"
    echo -e "${CYBER_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    
    # Prepara o comando curl
    local curl_cmd="curl -s -i -w '\n%{http_code}\n%{time_total}' -X DELETE"
    curl_cmd+=" -H 'User-Agent: Flux-HTTP-Client/1.0'"
    curl_cmd+=" -H 'Accept: application/json'"
    
    # Adiciona headers customizados
    if [[ -n "$params" ]]; then
        curl_cmd+=" $params"
    fi
    
    curl_cmd+=" '$url'"
    
    # Executa a requisição com spinner
    echo -ne "${CYBER_YELLOW}⚡ Sending request...${RESET}"
    eval "$curl_cmd" > /tmp/flux_response.$$ &
    
    # Mostra spinner enquanto processa
    local pid=$!
    local spin='-\|/'
    local i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        printf "\r${CYBER_YELLOW}⚡ Sending request... ${spin:$i:1}${RESET}"
        sleep .1
    done
    printf "\r${CYBER_GREEN}⚡ Request sent!      ${RESET}\n"
    
    # Processa a resposta
    local response_headers=$(sed '/^\r$/q' /tmp/flux_response.$$)
    local response_body=$(sed '1,/^\r$/d' /tmp/flux_response.$$ | head -n -2)
    local status_code=$(tail -n 2 /tmp/flux_response.$$ | head -n 1)
    local duration=$(tail -n 1 /tmp/flux_response.$$ | awk '{printf "%.0f", $1 * 1000}')
    
    rm -f /tmp/flux_response.$$
    
    # Formata o status code com cores
    local status_color
    if [[ $status_code -ge 200 && $status_code -lt 300 ]]; then
        status_color="${CYBER_GREEN}"
    elif [[ $status_code -ge 400 ]]; then
        status_color="${CYBER_RED}"
    else
        status_color="${CYBER_YELLOW}"
    fi
    
    # Mostra a resposta formatada
    echo -e "\n${CYBER_BLUE}Response${RESET} ${CYBER_YELLOW}(${duration}ms)${RESET}"
    echo -e "${CYBER_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "${CYBER_YELLOW}Status:${RESET} ${status_color}${status_code}${RESET}"
    
    # Mostra headers mais relevantes
    echo -e "\n${CYBER_YELLOW}Headers:${RESET}"
    echo "$response_headers" | grep -iE '^(content-type|content-length|location|x-|authorization)' | sed 's/^/  /'
    
    # Mostra corpo da resposta se existir
    if [[ -n "$response_body" ]]; then
        echo -e "\n${CYBER_YELLOW}Body:${RESET}"
        if [[ "$response_body" =~ ^\{.*\}$ || "$response_body" =~ ^\[.*\]$ ]]; then
            echo "$response_body" | jq -C '.' 2>/dev/null || echo "$response_body"
        else
            echo "$response_body"
        fi
    fi
    
    # Linha final
    echo -e "\n${CYBER_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    
    # Retorna sucesso se status code for 2xx
    return $(( status_code >= 200 && status_code < 300 ? 0 : 1 ))
}