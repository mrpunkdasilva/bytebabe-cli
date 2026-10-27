#!/bin/bash

if [[ -z "${CYBER_BLUE:-}" ]]; then
    if [[ "${BASH_SOURCE[0]}" == */* ]]; then
        _bytebabe_docker_ui_dir="${BASH_SOURCE[0]%/*}"
    else
        _bytebabe_docker_ui_dir="."
    fi
    _bytebabe_docker_ui_dir="$(cd -P -- "$_bytebabe_docker_ui_dir" && pwd)"
    source "$_bytebabe_docker_ui_dir/../core/helpers.sh"
    unset _bytebabe_docker_ui_dir
fi

show_docker_header() {
    clear
    echo -e "${CYBER_BLUE}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║  ▓▓▓ DOCKER NAVIGATOR ▓▓▓                    ║"
    echo "  ║                                              ║"
    echo "  ║  🐋  Manage containers, images and volumes   ║"
    echo "  ║  🚀  Docker Compose utilities                ║"
    echo "  ║  ⚡  System monitoring and cleanup            ║"
    echo "  ╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

show_poseidon_header() {
    echo -e "$CYBER_BLUE
                                                           #       
                                                           ##      
    ####### #######     #### ######## ### ####### #######  ###  ## 
          ##      ##   ###            ###       ##      ## #### ## 
     ######  ##   ##   ###    ####### ###  ###  ## ##   ## ####### 
     ###     ##   ##   ###    ###     ###  ###  ## ##   ## ### ### 
     ###      ##### #####     ####### ###  ######   #####  ###  ## 
                                                                 # 

    ${CYBER_CYAN}⊳ Poderes do Deus dos Mares sobre seus containers ⊲ $CYBER_BLUE $RESET
    ══════════════════════════════════════════════════════════════

    "
}

show_docker_help() {
    show_poseidon_header

    echo -e "${BOLD}${CYBER_GREEN}USO:${RESET}"
    echo -e "  bytebabe docker ${CYBER_YELLOW}[comando] [opções]${RESET}"
    echo

    echo -e "${BOLD}${CYBER_GREEN}TRIDENTE DE COMANDOS:${RESET}"
    echo -e "  ${CYBER_GREEN}containers${RESET}    🐳  Domine seus containers (ls/start/stop/rm/logs/inspect/shell)"
    echo -e "  ${CYBER_GREEN}images${RESET}       📦  Controle as imagens como ondas"
    echo -e "  ${CYBER_GREEN}volumes${RESET}      💾  Profundezas do armazenamento"
    echo -e "  ${CYBER_GREEN}compose${RESET}      🌊  Comande frotas de serviços"
    echo -e "  ${CYBER_GREEN}clean${RESET}        🧹  Limpeza do templo submarino"
    echo -e "  ${CYBER_GREEN}stats${RESET}        📊  Visão do reino"
    echo -e "  ${CYBER_GREEN}help${RESET}         ❓  Sabedoria de Poseidon"
    echo

    echo -e "${BOLD}${CYBER_GREEN}SACRIFÍCIOS (EXEMPLOS):${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe docker containers${RESET}       # Menu interativo"
    echo -e "  ${CYBER_YELLOW}bytebabe docker c ls -a${RESET}          # Lista sem menu"
    echo -e "  ${CYBER_YELLOW}bytebabe docker compose up${RESET}       # Libere a fúria dos mares"
    echo

    echo -e "${BOLD}${CYBER_GREEN}PROFECIAS (DICAS):${RESET}"
    echo -e "  ${CYBER_BLUE}•${RESET} ${CYBER_YELLOW}--help${RESET} para invocar sabedoria específica"
    echo -e "  ${CYBER_BLUE}•${RESET} O Tridente (TAB) completa seus comandos"
    echo -e "  ${CYBER_BLUE}•${RESET} ${CYBER_YELLOW}Ctrl+C${RESET} para acalmar as tempestades (sair)"
}

format_container_info() {
    local full_line="$1"
    local status
    local color
    local container_name

    status=$(echo "$full_line" | awk '{print $2}')
    container_name=$(echo "$full_line" | awk '{print $1}')

    case $status in
        *running*) color="${CYBER_GREEN}" ;;
        *exited*) color="${CYBER_RED}" ;;
        *paused*) color="${CYBER_YELLOW}" ;;
        *Created*) color="${CYBER_BLUE}" ;;
        *) color="${CYBER_PURPLE}" ;;
    esac

    echo -e "${color}${container_name}${RESET} (${full_line#* })"
}

show_main_menu() {
    local selections=(
        "${BOLD}${CYBER_GREEN}1) 🐳 Container Commander   ${CYBER_YELLOW}» Manage running containers${RESET}"
        "${BOLD}${CYBER_GREEN}2) 📦 Image Harbor          ${CYBER_YELLOW}» Image management${RESET}"
        "${BOLD}${CYBER_GREEN}3) 💾 Volume Bay            ${CYBER_YELLOW}» Storage volume control${RESET}"
        "${BOLD}${CYBER_GREEN}4) 🚢 Compose Captain       ${CYBER_YELLOW}» Docker compose control${RESET}"
        "${BOLD}${CYBER_GREEN}5) 🧹 System Cleaner        ${CYBER_YELLOW}» Prune unused resources${RESET}"
        "${BOLD}${CYBER_GREEN}6) 📊 Docker Stats          ${CYBER_YELLOW}» Live system monitoring${RESET}"
        "${BOLD}${CYBER_RED}0) 🚪 Exit                 ${CYBER_YELLOW}» Quit Docker Navigator${RESET}"
    )

    choose_from_menu "Select an operation:" selected_choice "${selections[@]}"

    case "$selected_choice" in
        *"Container Commander"*) container_commander ;;
        *"Image Harbor"*) image_harbor ;;
        *"Volume Bay"*) volume_bay ;;
        *"Compose Captain"*) compose_captain ;;
        *"System Cleaner"*) system_cleaner ;;
        *"Docker Stats"*) docker_stats ;;
        *"Exit"*)
            echo -e "${CYBER_BLUE}🐳 Happy sailing! ${RESET}"
            return 0
            ;;
    esac
}
