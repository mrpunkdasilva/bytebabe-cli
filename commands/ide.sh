#!/bin/bash

# ==========================================
# IDE COMMANDER - CYBERPUNK EDITION
# ==========================================

# Importar módulos
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"
source "${BASE_DIR}/lib/ide/ide_services.sh"

# ==========================================
# CONSTANTES
# ==========================================
declare -A IDE_MAP=(
    ["vscode"]="Visual Studio Code"
    ["zed"]="Zed Editor"
    ["sublime"]="Sublime Text"
    ["toolbox"]="JetBrains Toolbox"
    ["intellij"]="IntelliJ IDEA"
    ["pycharm"]="PyCharm"
    ["clion"]="CLion"
    ["all"]="TODAS AS IDES"
)

declare -A RUN_IDS=(
    ["code"]="com.visualstudio.code"
    ["zed"]="dev.zed.Zed"
    ["sublime"]="com.sublimetext.three"
    ["intellij"]="com.jetbrains.IntelliJ-IDEA-Community"
    ["pycharm"]="com.jetbrains.PyCharm-Community"
    ["clion"]="com.jetbrains.CLion"
)

# ==========================================
# INTERFACE DO USUÁRIO
# ==========================================

show_cyber_header() {
    clear
    echo -e "${CYBER_BG_BLACK}${CYBER_PINK}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║   ██╗██████╗ ███████╗  ██████╗ ███████╗     ║"
    echo "║   ██║██╔══██╗██╔════╝ ██╔═══██╗██╔════╝     ║"
    echo "║   ██║██║  ██║█████╗   ██║   ██║█████╗       ║"
    echo "║   ██║██║  ██║██╔══╝   ██║   ██║██╔══╝       ║"
    echo "║   ██║██████╔╝███████╗ ╚██████╔╝███████╗     ║"
    echo "║   ╚═╝╚═════╝ ╚══════╝  ╚═════╝ ╚══════╝     ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
    cyber_divider
}

show_ide_menu() {
    echo -e "${CYBER_BLUE}${CYBER_BOLD}  ⚡ MENU DE IDES DISPONÍVEIS:${RESET}"
    echo ""

    local i=1
    for ide in "${!IDE_MAP[@]}"; do
        if [[ "$ide" != "all" ]]; then
            echo -e "  ${CYBER_PINK}${i}) ${IDE_MAP[$ide]}${RESET}"
            ((i++))
        fi
    done

    echo -e "\n  ${CYBER_RED}9) ${IDE_MAP["all"]}${RESET}"
    echo -e "  ${CYBER_YELLOW}0) Voltar${RESET}"
    echo ""
    cyber_divider
}

show_ide_help() {
    show_cyber_header
    echo -e "${CYBER_BLUE}${CYBER_BOLD}  💻 COMANDOS BÁSICOS:${RESET}"
    echo ""

    for ide in "${!IDE_MAP[@]}"; do
        if [[ "$ide" != "all" ]]; then
            echo -e "  ${CYBER_PINK}${ide}${RESET} ${CYBER_YELLOW}»${RESET} ${CYBER_GREEN}${IDE_MAP[$ide]}${RESET}"
        fi
    done

    echo -e "\n  ${CYBER_PINK}all${RESET} ${CYBER_YELLOW}»${RESET} ${CYBER_RED}${IDE_MAP["all"]}${RESET}"

    echo -e "\n${CYBER_BLUE}${CYBER_BOLD}  🚀 COMANDOS AVANÇADOS:${RESET}"
    echo -e "  ${CYBER_PINK}install <ide>${RESET}  ${CYBER_YELLOW}»${RESET} ${CYBER_GREEN}Instala uma IDE específica${RESET}"
    echo -e "  ${CYBER_PINK}run <ide>${RESET}     ${CYBER_YELLOW}»${RESET} ${CYBER_GREEN}Executa uma IDE${RESET}"
    echo -e "  ${CYBER_PINK}status <ide>${RESET}  ${CYBER_YELLOW}»${RESET} ${CYBER_GREEN}Verifica status da IDE${RESET}"
    echo -e "  ${CYBER_PINK}list${RESET}         ${CYBER_YELLOW}»${RESET} ${CYBER_GREEN}Lista IDEs instaladas${RESET}"

    echo -e "\n${CYBER_BLUE}${CYBER_BOLD}  🛠️  EXEMPLOS:${RESET}"
    echo -e "  ${CYBER_ICON_TERMINAL} ${CYBER_YELLOW}bytebabe ide vscode${RESET}"
    echo -e "  ${CYBER_ICON_TERMINAL} ${CYBER_YELLOW}bytebabe ide run code${RESET}"
    echo -e "  ${CYBER_ICON_TERMINAL} ${CYBER_YELLOW}bytebabe ide status zed${RESET}"
    cyber_divider
}

