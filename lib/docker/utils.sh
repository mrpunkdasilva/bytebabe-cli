#!/bin/bash

system_cleaner() {
    show_docker_header
    echo -e "${CYBER_PURPLE}▓▓ SYSTEM CLEANER ▓▓${RESET}"

    local actions=(
        "🧹 Prune containers"
        "🧹 Prune images"
        "🧹 Prune volumes"
        "🧹 Prune networks"
        "🧹 Prune everything"
    )

    choose_from_menu "Select cleanup operation:" action "${actions[@]}"

    case $action in
        *containers*) docker container prune -f & show_docker_loading "Cleaning containers" ;;
        *images*) docker image prune -af & show_docker_loading "Cleaning images" ;;
        *volumes*) docker volume prune -f & show_docker_loading "Cleaning volumes" ;;
        *networks*) docker network prune -f & show_docker_loading "Cleaning networks" ;;
        *everything*) docker system prune -af & show_docker_loading "Nuclear cleanup" ;;
    esac
}

docker_stats() {
    clear
    echo -e "${CYBER_PURPLE}▓▓ DOCKER STATS ▓▓${RESET}"
    echo -e "${CYBER_YELLOW}Press Ctrl+C to return to menu${RESET}"
    echo

    watch -n 1 -c "docker stats --no-stream --format \
        \"table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}\" | \
        awk 'NR==1 {\$1=\"${CYBER_BLUE}CONTAINER${RESET}\"; \$2=\"${CYBER_GREEN}NAME${RESET}\"; \
        \$3=\"${CYBER_RED}CPU%${RESET}\"; \$4=\"${CYBER_PURPLE}MEM${RESET}\"; \
        \$5=\"${CYBER_CYAN}NET${RESET}\"; \$6=\"${CYBER_YELLOW}BLOCK${RESET}\"; print} \
        NR>1 {print}'"
}