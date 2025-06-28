#!/bin/bash

# Set BASE_DIR if not already set (for direct execution)
if [ -z "$BASE_DIR" ]; then
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

# Carrega módulos Docker
source "${BASE_DIR}/lib/docker/ui.sh"
source "${BASE_DIR}/lib/docker/helpers.sh"
source "${BASE_DIR}/lib/docker/containers.sh"
source "${BASE_DIR}/lib/docker/images.sh"
source "${BASE_DIR}/lib/docker/volumes.sh"
source "${BASE_DIR}/lib/docker/compose.sh"

# Verify Docker is ready
check_docker_daemon


# Função principal que processa os comandos
main() {
    local command="$1"
    shift

    # Estilo 1: Verboso (docker containers list --all)
    # Estilo 2: Curto (docker c ls -a)
    case "$command" in
        # Estilo verboso para containers
        "containers"|"c")
            container_commander "$@"
            ;;
        # Alias curto para containers
        "c"|"cont")
            container_commander "$@"
            ;;

        # Estilo verboso para imagens
        "images"|"image")
            image_harbor "$@"
            ;;
        # Alias curto para imagens
        "i"|"img")
            image_harbor "$@"
            ;;

        # Estilo verboso para volumes
        "volumes"|"volume")
            echo -e "${CYBER_YELLOW}Volume management not yet implemented${RESET}"
            ;;
        # Alias curto para volumes
        "v"|"vol")
            echo -e "${CYBER_YELLOW}Volume management not yet implemented${RESET}"
            ;;

        # Estilo verboso para compose
        "compose"|"co")
            handle_compose_command "$@"
            ;;

        *)
            echo "Comando inválido: $command"
            show_docker_help
            exit 1
            ;;
    esac
}

# Inicializa o script
main "$@"
