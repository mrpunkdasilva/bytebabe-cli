#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"

# Carrega módulos Docker
source "$BASE_DIR/lib/docker/ui.sh"
source "$BASE_DIR/lib/docker/helpers.sh"
source "$BASE_DIR/lib/docker/containers.sh"
source "$BASE_DIR/lib/docker/images.sh"
source "$BASE_DIR/lib/docker/volumes.sh"
source "$BASE_DIR/lib/docker/compose.sh"
source "$BASE_DIR/lib/docker/utils.sh"

# Verify Docker is ready
check_docker_daemon


# Main command processor
handle_container_command() {
    local subcmd="$1"
    shift

    case "$subcmd" in
        "list"|"ls"|"l")
            list_containers "$@"
            ;;
        "start"|"up"|"u")
            start_container "$@"
            ;;
        # ... outros casos
    esac
}

# Função principal que processa os comandos
main() {
    local command="$1"
    shift

    # Estilo 1: Verboso (docker containers list --all)
    # Estilo 2: Curto (docker c ls -a)
    case "$command" in
        # Estilo verboso para containers
        "containers"|"container")
            handle_container_command "$@"
            ;;
        # Alias curto para containers
        "c"|"cont")
            handle_container_command "$@"
            ;;

        # Estilo verboso para imagens
        "images"|"image")
            handle_image_command "$@"
            ;;
        # Alias curto para imagens
        "i"|"img")
            handle_image_command "$@"
            ;;

        # Estilo verboso para volumes
        "volumes"|"volume")
            handle_volume_command "$@"
            ;;
        # Alias curto para volumes
        "v"|"vol")
            handle_volume_command "$@"
            ;;

        # Estilo verboso para compose
        "compose")
            handle_compose_command "$@"
            ;;
        # Alias curto para compose
        "co"|"comp")
            handle_compose_command "$@"
            ;;

        *)
            echo "Comando inválido: $command"
            show_help
            exit 1
            ;;
    esac
}

# Inicializa o script
main "$@"
