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
case "$1" in
    containers|container|cont|c)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            show_docker_loading
            echo -e "${CYBER_CYAN}🌊 Container Commander Help 🌊${RESET}"
            echo -e "Control your Docker containers like Poseidon commands the seas"
            echo -e "\n${CYBER_YELLOW}Usage:"
            echo -e "  bytebabe docker containers [options]"
            echo -e "\nOptions:"
            echo -e "  --all      Show all containers (including stopped)"
            echo -e "  --filter   Filter by status (running, exited, paused)"
            echo -e "  --prune    Remove stopped containers"
            echo -e "\nExample:"
            echo -e "  bytebabe docker containers --filter running${RESET}"
        else
            container_commander "${@:2}"
        fi
        ;;

    images|image|img|i)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            show_docker_loading
            echo -e "${CYBER_CYAN}📦 Image Harbor Help 📦${RESET}"
            echo -e "Manage Docker images like treasures in Poseidon's vault"
            echo -e "\n${CYBER_YELLOW}Usage:"
            echo -e "  bytebabe docker images [options]"
            echo -e "\nOptions:"
            echo -e "  --prune    Remove dangling images"
            echo -e "  --all      Show all images (including intermediates)"
            echo -e "\nExample:"
            echo -e "  bytebabe docker images --prune${RESET}"
        else
            image_harbor "${@:2}"
        fi
        ;;

    volumes|volume|vol|v)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            show_docker_loading
            echo -e "${CYBER_CYAN}💾 Volume Bay Help 💾${RESET}"
            echo -e "Manage Docker volumes like the depths of Poseidon's realm"
            echo -e "\n${CYBER_YELLOW}Usage:"
            echo -e "  bytebabe docker volumes [options]"
            echo -e "\nOptions:"
            echo -e "  --prune    Remove unused volumes"
            echo -e "  --size     Show volume sizes"
            echo -e "\nExample:"
            echo -e "  bytebabe docker volumes --prune${RESET}"
        else
            volume_bay "${@:2}"
        fi
        ;;

    compose|comp|com|co)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            show_docker_loading
            echo -e "${CYBER_CYAN}🚢 Compose Captain Help 🚢${RESET}"
            echo -e "Command your Docker fleets like Poseidon guides his ships"
            echo -e "\n${CYBER_YELLOW}Usage:"
            echo -e "  bytebabe docker compose [command]"
            echo -e "\nCommands:"
            echo -e "  up       Start services"
            echo -e "  down     Stop services"
            echo -e "  logs     View service logs"
            echo -e "\nExample:"
            echo -e "  bytebabe docker compose up${RESET}"
        else
            compose_captain "${@:2}"
        fi
        ;;

    clean|clear|cl|cls)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            show_docker_loading
            echo -e "${CYBER_CYAN}🧹 System Cleaner Help 🧹${RESET}"
            echo -e "Purge your Docker realm like Poseidon cleanses the seas"
            echo -e "\n${CYBER_YELLOW}Usage:"
            echo -e "  bytebabe docker clean [options]"
            echo -e "\nOptions:"
            echo -e "  --all      Clean everything"
            echo -e "  --images   Clean only images"
            echo -e "\nExample:"
            echo -e "  bytebabe docker clean --all${RESET}"
        else
            system_cleaner "${@:2}"
        fi
        ;;

    stats|stat|st)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            show_docker_loading
            echo -e "${CYBER_CYAN}📊 Docker Stats Help 📊${RESET}"
            echo -e "Survey your Docker domain like Poseidon watches the oceans"
            echo -e "\n${CYBER_YELLOW}Usage:"
            echo -e "  bytebabe docker stats [options]"
            echo -e "\nOptions:"
            echo -e "  --live    Real-time monitoring (default)"
            echo -e "  --snap    Single snapshot"
            echo -e "\nExample:"
            echo -e "  bytebabe docker stats --live${RESET}"
        else
            docker_stats "${@:2}"
        fi
        ;;

    help|--help|-h|"")
        show_docker_help
        ;;

    *)
        show_docker_loading
        echo -e "${CYBER_RED}Error: Comando desconhecido '$1'${RESET}"
        show_docker_help
        exit 1
        ;;
esac