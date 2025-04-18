#!/bin/bash

# Exibe o cabeçalho da requisição
show_request_header() {
    local method="$1"
    local url="$2"

    echo -e "\n${CYBER_BLUE}╭─────────── REQUEST ───────────╮${RESET}"
    echo -e "${CYBER_BLUE}│${RESET} ${CYBER_GREEN}${method}${RESET} ${url}"
    echo -e "${CYBER_BLUE}╰────────────────────────────────╯${RESET}\n"
}

# Exibe os headers da requisição
show_request_headers() {
    local header_array=("$@")  # Recebe os headers como array

    echo -e "${CYBER_BLUE}Headers:${RESET}"
    for header in "${header_array[@]}"; do
        echo -e "  ${CYBER_YELLOW}▸${RESET} ${header}"
    done
    echo
}

# Exibe o corpo da resposta formatado
show_response() {
    local status_code="$1"
    local headers="$2"
    local body="$3"
    local duration="$4"

    # Determina a cor baseada no status code
    local status_color
    if [[ $status_code -ge 200 && $status_code -lt 300 ]]; then
        status_color=$CYBER_GREEN
    elif [[ $status_code -ge 300 && $status_code -lt 400 ]]; then
        status_color=$CYBER_YELLOW
    else
        status_color=$CYBER_RED
    fi

    echo -e "\n${CYBER_BLUE}╭─────────── RESPONSE ───────────╮${RESET}"
    echo -e "${CYBER_BLUE}│${RESET} Status: ${status_color}${status_code}${RESET}"
    echo -e "${CYBER_BLUE}│${RESET} Time: ${CYBER_YELLOW}${duration}ms${RESET}"
    echo -e "${CYBER_BLUE}╰─────────────────────────────────╯${RESET}\n"

    # Mostra headers da resposta
    echo -e "${CYBER_BLUE}Response Headers:${RESET}"
    echo "$headers" | while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            echo -e "  ${CYBER_YELLOW}▸${RESET} ${line}"
        fi
    done
    echo

    # Tenta formatar o body como JSON se possível
    if [[ "$body" =~ ^\{.*\}$ || "$body" =~ ^\[.*\]$ ]]; then
        echo "$body" | jq -C '.' 2>/dev/null || echo "$body"
    else
        echo "$body"
    fi
    echo
}

# Exibe mensagem de erro
show_error() {
    local message="$1"
    echo -e "\n${CYBER_RED}╭─────────── ERROR ───────────╮${RESET}"
    echo -e "${CYBER_RED}│${RESET} ${message}"
    echo -e "${CYBER_RED}╰───────────────────────────────╯${RESET}\n"
}

# Exibe barra de progresso durante a requisição
show_loading() {
    local pid=$1
    local message="${2:-Making request...}"
    local spin=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0

    while kill -0 $pid 2>/dev/null; do
        echo -ne "\r${CYBER_BLUE}${spin[$i]} ${message}${RESET}"
        i=$(( (i+1) % 10 ))
        sleep 0.1
    done
    echo -ne "\r\033[K"  # Limpa a linha
}