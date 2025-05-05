#!/bin/bash

# Importa o módulo de histórico
source "$(dirname "$0")/history.sh"

# Função para enviar requisição HTTP
send_request() {
    local method="$1"
    local url="$2"
    local headers="$3"
    local body="$4"
    
    echo -e "${CYBER_BLUE}Enviando requisição ${method} para ${url}...${RESET}"
    
    # Prepara os headers para curl
    local header_args=""
    if [ ! -z "$headers" ]; then
        while IFS= read -r line; do
            header_args="$header_args -H \"$line\""
        done <<< "$headers"
    fi
    
    # Prepara o comando curl
    local curl_cmd="curl -s -X $method $header_args"
    
    # Adiciona o body se necessário
    if [ ! -z "$body" ] && [[ "$method" != "GET" ]]; then
        curl_cmd="$curl_cmd -d '$body'"
    fi
    
    # Adiciona a URL
    curl_cmd="$curl_cmd \"$url\""
    
    # Executa a requisição e captura a resposta
    local response=$(eval $curl_cmd)
    local status_code=$(eval $curl_cmd -o /dev/null -w "%{http_code}")
    
    # Salva no histórico
    save_request_history "$method" "$url" "$headers" "$body" "$response" "$status_code"
    
    # Exibe a resposta
    echo -e "${CYBER_GREEN}✓ Resposta recebida (Status: $status_code)${RESET}"
    echo "$response" | jq . 2>/dev/null || echo "$response"
    
    return 0
}

# Menu de histórico
show_history_menu() {
    while true; do
        clear
        echo -e "${HEADER_STYLE}╔════════════════════════════════════════════════╗${RESET}"
        echo -e "${HEADER_STYLE}║           HISTÓRICO DE REQUISIÇÕES             ║${RESET}"
        echo -e "${HEADER_STYLE}╚════════════════════════════════════════════════╝${RESET}"
        echo
        echo -e "1) ${CYBER_CYAN}Listar histórico${RESET}"
        echo -e "2) ${CYBER_CYAN}Ver detalhes de uma requisição${RESET}"
        echo -e "3) ${CYBER_CYAN}Limpar histórico${RESET}"
        echo -e "4) ${CYBER_CYAN}Exportar histórico${RESET}"
        echo -e "0) ${CYBER_CYAN}Voltar${RESET}"
        echo
        read -p "Escolha uma opção: " option
        
        case $option in
            1)
                clear
                list_request_history
                read -p "Pressione Enter para continuar..."
                ;;
            2)
                clear
                list_request_history
                echo
                read -p "Digite o número da requisição: " req_num
                clear
                view_request_details $req_num
                read -p "Pressione Enter para continuar..."
                ;;
            3)
                clear
                clear_request_history
                read -p "Pressione Enter para continuar..."
                ;;
            4)
                clear
                read -p "Digite o nome do arquivo (ou Enter para padrão): " filename
                export_request_history "$filename"
                read -p "Pressione Enter para continuar..."
                ;;
            0)
                return
                ;;
            *)
                echo -e "${CYBER_RED}✗ Opção inválida${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Adiciona opção de histórico ao menu principal do Flux
# Esta função deve ser chamada pelo menu principal
add_history_option_to_menu() {
    echo -e "H) ${CYBER_CYAN}Histórico de Requisições${RESET}"
}

# Handler para a opção de histórico
handle_history_option() {
    show_history_menu
}