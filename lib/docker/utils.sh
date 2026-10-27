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

    local pid

    case $action in
        *containers*)
            $cmd_docker container prune -f &
            pid=$!
            show_loading "$pid" "Cleaning containers"
            ;;
        *images*)
            $cmd_docker image prune -af &
            pid=$!
            show_loading "$pid" "Cleaning images"
            ;;
        *volumes*)
            $cmd_docker volume prune -f &
            pid=$!
            show_loading "$pid" "Cleaning volumes"
            ;;
        *networks*)
            $cmd_docker network prune -f &
            pid=$!
            show_loading "$pid" "Cleaning networks"
            ;;
        *everything*)
            $cmd_docker system prune -af &
            pid=$!
            show_loading "$pid" "Nuclear cleanup"
            ;;
    esac
}

docker_stats() {
    clear
    echo -e "${CYBER_PURPLE}▓▓ DOCKER STATS ▓▓${RESET}"
    echo -e "${CYBER_YELLOW}Press Ctrl+C to return to menu${RESET}"
    echo

    watch -n 1 -c "$cmd_docker stats --no-stream --format \
        \"table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}\" | \
        awk 'NR==1 {\$1=\"${CYBER_BLUE}CONTAINER${RESET}\"; \$2=\"${CYBER_GREEN}NAME${RESET}\"; \
        \$3=\"${CYBER_RED}CPU%${RESET}\"; \$4=\"${CYBER_PURPLE}MEM${RESET}\"; \
        \$5=\"${CYBER_CYAN}NET${RESET}\"; \$6=\"${CYBER_YELLOW}BLOCK${RESET}\"; print} \
        NR>1 {print}'"
}