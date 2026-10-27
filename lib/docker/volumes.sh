#!/bin/bash

show_volumes_help() {
    echo -e "${CYBER_BLUE}${CYBER_BOLD}DOCKER VOLUMES - GERENCIAMENTO DE VOLUMES${RESET}"
    echo ""
    echo -e "${CYBER_YELLOW}Uso: bytebabe docker volumes <comando>${RESET}"
    echo ""
    echo -e "${CYBER_GREEN}ls|list${RESET}          Lista volumes"
    echo -e "${CYBER_GREEN}create <nome>${RESET}    Cria um volume"
    echo -e "${CYBER_GREEN}inspect <nome>${RESET}   Inspeciona um volume"
    echo -e "${CYBER_GREEN}rm <nome> [-f]${RESET}   Remove um volume"
    echo -e "${CYBER_GREEN}prune [-f]${RESET}       Remove volumes não utilizados"
    echo -e "${CYBER_GREEN}help${RESET}             Exibe esta ajuda"
    echo ""
    echo -e "${CYBER_BLUE}Sem comando, abre o menu interativo de volumes.${RESET}"
}

volume_docker() {
    local -a volume_cmd
    read -r -a volume_cmd <<< "${cmd_docker:-docker}"
    volume_cmd+=(volume "$@")
    "${volume_cmd[@]}"
}

validate_volume_name() {
    local name="${1:-}"
    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome do volume é obrigatório${RESET}"
        return 1
    fi
    if [[ ! "$name" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*$ ]]; then
        echo -e "${CYBER_RED}✘ Nome de volume inválido: $name${RESET}"
        return 1
    fi
}

list_volumes() {
    if [[ "${1:-}" == "-q" || "${1:-}" == "--quiet" ]]; then
        volume_docker ls --quiet
        return $?
    fi

    volume_docker ls
}

create_volume() {
    local name="${1:-}"
    validate_volume_name "$name" || return 1
    volume_docker create "$name"
}

inspect_volume() {
    local name="${1:-}"
    validate_volume_name "$name" || return 1
    volume_docker inspect "$name"
}

remove_volume() {
    local name=""
    local force=0
    local arg

    for arg in "$@"; do
        case "$arg" in
            -f|--force) force=1 ;;
            *) name="$arg" ;;
        esac
    done

    validate_volume_name "$name" || return 1

    if (( force == 0 )); then
        local confirm
        read -r -p "Remover o volume '$name'? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[yY]$ ]]; then
            echo -e "${CYBER_YELLOW}Remoção cancelada${RESET}"
            return 0
        fi
    fi

    volume_docker rm "$name"
}

prune_volumes() {
    local force=0
    local arg

    for arg in "$@"; do
        case "$arg" in
            -f|--force) force=1 ;;
            *) ;;
        esac
    done

    if (( force == 0 )); then
        local confirm
        read -r -p "Remover todos os volumes não utilizados? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[yY]$ ]]; then
            echo -e "${CYBER_YELLOW}Limpeza cancelada${RESET}"
            return 0
        fi
    fi

    volume_docker prune --force
}

volume_bay() {
    while true; do
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ VOLUME BAY ▓▓${RESET}"
        list_volumes || return $?

        local options=(
            "Listar volumes"
            "Criar volume"
            "Inspecionar volume"
            "Remover volume"
            "Prune de volumes"
            "⬅ Voltar"
        )
        local action=""
        choose_from_menu "Selecione uma ação:" action "${options[@]}"

        case "$action" in
            "Listar volumes")
                read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
                ;;
            "Criar volume")
                local name
                read -r -p "Nome do volume: " name
                create_volume "$name" || true
                read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
                ;;
            "Inspecionar volume")
                local name
                read -r -p "Nome do volume: " name
                inspect_volume "$name" | less || true
                read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
                ;;
            "Remover volume")
                local name
                read -r -p "Nome do volume: " name
                remove_volume "$name" || true
                read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
                ;;
            "Prune de volumes")
                prune_volumes || true
                read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
                ;;
            "⬅ Voltar"|"")
                return 0
                ;;
        esac
    done
}

volume_commander() {
    local action="${1:-}"

    case "$action" in
        ""|menu)
            volume_bay
            ;;
        help|--help|-h)
            show_volumes_help
            ;;
        ls|list)
            shift
            list_volumes "$@"
            ;;
        create|add)
            shift
            create_volume "$@"
            ;;
        inspect|show)
            shift
            inspect_volume "$@"
            ;;
        rm|remove)
            shift
            remove_volume "$@"
            ;;
        prune|clean)
            shift
            prune_volumes "$@"
            ;;
        *)
            echo -e "${CYBER_RED}✘ Ação de volume inválida: $action${RESET}"
            show_volumes_help
            return 1
            ;;
    esac
}
