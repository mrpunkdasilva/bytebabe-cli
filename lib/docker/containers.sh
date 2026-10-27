#!/bin/bash

if [[ "${BASH_SOURCE[0]}" == */* ]]; then
    _bytebabe_docker_containers_dir="${BASH_SOURCE[0]%/*}"
else
    _bytebabe_docker_containers_dir="."
fi
_bytebabe_docker_containers_dir="$(cd -P -- "$_bytebabe_docker_containers_dir" && pwd)"
source "$_bytebabe_docker_containers_dir/../core/helpers.sh"
source "$_bytebabe_docker_containers_dir/ui.sh"
unset _bytebabe_docker_containers_dir

cmd_docker="${cmd_docker:-docker}"
cmd_docker_compose="${cmd_docker_compose:-}"

# Funções para containers
show_container_logs() {
    clear
    echo -e "${CYBER_PURPLE}📜 LOGS DO CONTAINER $1 ${RESET}"
    $cmd_docker logs --tail=50 "$1" | less -R
}

inspect_container() {
    clear
    echo -e "${CYBER_PURPLE}🔍 INSPEÇÃO DO CONTAINER $1 ${RESET}"
    $cmd_docker inspect "$1" | jq . | less -R
}

exec_container_shell() {
    clear
    echo -e "${CYBER_PURPLE}⚡ ACESSANDO O CONTAINER $1 ${RESET}"
    $cmd_docker exec -it "$1" bash || $cmd_docker exec -it "$1" sh
}

remove_container() {
    read -p "${CYBER_RED}⚠️ Confirmar remoção de $1? (y/N): ${RESET}" confirm
    if [[ "$confirm" == [yY] ]]; then
        $cmd_docker rm -f "$1"
    else
        echo -e "${CYBER_YELLOW}▶ Remoção cancelada${RESET}"
    fi
}

# Verifica se é container do Compose
is_compose_container() {
    local container=$1
    $cmd_docker inspect "$container" --format '{{index .Config.Labels "com.docker.compose.project"}}' | grep -q .
}

# Obtém info do Compose
get_compose_info() {
    local container=$1
    local project=$($cmd_docker inspect "$container" --format '{{index .Config.Labels "com.docker.compose.project"}}')
    local service=$($cmd_docker inspect "$container" --format '{{index .Config.Labels "com.docker.compose.service"}}')
    echo "$project $service"
}

# Verifica se é um serviço web (Nginx/Apache)
is_web_service() {
    local service=$1
    [[ "$service" =~ nginx|apache|httpd ]]
}

show_container_actions() {
    local container=$1
    local compose_project=""
    local compose_service=""

    if is_compose_container "$container"; then
        read -r compose_project compose_service <<< $(get_compose_info "$container")
    fi

    while true; do
        if ! $cmd_docker inspect "$container" &>/dev/null; then
            echo -e "${CYBER_RED}Container não encontrado!${RESET}"
            read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
            return
        fi

        if [ -n "$compose_project" ]; then
            echo -e "${CYBER_YELLOW}ℹ Projeto: ${CYBER_CYAN}$compose_project${CYBER_YELLOW} (Serviço: ${CYBER_CYAN}$compose_service${CYBER_YELLOW})${RESET}"

            if is_web_service "$compose_service"; then
                echo -e "${CYBER_BLUE}💡 Dica: Verifique os volumes de configuração no docker-compose.yml${RESET}"
                echo -e "${CYBER_BLUE}💡 Comandos úteis:"
                echo -e "  - ${CYBER_CYAN}docker compose exec $compose_service nginx -t${RESET} (testar configuração Nginx)"
                echo -e "  - ${CYBER_CYAN}docker compose logs $compose_service${RESET} (ver logs)"
            fi
        fi

        echo
        local actions=(
            "🚀 Iniciar"
            "⏹️ Parar"
            "🔁 Reiniciar"
            "📝 Logs"
            "🔍 Inspecionar"
            "⚡ Acessar Shell"
            "🗑️ Remover"
            "⬅ Voltar"
        )

        choose_from_menu "Ação para $container:" action "${actions[@]}"
        [[ "$action" == "⬅ Voltar" ]] && return

        case $action in
            *Iniciar*)
                if [ -n "$compose_project" ]; then
                    $cmd_docker_compose -p "$compose_project" up -d "$compose_service"
                else
                    $cmd_docker start "$container"
                fi
                ;;
            *Parar*)
                if [ -n "$compose_project" ]; then
                    $cmd_docker_compose -p "$compose_project" stop "$compose_service"
                else
                    $cmd_docker stop "$container"
                fi
                ;;
            *Reiniciar*)
                if [ -n "$compose_project" ]; then
                    $cmd_docker_compose -p "$compose_project" restart "$compose_service"
                else
                    $cmd_docker restart "$container"
                fi
                ;;
            *Logs*) show_container_logs "$container" ;;
            *Inspecionar*) inspect_container "$container" ;;
            *Acessar*) exec_container_shell "$container" ;;
            *Remover*) remove_container "$container" ;;
        esac
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
    done
}

# Lista todos os containers
list_all_containers() {
    while true; do
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ LISTA DE CONTAINERS ▓▓${RESET}"

        local containers=()
        local real_names=()

        if ! containers_list=$($cmd_docker ps -a --format "{{.Names}} ({{.Status}})" 2>&1 | sort); then
            echo -e "${CYBER_RED}Erro ao listar containers:${RESET}"
            echo -e "${containers_list}"
            read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
            return 1
        fi

        while IFS= read -r line; do
            real_names+=("$(echo "$line" | awk '{print $1}')")
            containers+=("$(format_container_info "$line")")
        done <<< "$containers_list"

        if [ ${#containers[@]} -eq 0 ]; then
            echo -e "${CYBER_YELLOW}Nenhum container encontrado${RESET}"
            read -n 1 -s -r -p "Pressione qualquer tecla para voltar..."
            return
        fi

        choose_from_menu "Selecione um container:" selected_container "${containers[@]}" "⬅ Voltar"
        [[ "$selected_container" == "⬅ Voltar" ]] && return

        local index=0
        for container in "${containers[@]}"; do
            if [ "$container" == "$selected_container" ]; then
                show_container_actions "${real_names[$index]}"
                break
            fi
            ((index++))
        done
    done
}

# Lista containers em execução
list_running_containers() {
    while true; do
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ CONTAINERS EM EXECUÇÃO ▓▓${RESET}"

        local containers=()
        local real_names=()

        if ! containers_list=$($cmd_docker ps --format "{{.Names}} ({{.Status}})" 2>&1 | sort); then
            echo -e "${CYBER_RED}Erro ao listar containers:${RESET}"
            echo -e "${containers_list}"
            read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
            return 1
        fi

        while IFS= read -r line; do
            real_names+=("$(echo "$line" | awk '{print $1}')")
            containers+=("$(format_container_info "$line")")
        done <<< "$containers_list"

        if [ ${#containers[@]} -eq 0 ]; then
            echo -e "${CYBER_YELLOW}Nenhum container em execução${RESET}"
            read -n 1 -s -r -p "Pressione qualquer tecla para voltar..."
            return
        fi

        choose_from_menu "Selecione um container:" selected_container "${containers[@]}" "⬅ Voltar"
        [[ "$selected_container" == "⬅ Voltar" ]] && return

        local index=0
        for container in "${containers[@]}"; do
            if [ "$container" == "$selected_container" ]; then
                show_container_actions "${real_names[$index]}"
                break
            fi
            ((index++))
        done
    done
}

# Pesquisa containers por nome
search_containers() {
    show_docker_header
    echo -e "${CYBER_PURPLE}▓▓ PESQUISAR CONTAINERS ▓▓${RESET}"
    read -p "Digite parte do nome do container: " search_term

    local containers=()
    local real_names=()

    if ! containers_list=$($cmd_docker ps -a --format "{{.Names}} ({{.Status}})" 2>&1 | grep -i "$search_term" | sort); then
        echo -e "${CYBER_YELLOW}Nenhum container encontrado com '$search_term'${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return
    fi

    while IFS= read -r line; do
        real_names+=("$(echo "$line" | awk '{print $1}')")
        containers+=("$(format_container_info "$line")")
    done <<< "$containers_list"

    if [ ${#containers[@]} -eq 0 ]; then
        echo -e "${CYBER_YELLOW}Nenhum container encontrado com '$search_term'${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return
    fi

    choose_from_menu "Resultados para '$search_term':" selected_container "${containers[@]}" "⬅ Voltar"
    [[ "$selected_container" == "⬅ Voltar" ]] && return

    local index=0
    for container in "${containers[@]}"; do
        if [ "$container" == "$selected_container" ]; then
            show_container_actions "${real_names[$index]}"
            break
        fi
        ((index++))
    done
}

# Cria um novo container
create_container() {
    show_docker_header
    echo -e "${CYBER_PURPLE}▓▓ CRIAR NOVO CONTAINER ▓▓${RESET}"

    read -p "Nome do container: " container_name
    read -p "Imagem Docker (ex: nginx:latest): " image_name
    read -p "Portas (ex: 80:80): " ports
    read -p "Variáveis de ambiente (ex: VAR=valor): " env_vars
    read -p "Volumes (ex: /local:/container): " volumes

    local -a create_args
    read -r -a create_args <<< "$cmd_docker"
    create_args+=(run -d --name "$container_name")

    if [ -n "$ports" ]; then
        create_args+=(-p "$ports")
    fi

    if [ -n "$env_vars" ]; then
        create_args+=(-e "$env_vars")
    fi

    if [ -n "$volumes" ]; then
        create_args+=(-v "$volumes")
    fi

    create_args+=("$image_name")

    echo -e "${CYBER_BLUE}▶ Comando a ser executado:${RESET}"
    echo -e "${CYBER_CYAN}${create_args[*]}${RESET}"
    read -p "Confirmar criação? (y/N): " confirm

    if [[ "$confirm" == [yY] ]]; then
        "${create_args[@]}"
    else
        echo -e "${CYBER_YELLOW}Criação cancelada${RESET}"
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

# Mostra estatísticas dos containers
show_container_stats() {
    local pause=1

    if [[ "${1:-}" == "--no-pause" ]]; then
        pause=0
    fi

    show_docker_header
    echo -e "${CYBER_PURPLE}▓▓ ESTATÍSTICAS DOS CONTAINERS ▓▓${RESET}"
    $cmd_docker stats --no-stream
    echo -e "\n${CYBER_BLUE}▶ Uso de disco:${RESET}"
    $cmd_docker system df

    if (( pause )); then
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
    fi
}

# Lista containers em modo não interativo
list_containers_table() {
    local mode="all"
    local arg
    local args=(ps)

    for arg in "$@"; do
        case "$arg" in
            -a|--all) mode="all" ;;
            -r|--running) mode="running" ;;
            *)
                echo "Opção inválida para containers: $arg" >&2
                return 1
                ;;
        esac
    done

    if [[ "$mode" == "all" ]]; then
        args+=(-a)
    fi
    args+=(--format "table {{.Names}}\t{{.Status}}\t{{.Image}}")

    $cmd_docker "${args[@]}"
}

container_action() {
    local action="$1"
    shift

    if (($# == 0)); then
        echo "Informe ao menos um container para $action" >&2
        return 1
    fi

    $cmd_docker "$action" "$@"
}

remove_containers() {
    local container

    if (($# == 0)); then
        echo "Informe ao menos um container para remover" >&2
        return 1
    fi

    for container in "$@"; do
        remove_container "$container" || return 1
    done
}

handle_container_command() {
    local action="${1:-}"

    if (($# > 0)); then
        shift
    fi

    case "$action" in
        ls|list)
            list_containers_table "$@"
            ;;
        running|ps)
            list_containers_table --running
            ;;
        start|stop|restart)
            container_action "$action" "$@"
            ;;
        rm|remove)
            remove_containers "$@"
            ;;
        logs)
            if (($# == 0)); then
                echo "Informe o container para ver os logs" >&2
                return 1
            fi
            show_container_logs "$1"
            ;;
        inspect)
            if (($# == 0)); then
                echo "Informe o container para inspecionar" >&2
                return 1
            fi
            inspect_container "$1"
            ;;
        shell|exec)
            if (($# == 0)); then
                echo "Informe o container para acessar" >&2
                return 1
            fi
            exec_container_shell "$1"
            ;;
        stats)
            show_container_stats --no-pause
            ;;
        create)
            create_container
            ;;
        help|--help|-h)
            show_docker_help
            ;;
        "")
            main_menu
            ;;
        *)
            echo "Comando de container inválido: $action" >&2
            show_docker_help
            return 1
            ;;
    esac
}

# Menu principal
main_menu() {
    while true; do
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ MENU PRINCIPAL ▓▓${RESET}"

        local options=(
            "📋 Listar todos os containers"
            "🟢 Listar containers em execução"
            "🔍 Pesquisar containers"
            "🆕 Criar novo container"
            "📊 Estatísticas do sistema"
            "🚪 Sair"
        )

        choose_from_menu "Selecione uma opção:" choice "${options[@]}"

        case $choice in
            *todos*) list_all_containers ;;
            *execução*) list_running_containers ;;
            *Pesquisar*) search_containers ;;
            *novo*) create_container ;;
            *Estatísticas*) show_container_stats ;;
            *Sair*) return 0 ;;
        esac
    done
}

# Ponto de entrada principal
container_commander() {
    if (($# > 0)); then
        case "$1" in
            help|--help|-h)
                handle_container_command "$@"
                return $?
                ;;
        esac
    fi

    check_docker_dependencies
    cmd_docker_compose="${cmd_docker_compose:-$cmd_docker compose}"

    if (($# > 0)); then
        handle_container_command "$@"
        return $?
    fi

    main_menu
}

