#!/bin/bash

# Load core functions and variables
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"

# Docker command with proper permissions
cmd_docker="docker"
if ! docker ps >/dev/null 2>&1; then
    cmd_docker="sudo docker"
fi

# Função para processar comandos de volumes
handle_volume_command() {
    local subcommand="$1"
    shift

    case "$subcommand" in
        "list"|"ls")
            $cmd_docker volume ls
            ;;
        "create"|"new")
            if [ -z "$1" ]; then
                echo -e "${CYBER_RED}Erro: Especifique um nome para o volume${RESET}"
                echo -e "Exemplo: ${CYBER_CYAN}bytebabe docker volumes create meu-volume${RESET}"
                return 1
            fi
            $cmd_docker volume create "$1"
            ;;
        "inspect"|"i")
            if [ -z "$1" ]; then
                echo -e "${CYBER_RED}Erro: Especifique um volume para inspecionar${RESET}"
                echo -e "Exemplo: ${CYBER_CYAN}bytebabe docker volumes inspect meu-volume${RESET}"
                return 1
            fi
            $cmd_docker volume inspect "$1"
            ;;
        "remove"|"rm")
            if [ -z "$1" ]; then
                echo -e "${CYBER_RED}Erro: Especifique um volume para remover${RESET}"
                echo -e "Exemplo: ${CYBER_CYAN}bytebabe docker volumes remove meu-volume${RESET}"
                return 1
            fi
            $cmd_docker volume rm "$1"
            ;;
        "prune"|"clean")
            echo -e "${CYBER_YELLOW}Removendo volumes não utilizados...${RESET}"
            $cmd_docker volume prune -f
            ;;
        *)
            echo -e "${CYBER_YELLOW}⚡ ${CYBER_BLUE}VOLUME COMMANDS:${RESET}"
            echo -e "  ${CYBER_GREEN}list${RESET}, ${CYBER_GREEN}ls${RESET}       List all volumes"
            echo -e "  ${CYBER_GREEN}create${RESET}, ${CYBER_GREEN}new${RESET}    Create a new volume"
            echo -e "  ${CYBER_GREEN}inspect${RESET}, ${CYBER_GREEN}i${RESET}     Inspect a volume"
            echo -e "  ${CYBER_GREEN}remove${RESET}, ${CYBER_GREEN}rm${RESET}     Remove a volume"
            echo -e "  ${CYBER_GREEN}prune${RESET}, ${CYBER_GREEN}clean${RESET}   Remove unused volumes"
            ;;
    esac
}