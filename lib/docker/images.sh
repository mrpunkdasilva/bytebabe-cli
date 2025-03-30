#!/bin/bash

image_harbor() {
    while true; do
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ IMAGE HARBOR ▓▓${RESET}"

        local images=($(docker images --format "{{.Repository}}:{{.Tag}} ({{.Size}})" | sort))
        choose_from_menu "Select image:" image "${images[@]}" "⬅ Back"

        [[ "$image" == "⬅ Back" ]] && return

        local image_name=$(echo "$image" | awk -F'[: ]' '{print $1":"$2}')
        show_image_actions "$image_name"
    done
}

show_image_actions() {
    local image=$1

    echo
    local actions=(
        "🔍 Inspect"
        "🚀 Run"
        "🏷️ Tag"
        "📤 Push"
        "📥 Pull"
        "🗑️ Remove"
    )

    choose_from_menu "Action for $image:" action "${actions[@]}"

    case $action in
        *Inspect*) inspect_image "$image" ;;
        *Run*) run_image "$image" ;;
        *Tag*) tag_image "$image" ;;
        *Push*) push_image "$image" ;;
        *Pull*) pull_image "$image" ;;
        *Remove*) remove_image "$image" ;;
    esac
}

# Implemente as demais funções seguindo o mesmo padrão...