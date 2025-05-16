#!/bin/bash

# Cores para mensagens
CYBER_RED='\033[38;5;196m'
CYBER_GREEN='\033[38;5;46m'
CYBER_BLUE='\033[38;5;45m'
CYBER_YELLOW='\033[38;5;226m'
CYBER_PURPLE='\033[38;5;129m'
CYBER_CYAN='\033[38;5;51m'
RESET='\033[0m'
BOLD='\033[1m'

# Comandos Docker
cmd_docker="docker"
cmd_docker_compose="docker compose"

# Função para exibir o cabeçalho
show_docker_header() {
    clear
    echo -e "${CYBER_BLUE}"
    echo "  ╔══════════════════════════════════════════════╗"
    echo "  ║  ▓▓▓ DOCKER NAVIGATOR ▓▓▓                    ║"
    echo "  ║                                              ║"
    echo "  ║  🐋  Manage containers, images and volumes   ║"
    echo "  ║  🚀  Docker Compose utilities                ║"
    echo "  ║  ⚡   System monitoring and cleanup           ║"
    echo "  ╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
}


# Função para seleção de menu
# Função para seleção de menu
choose_from_menu() {
    local prompt="$1" outvar="$2"
    shift
    shift
    local options=("$@") cur=0 count=${#options[@]} index=0
    local key

    if [ $count -eq 0 ]; then
        echo -e "${CYBER_RED}Nenhuma opção disponível${RESET}"
        return 1
    fi

    echo -e "${BOLD}${CYBER_PURPLE}$prompt${RESET}"

    while true; do
        index=0
        for o in "${options[@]}"; do
            if [ "$index" -eq "$cur" ]; then
                echo -e "${CYBER_GREEN} > ${CYBER_CYAN}${BOLD}${o}${RESET}"
            else
                echo -e "   ${CYBER_YELLOW}${o}${RESET}"
            fi
            index=$((index+1))
        done

        # Ler apenas 1 caractere (-n 1), modo silencioso (-s)
        read -rsn1 key
        # Se for uma sequência de escape, ler mais 2 caracteres
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
        fi

        case "$key" in
            '[A') cur=$((cur-1)); [ "$cur" -lt 0 ] && cur=0 ;;  # Seta para cima
            '[B') cur=$((cur+1)); [ "$cur" -ge "$count" ] && cur=$((count-1)) ;;  # Seta para baixo
            '') break ;;  # Enter (string vazia)
            [1-9])
                if [ "$key" -gt 0 ] && [ "$key" -le "$count" ]; then
                    cur=$((key-1))
                    break
                fi
                ;;
            q|Q) return 1 ;;
        esac

        # Mover o cursor para cima para reescrever o menu
        printf "\033[%dA" "$count"
    done

    printf -v "$outvar" "%s" "${options[$cur]}"
}

# Formata informações do container
format_container_info() {
    local full_line="$1"
    local status=$(echo "$full_line" | awk '{print $2}')
    local color
    local container_name=$(echo "$full_line" | awk '{print $1}')

    case $status in
        *running*) color="${CYBER_GREEN}" ;;
        *exited*) color="${CYBER_RED}" ;;
        *paused*) color="${CYBER_YELLOW}" ;;
        *Created*) color="${CYBER_BLUE}" ;;
        *) color="${CYBER_PURPLE}" ;;
    esac

    echo -e "${color}${container_name}${RESET} (${full_line#* })"
}

# Verifica dependências
check_dependencies() {
    local missing=()

    if ! command -v jq &>/dev/null; then
        missing+=("jq")
    fi

    if ! command -v less &>/dev/null; then
        missing+=("less")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${CYBER_YELLOW}⚠ Dependências faltando:${RESET}"
        for dep in "${missing[@]}"; do
            echo -e " - ${CYBER_RED}$dep${RESET}"
        done
        echo -e "${CYBER_BLUE}▶ Instale com:${RESET}"
        if command -v apt &>/dev/null; then
            echo -e "   ${CYBER_CYAN}sudo apt install ${missing[*]}${RESET}"
        elif command -v yum &>/dev/null; then
            echo -e "   ${CYBER_CYAN}sudo yum install ${missing[*]}${RESET}"
        fi
        echo
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
    fi
}

