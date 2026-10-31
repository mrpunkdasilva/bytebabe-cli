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
    echo -e "${CYBER_PINK}1) Terminal Services (Zsh/OhMyZsh/Spaceship/Atuin)"
    echo -e "2) Database Tools (DBeaver/MongoDB Compass/pgAdmin/MySQL)"
    echo -e "3) Browser Tools (Chrome/Firefox/Brave/Edge/Vivaldi)"
    echo -e "4) API Tools (curl/httpie/jq/yq/grpcurl/websocat)"
    echo -e "5) Instalar Docker"
    echo -e "6) Ajuda"
    echo -e "0) Voltar${RESET}"
    echo ""
    cyber_divider
}

# ==========================================
# FUNÇÕES DE CHAMADA (APENAS PARA MÓDULOS EXISTENTES)
# ==========================================

call_terminal_services() {
    echo -e "${CYBER_YELLOW}⚡ Iniciando Terminal Tools...${RESET}"
    ( source "$BASE_DIR/lib/devtools/terminal_services.sh"; terminal_services_main "$@" )
}

call_database_tools() {
    echo -e "${CYBER_YELLOW}⚡ Iniciando Database Tools...${RESET}"
    ( source "$BASE_DIR/lib/devtools/database_services.sh"; database_services_main "$@" )
}

call_browser_tools() {
    echo -e "${CYBER_YELLOW}⚡ Iniciando Browser Tools...${RESET}"
    ( source "$BASE_DIR/lib/devtools/browser_services.sh"; browser_services_main "$@" )
}

call_api_tools() {
    echo -e "${CYBER_YELLOW}⚡ Iniciando API Tools...${RESET}"
    ( source "$BASE_DIR/lib/devtools/api_services.sh"; api_services_main "$@" )
}

call_docker_install() {
    echo -e "${CYBER_BLUE}${CYBER_BOLD}  🐳 INSTALADOR DO DOCKER${RESET}"
    echo -e "${CYBER_GRAY}  Requer privilégios de administrador (sudo).${RESET}"
    cyber_divider
    read -r -p $'\e[1;35m  ⌘ DESEJA CONTINUAR? (s/n): \e[0m' resposta

    if [[ ! "$resposta" =~ ^[Ss]$ ]]; then
        echo -e "${CYBER_YELLOW}  ⚠ Instalação do Docker ignorada.${RESET}"
        return 0
    fi

    echo -e "${CYBER_PINK}  ⚡ Executando instalador upstream...${RESET}"
    cyber_divider
    if env -u VERSION bash "$BASE_DIR/lib/utils/get_docker.sh"; then
        cyber_divider
        echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}${CYBER_BOLD}Docker instalado com sucesso!${RESET}"
    else
        cyber_divider
        echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}${CYBER_BOLD}Falha na instalação do Docker.${RESET}"
        return 1
    fi
}

# ==========================================
# PROCESSAMENTO DE COMANDOS
# ==========================================

process_command() {
    case $1 in
        "terminal"|"term"|"t")
            call_terminal_services "${@:2}"
            ;;
        "database"|"db"|"d")
            call_database_tools "${@:2}"
            ;;
        "help"|"--help"|"-h"|"h")
            show_help
            ;;
        "browser"|"bwsr"|"b")
            call_browser_tools "${@:2}"
            ;;
        "api"|"api-tools"|"a")
            call_api_tools "${@:2}"
            ;;
        "docker"|"install-docker")
            call_docker_install
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
    echo -e "  ${CYBER_PINK}terminal, term, t${RESET}   - Ferramentas de terminal (Zsh, OhMyZsh, Spaceship, Atuin)"
    echo -e "  ${CYBER_PINK}database, db, d${RESET}     - Ferramentas de banco de dados (DBeaver, MongoDB Compass, pgAdmin, MySQL)"
    echo -e "  ${CYBER_PINK}browser, bwsr, b${RESET}    - Ferramentas de navegador (Chrome, Firefox, Brave, Edge, Vivaldi)"
    echo -e "  ${CYBER_PINK}api, api-tools, a${RESET}   - Ferramentas de API (curl, httpie, jq, yq, grpcurl, websocat)"
    echo -e "  ${CYBER_PINK}docker, install-docker${RESET} - Instala o Docker"
    echo -e "  ${CYBER_PINK}help, h${RESET}             - Mostra esta ajuda"
    echo -e "\nEXEMPLOS:"
    echo -e "  ${CYBER_YELLOW}bytebabe devtools terminal all${RESET}  ou  ${CYBER_YELLOW}bytebabe devtools t all"
    echo -e "  ${CYBER_YELLOW}bytebabe devtools database all${RESET}  ou  ${CYBER_YELLOW}bytebabe devtools d all"
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
                3) call_browser_tools ;;
                4) call_api_tools ;;
                5) call_docker_install ;;
                6) show_help ;;
                0) break ;;
                *)
                    echo -e "${CYBER_RED}✘ Opção inválida!${RESET}"
                    sleep 1
                    ;;
            esac
            [[ "$choice" != "0" ]] && read -p $'\e[1;36m  Pressione ENTER para continuar...\e[0m'
        done
    else
        # Modo direto
        process_command "$@"
    fi
}

# ==========================================
# INICIALIZAÇÃO
# ==========================================

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