# ==========================================
# PROCESSAMENTO DE COMANDOS
# ==========================================

process_single_ide() {
    local ide=$1

    case "$ide" in
        vscode) install_vscode ;;
        zed) install_zed ;;
        sublime) install_sublime ;;
        toolbox) install_toolbox ;;
        intellij) install_jetbrains_ide "IntelliJ-IDEA" ;;
        pycharm) install_jetbrains_ide "PyCharm" ;;
        clion) install_jetbrains_ide "CLion" ;;
        *)
            echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}IDE desconhecida: ${ide}${RESET}"
            show_ide_help
            return 1
            ;;
    esac
}

process_advanced_command() {
    local cmd=$1
    local ide=$2

    case "$cmd" in
        install|i|add)
            if [[ -z "$ide" ]]; then
                echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}Especifique uma IDE para instalar${RESET}"
                show_ide_help
                return 1
            fi
            process_single_ide "$ide"
            ;;
        run|r)
            if [[ -z "$ide" ]]; then
                echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}Especifique uma IDE para executar${RESET}"
                echo -e "${CYBER_YELLOW}IDEs disponíveis: ${!RUN_IDS[@]}${RESET}"
                return 1
            fi
            run_ide "$ide"
            ;;
        status|s)
            if [[ -z "$ide" ]]; then
                echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}Especifique uma IDE para verificar${RESET}"
                return 1
            fi
            ide_status "$ide"
            ;;
        list|l)
            list_installed_ides
            ;;
        *)
            echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}Comando desconhecido: ${cmd}${RESET}"
            show_ide_help
            return 1
            ;;
    esac
}

process_interactive_menu() {
    while true; do
        show_cyber_header
        show_ide_menu

        read -p $'\e[1;35m  ⌘ SELECIONE UMA OPÇÃO: \e[0m' choice

        case $choice in
            1) process_single_ide "vscode" ;;
            2) process_single_ide "zed" ;;
            3) process_single_ide "sublime" ;;
            4) process_single_ide "toolbox" ;;
            5) process_single_ide "intellij" ;;
            6) process_single_ide "pycharm" ;;
            7) process_single_ide "clion" ;;
            9)
                echo -e "${CYBER_RED}${CYBER_BOLD}⚠ ATENÇÃO: Isso instalará TODAS as IDES listadas${RESET}"
                read -p $'\e[1;33m  Confirma? (s/N): \e[0m' confirm
                if [[ "$confirm" =~ [sSyY] ]]; then
                    install_all_ides
                fi
                ;;
            0)
                echo -e "${CYBER_BLUE}Retornando ao menu principal...${RESET}"
                sleep 1
                break
                ;;
            *)
                echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}Opção inválida!${RESET}"
                sleep 1
                ;;
        esac

        if [[ "$choice" != "0" ]]; then
            read -p $'\e[1;36m  Pressione ENTER para continuar...\e[0m'
        fi
    done
}

# ==========================================
# FUNÇÃO PRINCIPAL
# ==========================================

main() {
    # Verificar se há argumentos
    if [[ $# -eq 0 ]]; then
        process_interactive_menu
    else
        case "$1" in
            -h|--help|help)
                show_ide_help
                ;;
            install|run|status|list)
                process_advanced_command "$@"
                ;;
            *)
                show_cyber_header
                process_single_ide "$1"
                ;;
        esac
    fi
}

# Iniciar
main "$@"