#!/bin/bash

if [ -z "$BASE_DIR" ]; then
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

source "${BASE_DIR}/lib/docker/ui.sh"
source "${BASE_DIR}/lib/docker/helpers.sh"
source "${BASE_DIR}/lib/docker/containers.sh"
source "${BASE_DIR}/lib/docker/images.sh"
source "${BASE_DIR}/lib/docker/volumes.sh"
source "${BASE_DIR}/lib/docker/compose.sh"
source "${BASE_DIR}/lib/docker/utils.sh"

main() {
    local command="${1:-}"

    if (($# > 0)); then
        shift
    fi

    case "$command" in
        help|--help|-h|"")
            show_docker_help
            return 0
            ;;
        containers|c|cont)
            case "${1:-}" in
                help|--help|-h)
                    container_commander "$@"
                    return $?
                    ;;
            esac
            ;;
        images|image|i|img)
            case "${1:-}" in
                help|--help|-h)
                    image_harbor "$@"
                    return $?
                    ;;
            esac
            ;;
        compose|co)
            case "${1:-}" in
                help|--help|-h|"")
                    handle_compose_command "$@"
                    return $?
                    ;;
            esac
            ;;
        volumes|volume|v|vol)
            case "${1:-}" in
                help|--help|-h)
                    volume_commander "$@"
                    return $?
                    ;;
            esac
            ;;
    esac

    if ! configure_docker; then
        return 1
    fi

    case "$command" in
        containers|c|cont)
            container_commander "$@"
            ;;
        images|image|i|img)
            image_harbor "$@"
            ;;
        volumes|volume|v|vol)
            volume_commander "$@"
            ;;
        compose|co)
            handle_compose_command "$@"
            ;;
        clean)
            system_cleaner
            ;;
        stats)
            docker_stats
            ;;
        *)
            echo -e "${CYBER_RED}Comando inválido: $command${RESET}"
            show_docker_help
            return 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
