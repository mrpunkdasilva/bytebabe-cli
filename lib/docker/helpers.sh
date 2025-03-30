#!/bin/bash

# Verifica se Docker está rodando
check_docker_daemon() {
    if ! docker ps >/dev/null 2>&1; then
        echo -e "${CYBER_RED}🐳 Docker daemon is not running!${RESET}"
        read -p "${CYBER_BLUE}? Start Docker service? (Y/n): ${RESET}" choice
        if [[ ! "$choice" =~ ^[Nn]$ ]]; then
            sudo systemctl start docker & show_docker_loading "Starting Docker"
        else
            exit 1
        fi
    fi
}

# Formata saida do docker ps
format_container_info() {
    local container=$1
    local status=$(docker inspect --format '{{.State.Status}}' "$container")
    local color

    case $status in
        running) color="${CYBER_GREEN}" ;;
        exited) color="${CYBER_RED}" ;;
        paused) color="${CYBER_YELLOW}" ;;
        *) color="${CYBER_BLUE}" ;;
    esac

    echo "${color}${container}${RESET}"
}

# Filtra containers por status
filter_containers_by_status() {
    local status=$1
    docker ps --filter "status=$status" --format "{{.Names}}" | sort
}