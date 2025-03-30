#!/bin/bash

container_commander() {
    while true; do
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ CONTAINER COMMANDER ▓▓${RESET}"

        local containers=()
        while IFS= read -r line; do
            containers+=("$(format_container_info "$line")")
        done < <(docker ps -a --format "{{.Names}}" | sort)

        if [ ${#containers[@]} -eq 0 ]; then
            echo -e "${CYBER_YELLOW}No containers found${RESET}"
            read -n 1 -s -r -p "Press any key to return..."
            return
        fi

        choose_from_menu "Select container:" container "${containers[@]}" "⬅ Back"

        [[ "$container" == "⬅ Back" ]] && return

        local container_name=$(echo "$container" | sed -E 's/\x1B\[[0-9;]*[mGK]//g' | awk '{print $1}')

        show_container_actions "$container_name"
    done
}

show_container_actions() {
    local container=$1

    echo
    local actions=(
        "🚀 Start"
        "⏹️ Stop"
        "🔁 Restart"
        "📝 Logs"
        "🔍 Inspect"
        "⚡ Exec bash"
        "🗑️ Remove"
    )

    choose_from_menu "Action for $container:" action "${actions[@]}"

    case $action in
        *Start*) docker start "$container" & show_docker_loading "Starting $container" ;;
        *Stop*) docker stop "$container" & show_docker_loading "Stopping $container" ;;
        *Restart*) docker restart "$container" & show_docker_loading "Restarting $container" ;;
        *Logs*) show_container_logs "$container" ;;
        *Inspect*) inspect_container "$container" ;;
        *Exec*) exec_container_shell "$container" ;;
        *Remove*) remove_container "$container" ;;
    esac
}

show_container_logs() {
    clear
    echo -e "${CYBER_PURPLE}📜 LOGS FOR $1 ${RESET}"
    docker logs --tail=50 "$1" | less -R
}

inspect_container() {
    clear
    echo -e "${CYBER_PURPLE}🔍 INSPECT $1 ${RESET}"
    docker inspect "$1" | jq . | less -R
}

exec_container_shell() {
    clear
    echo -e "${CYBER_PURPLE}⚡ ENTERING $1 ${RESET}"
    docker exec -it "$1" bash || docker exec -it "$1" sh
}

remove_container() {
    read -p "${CYBER_RED}⚠️ Really remove $1? (y/N): ${RESET}" confirm
    [[ "$confirm" == "y" ]] && docker rm -f "$1" & show_docker_loading "Removing $1"
}