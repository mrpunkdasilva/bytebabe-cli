#!/bin/bash

# Exibe o cabeçalho do Flux
show_flux_header() {
    clear
    echo -e "${CYBER_BLUE}"
    cat << "EOF"
    ███████╗██╗     ██╗   ██╗██╗  ██╗
    ██╔════╝██║     ██║   ██║╚██╗██╔╝
    █████╗  ██║     ██║   ██║ ╚███╔╝ 
    ██╔══╝  ██║     ██║   ██║ ██╔██╗ 
    ██║     ███████╗╚██████╔╝██╔╝ ██╗
    ╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
EOF
    echo -e "${CYBER_PURPLE}"
    echo -e "╔════════════════════════════════════════╗"
    echo -e "║   ${CYBER_BLUE}⚡ ${CYBER_YELLOW}HTTP CLIENT v1.0 ${CYBER_PURPLE}⚡   "
    echo -e "╚════════════════════════════════════════╝${RESET}"
    echo
}

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

# Mostra a ajuda do Flux
show_flux_help() {
    echo -e "${CYBER_PURPLE}╔═══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║ ${CYBER_CYAN}${BOLD}FLUX API CLIENT - AJUDA${RESET}${CYBER_PURPLE}                              ║${RESET}"
    echo -e "${CYBER_PURPLE}╚═══════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYBER_BLUE}Uso:${RESET} flux ${CYBER_GREEN}<comando>${RESET} [opções]"
    echo
    echo -e "${CYBER_BLUE}Comandos:${RESET}"
    echo -e "  ${CYBER_GREEN}get${RESET}      Envia uma requisição GET"
    echo -e "  ${CYBER_GREEN}post${RESET}     Envia uma requisição POST"
    echo -e "  ${CYBER_GREEN}put${RESET}      Envia uma requisição PUT"
    echo -e "  ${CYBER_GREEN}delete${RESET}   Envia uma requisição DELETE"
    echo -e "  ${CYBER_GREEN}history${RESET}  Gerencia o histórico de requisições"
    echo -e "  ${CYBER_GREEN}server${RESET}   Inicia um servidor JSON para testes"
    echo
    echo -e "${CYBER_BLUE}Exemplos:${RESET}"
    echo -e "  ${CYBER_CYAN}flux get https://api.exemplo.com/users${RESET}"
    echo -e "  ${CYBER_CYAN}flux post https://api.exemplo.com/users -d '{\"name\":\"John\"}'${RESET}"
    echo -e "  ${CYBER_CYAN}flux server${RESET} (inicia o servidor JSON na porta 3000)"
    echo -e "  ${CYBER_CYAN}flux server 8080${RESET} (inicia o servidor JSON na porta 8080)"
}
