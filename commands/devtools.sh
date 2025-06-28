#!/bin/bash

# ==================================================
# CONFIGURAÇÕES GLOBAIS
# ==================================================

# Carrega bibliotecas
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

# ==========================================
# FUNÇÕES PRINCIPAIS
# ==========================================

show_devtools_header() {
    clear
    echo -e "${CYBER_BG_DARK}${CYBER_PINK}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║   ██████╗ ███████╗██╗   ██╗████████╗ ██████╗ ║"
    echo "║   ██╔══██╗██╔════╝██║   ██║╚══██╔══╝██╔═══██╗║"
    echo "║   ██║  ██║█████╗  ██║   ██║   ██║   ██║   ██║║"
    echo "║   ██║  ██║██╔══╝  ╚██╗ ██╔╝   ██║   ██║   ██║║"
    echo "║   ██████╔╝███████╗ ╚████╔╝    ██║   ╚██████╔╝║"
    echo "║   ╚═════╝ ╚══════╝  ╚═══╝     ╚═╝    ╚═════╝ ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
    cyber_divider
}

show_devtools_menu() {
    echo -e "${CYBER_BLUE}${CYBER_BOLD}  🛠️ MENU DE FERRAMENTAS DE DESENVOLVIMENTO 🛠️${RESET}"
    echo ""
    echo -e "${CYBER_PINK}1) Terminal Services (Zsh/OhMyZsh/Spaceship)"
    echo -e "2) Database Tools (DBeaver/MongoDB Compass/pgAdmin/MySQL)"
    echo -e "3) Ajuda"
    echo -e "0) Voltar${RESET}"
    echo ""
    cyber_divider
}

# ==========================================
# FUNÇÕES DE CHAMADA (APENAS PARA MÓDULOS EXISTENTES)
# ==========================================

call_terminal_services() {
    echo -e "${CYBER_YELLOW}⚡ Iniciando Terminal Tools...${RESET}"
    source "$BASE_DIR/lib/devtools/terminal_services.sh"
}

call_database_tools() {
    echo -e "${CYBER_YELLOW}⚡ Iniciando Database Tools...${RESET}"
    source "$BASE_DIR/lib/devtools/database_services.sh"
}

call_browser_tools() {
    echo -e "${CYBER_YELLOW}⚡ Iniciando Browser Tools...${RESET}"
    source "$BASE_DIR/lib/devtools/browser_services.sh"
}

call_api_tools() {
    echo -e "${CYBER_YELLOW}⚡ Iniciando API Tools...${RESET}"
    source "$BASE_DIR/lib/devtools/api_services.sh" "${@:1}"
}

# ==========================================
# PROCESSAMENTO DE COMANDOS
# ==========================================

process_command() {
    case $1 in
        "terminal"|"term")
            call_terminal_services "${@:2}"
            ;;
        "database"|"db")
            call_database_tools "${@:2}"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        "browser"|"bwsr")
            call_browser_tools "${@:2}"
            ;;
          "api"|"api-tools")
            call_api_tools "${@:2}"
            ;;
        *)
            echo -e "${CYBER_RED}✘ Comando inválido! Use 'help' para ver as opções${RESET}"
            ;;
    esac
}

show_help() {
    show_devtools_header
    echo -e "${CYBER_BLUE}USO: bytebabe devtools [comando] [opções]"
    echo -e "\nCOMANDOS DISPONÍVEIS:"
    echo -e "  ${CYBER_PINK}terminal, term${RESET}   - Ferramentas de terminal (Zsh, OhMyZsh, Spaceship)"
    echo -e "  ${CYBER_PINK}database, db${RESET}    - Ferramentas de banco de dados (DBeaver, MongoDB Compass, pgAdmin, MySQL)"
    echo -e "  ${CYBER_PINK}help${RESET}           - Mostra esta ajuda"
    echo -e "\nEXEMPLOS:"
    echo -e "  ${CYBER_YELLOW}bytebabe devtools terminal all"
    echo -e "  ${CYBER_YELLOW}bytebabe devtools database all"
    echo -e "  ${CYBER_YELLOW}bytebabe devtools help${RESET}"
    cyber_divider
}

# ==========================================
# FUNÇÃO PRINCIPAL
# ==========================================

main() {
    if [[ $# -eq 0 ]]; then
        # Modo interativo
        while true; do
            show_devtools_header
            show_devtools_menu
            read -p $'\e[1;35m  ⌘ SELECIONE UMA OPÇÃO: \e[0m' choice

            case $choice in
                1) call_terminal_services ;;
                2) call_database_tools ;;
                3) call_browser_tools;;
                4) show_help ;;
                0) break ;;
                *)
                    echo -e "${CYBER_RED}✘ Opção inválida!${RESET}"
                    sleep 1
                    ;;
            esac
            [[ "$choice" != "3" && "$choice" != "0" ]] && read -p $'\e[1;36m  Pressione ENTER para continuar...\e[0m'
        done
    else
        # Modo direto
        process_command "$@"
    fi
}

# ==========================================
# INICIALIZAÇÃO
# ==========================================

main "$@"