# Configura Docker e Docker Compose
configure_docker() {
    if ! command -v docker &>/dev/null; then
        echo -e "${CYBER_RED}✖ Docker não instalado!${RESET}"
        echo -e "${CYBER_BLUE}▶ Instale em: https://docs.docker.com/engine/install/${RESET}"
        exit 1
    fi

    # Verifica Docker Compose (subcomando)
    if ! docker compose version &>/dev/null; then
        echo -e "${CYBER_RED}✖ 'docker compose' não disponível!${RESET}"
        if command -v docker-compose &>/dev/null; then
            echo -e "${CYBER_YELLOW}⚠ Usando versão legada docker-compose${RESET}"
            cmd_docker_compose="docker-compose"
        else
            echo -e "${CYBER_RED}✖ Docker Compose não instalado!${RESET}"
            exit 1
        fi
    fi

    if docker ps &>/dev/null; then
        echo -e "${CYBER_GREEN}✔ Docker acessível sem sudo${RESET}"
        cmd_docker="docker"
    elif sudo docker ps &>/dev/null; then
        echo -e "${CYBER_YELLOW}⚠ Docker requer sudo${RESET}"
        cmd_docker="sudo docker"
        cmd_docker_compose="sudo $cmd_docker_compose"

        echo -e "\n${CYBER_BLUE}▶ Para evitar sudo:${RESET}"
        echo -e "   ${CYBER_CYAN}sudo usermod -aG docker \$USER${RESET}"
        echo -e "   ${CYBER_YELLOW}(Reinicie a sessão depois)${RESET}\n"
    else
        echo -e "${CYBER_RED}✖ Não foi possível conectar ao Docker!${RESET}"
        exit 1
    fi
}

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

    local create_cmd="$cmd_docker run -d --name $container_name"

    if [ -n "$ports" ]; then
        create_cmd+=" -p $ports"
    fi

    if [ -n "$env_vars" ]; then
        create_cmd+=" -e $env_vars"
    fi

    if [ -n "$volumes" ]; then
        create_cmd+=" -v $volumes"
    fi

    create_cmd+=" $image_name"

    echo -e "${CYBER_BLUE}▶ Comando a ser executado:${RESET}"
    echo -e "${CYBER_CYAN}$create_cmd${RESET}"
    read -p "Confirmar criação? (y/N): " confirm

    if [[ "$confirm" == [yY] ]]; then
        eval "$create_cmd"
    else
        echo -e "${CYBER_YELLOW}Criação cancelada${RESET}"
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

# Mostra estatísticas dos containers
show_stats() {
    show_docker_header
    echo -e "${CYBER_PURPLE}▓▓ ESTATÍSTICAS DOS CONTAINERS ▓▓${RESET}"
    $cmd_docker stats --no-stream
    echo -e "\n${CYBER_BLUE}▶ Uso de disco:${RESET}"
    $cmd_docker system df
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
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
            *Estatísticas*) show_stats ;;
            *Sair*) exit 0 ;;
        esac
    done
}

# Ponto de entrada principal
container_commander() {
    check_dependencies
    configure_docker
    main_menu
}

# Função para processar comandos de container
handle_container_command() {
    local subcommand="$1"
    shift

    case "$subcommand" in
        "list"|"ls")
            if [[ "$1" == "--all" || "$1" == "-a" ]]; then
                list_all_containers
            else
                list_running_containers
            fi
            ;;
        "create"|"new")
            create_container
            ;;
        "stats"|"stat")
            show_stats
            ;;
        "search"|"find")
            search_containers
            ;;
        *)
            echo -e "${CYBER_YELLOW}⚡ ${CYBER_BLUE}CONTAINER COMMANDS:${RESET}"
            echo -e "  ${CYBER_GREEN}list${RESET}, ${CYBER_GREEN}ls${RESET}       List containers"
            echo -e "    ${CYBER_GRAY}--all, -a${RESET}  Show all containers (including stopped)"
            echo -e "  ${CYBER_GREEN}create${RESET}, ${CYBER_GREEN}new${RESET}    Create a new container"
            echo -e "  ${CYBER_GREEN}stats${RESET}, ${CYBER_GREEN}stat${RESET}    Show container statistics"
            echo -e "  ${CYBER_GREEN}search${RESET}, ${CYBER_GREEN}find${RESET}   Search for containers"
            ;;
    esac
}

