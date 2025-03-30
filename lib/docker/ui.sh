#!/bin/bash

# Header ASCII Art
show_docker_header() {
    clear
    echo -e "${CYBER_BLUE}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║  ▓▓▓ DOCKER NAVIGATOR ▓▓▓                    ║"
    echo "  ║                                              ║"
    echo "  ║  🐋  Manage containers, images and volumes   ║"
    echo "  ║  🚀  Docker Compose utilities                ║"
    echo "  ║  ⚡  System monitoring and cleanup           ║"
    echo "  ╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

# Animação temática Docker
show_docker_loading() {
    local pid=$!
    local message=$1
    local delay=0.15
    local spin_chars=('🐳 ' '⚓ ' '🚢 ' '🌊 ' '🌀 ' '🔹 ' '🔷 ' '🔵 ')
    local i=0

    printf "${CYBER_BLUE}${message}${RESET} "
    while kill -0 $pid 2>/dev/null; do
        printf "\b${spin_chars[i]}"
        i=$(( (i+1) % 8 ))
        sleep $delay
    done
    printf "\b\b\b   \b\b\b\n"
}

# Menu principal
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
            exit 0
            ;;
    esac
}