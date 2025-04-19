#!/bin/bash

perform_get_request() {
    local url="$1"
    local params="$2"
    
    # Limpa a tela e mostra o header
    clear
    show_flux_header
    
    # Prepara o comando curl base com formatação de saída
    local curl_cmd="curl -s -i -w '\n%{http_code}\n%{time_total}'"

    # Mostra cabeçalho da requisição
    show_request_header "GET" "$url"

    # Prepara headers padrão
    local headers=()
    headers+=("User-Agent: Flux-HTTP-Client/1.0")
    headers+=("Accept: application/json")
    
    # Adiciona headers customizados dos parâmetros
    if [[ -n "$params" ]]; then
        while IFS= read -r header; do
            if [[ -n "$header" ]]; then
                headers+=("$header")
            fi
        done <<< "$(echo "$params" | grep -o "\-H '[^']*'" | cut -d"'" -f2)"
    fi
    
    # Mostra headers da requisição
    show_request_headers "${headers[@]}"
    
    # Adiciona headers ao comando curl
    for header in "${headers[@]}"; do
        curl_cmd+=" -H '${header}'"
    done

    # Adiciona URL e parâmetros extras
    curl_cmd+=" '$url'"
    if [[ -n "$params" ]]; then
        # Adiciona outros parâmetros que não são headers
        local other_params=$(echo "$params" | grep -v "\-H '[^']*'")
        if [[ -n "$other_params" ]]; then
            curl_cmd+=" $other_params"
        fi
    fi

    # Executa request em background e mostra loading
    eval "$curl_cmd" > /tmp/flux_response.$$ &
    show_loading $!

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

# Função para mostrar loading durante a requisição
show_loading() {
    local pid=$1
    local spin='-\|/'
    local i=0

    echo -ne "\n${CYBER_BLUE}Executing request...${RESET} "
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %4 ))
        echo -ne "\r${CYBER_BLUE}Executing request...${RESET} ${spin:$i:1}"
        sleep .1
    done
    echo -ne "\r${CYBER_BLUE}Request completed${RESET}    \n\n"
}

# Função para mostrar o cabeçalho da requisição
show_request_header() {
    local method="$1"
    local url="$2"

    echo -e "\n${CYBER_BLUE}╭─────────── REQUEST ───────────╮${RESET}"
    echo -e "${CYBER_BLUE}│${RESET} ${CYBER_GREEN}${method}${RESET} ${url}"
    echo -e "${CYBER_BLUE}╰────────────────────────────────╯${RESET}\n"
}

# Função para mostrar os headers da requisição
show_request_headers() {
    echo -e "${CYBER_BLUE}Headers:${RESET}"
    for header in "$@"; do
        echo -e "  ${CYBER_YELLOW}▸${RESET} ${header}"
    done
    echo
}
