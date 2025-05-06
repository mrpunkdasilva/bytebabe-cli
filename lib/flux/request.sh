#!/bin/bash

# Importa o módulo de histórico
source "$(dirname "$0")/history.sh"

# Definição de cores caso não estejam definidas
if [ -z "$CYBER_PINK" ]; then
    CYBER_PINK='\033[38;5;198m'
    CYBER_BLUE='\033[38;5;45m'
    CYBER_GREEN='\033[38;5;118m'
    CYBER_YELLOW='\033[38;5;227m'
    CYBER_RED='\033[38;5;196m'
    CYBER_PURPLE='\033[38;5;93m'
    CYBER_CYAN='\033[38;5;51m'
    RESET='\033[0m'
    BOLD='\033[1m'
fi

# Verifica se as funções do history.sh foram carregadas
if ! type list_request_history > /dev/null 2>&1; then
    echo -e "${CYBER_RED}[✗] Erro: Funções do módulo de histórico não foram carregadas corretamente${RESET}"
    echo -e "${CYBER_YELLOW}[!] Verificando se o arquivo history.sh existe...${RESET}"
    
    HISTORY_PATH="$(dirname "$0")/history.sh"
    if [ -f "$HISTORY_PATH" ]; then
        echo -e "${CYBER_GREEN}[✓] Arquivo encontrado: $HISTORY_PATH${RESET}"
        echo -e "${CYBER_BLUE}[i] Tentando carregar novamente...${RESET}"
        source "$HISTORY_PATH"
    else
        echo -e "${CYBER_RED}[✗] Arquivo não encontrado: $HISTORY_PATH${RESET}"
        exit 1
    fi
    
    # Verifica novamente se as funções foram carregadas
    if ! type list_request_history > /dev/null 2>&1; then
        echo -e "${CYBER_RED}[✗] Falha ao carregar as funções do módulo de histórico${RESET}"
        exit 1
    fi
fi

# Menu de histórico
show_history_menu() {
    while true; do
        clear
        
        # Mostra o cabeçalho diretamente aqui em vez de chamar a função
        echo -e "${CYBER_BLUE}"
        cat << "EOF"
 _    _ _____  _____ _______ ____  _______     __
| |  | |_   _|/ ____|__   __/ __ \|  __ \ \   / /
| |__| | | | | (___    | | | |  | | |__) \ \_/ / 
|  __  | | |  \___ \   | | | |  | |  _  / \   /  
| |  | |_| |_ ____) |  | | | |__| | | \ \  | |   
|_|  |_|_____|_____/   |_|  \____/|_|  \_\ |_|   
                                                 
EOF
        
        echo -e "${CYBER_PURPLE}╔═══════════════════════════════════════════════════════════════╗${RESET}"
        echo -e "${CYBER_PURPLE}║ ${CYBER_CYAN}${BOLD}MENU DE HISTÓRICO${RESET}${CYBER_PURPLE}                                    ║${RESET}"
        echo -e "${CYBER_PURPLE}╚═══════════════════════════════════════════════════════════════╝${RESET}"
        echo
        echo -e "  ${CYBER_BLUE}[1]${RESET} ${CYBER_CYAN}Listar histórico${RESET}"
        echo -e "  ${CYBER_BLUE}[2]${RESET} ${CYBER_CYAN}Ver detalhes de uma requisição${RESET}"
        echo -e "  ${CYBER_BLUE}[3]${RESET} ${CYBER_CYAN}Limpar histórico${RESET}"
        echo -e "  ${CYBER_BLUE}[4]${RESET} ${CYBER_CYAN}Exportar histórico${RESET}"
        echo -e "  ${CYBER_BLUE}[5]${RESET} ${CYBER_CYAN}Forçar limpeza do histórico${RESET}"
        echo -e "  ${CYBER_BLUE}[0]${RESET} ${CYBER_CYAN}Voltar${RESET}"
        echo
        echo -e "${CYBER_PURPLE}───────────────────────────────────────────────────────────────${RESET}"
        
        # Usar echo -ne em vez de read -p para cores
        echo -ne "${CYBER_PINK}Escolha uma opção: ${RESET}"
        read option
        
        case $option in
            1)
                clear
                list_request_history
                echo
                echo -ne "${CYBER_BLUE}Pressione Enter para continuar...${RESET}"
                read
                ;;
            2)
                clear
                list_request_history
                echo
                echo -ne "${CYBER_PINK}Digite o número da requisição: ${RESET}"
                read req_num
                clear
                view_request_details $req_num
                echo
                echo -ne "${CYBER_BLUE}Pressione Enter para continuar...${RESET}"
                read
                ;;
            3)
                clear
                clear_request_history
                echo
                echo -ne "${CYBER_BLUE}Pressione Enter para continuar...${RESET}"
                read
                ;;
            4)
                clear
                echo -e "${CYBER_PURPLE}╔═══════════════════════════════════════════════════════════════╗${RESET}"
                echo -e "${CYBER_PURPLE}║ ${CYBER_CYAN}${BOLD}EXPORTAR HISTÓRICO${RESET}${CYBER_PURPLE}                                  ║${RESET}"
                echo -e "${CYBER_PURPLE}╚═══════════════════════════════════════════════════════════════╝${RESET}"
                echo
                echo -e "${CYBER_YELLOW}[i] O arquivo será salvo na pasta home do usuário se não for especificado um caminho completo.${RESET}"
                echo -e "${CYBER_YELLOW}[i] Exemplo: ${CYBER_CYAN}meu_historico.json${RESET} será salvo como ${CYBER_CYAN}$HOME/meu_historico.json${RESET}"
                echo
                echo -ne "${CYBER_PINK}Digite o nome do arquivo (ou Enter para padrão): ${RESET}"
                read filename
                export_request_history "$filename"
                echo
                echo -ne "${CYBER_BLUE}Pressione Enter para continuar...${RESET}"
                read
                ;;
            5)
                clear
                echo -e "${CYBER_YELLOW}[!] Forçando limpeza do histórico...${RESET}"
                clear_request_history 1
                echo
                echo -ne "${CYBER_BLUE}Pressione Enter para continuar...${RESET}"
                read
                ;;
            0)
                return
                ;;
            *)
                echo -e "${CYBER_RED}[✗] Opção inválida${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Função para processar e salvar uma requisição no histórico
process_request_for_history() {
    local method="$1"
    local url="$2"
    local headers="$3"
    local body="$4"
    local response="$5"
    local status_code="$6"
    
    # Salva no histórico
    save_request_history "$method" "$url" "$headers" "$body" "$response" "$status_code"
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
