#!/bin/bash

# Cores para melhor visualização
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuração
ALWAYS_USE_SUDO=true
COMPOSE_FILE="docker-compose.yml"

# Função para mostrar ajuda
show_help() {
    echo -e "\n${BLUE}Docker Compose Manager${NC}"
    echo -e "Uso: $0 [comando] [opções]"
    echo -e "\nComandos básicos:"
    echo -e "  ${GREEN}up${NC}        - Inicia serviços (opções: -d para detached)"
    echo -e "  ${GREEN}down${NC}      - Para e remove serviços"
    echo -e "  ${GREEN}restart${NC}   - Reinicia serviços"
    echo -e "  ${GREEN}logs${NC}      - Mostra logs (use -f para seguir)"
    echo -e "  ${GREEN}build${NC}     - Reconstrói imagens"
    echo -e "  ${GREEN}ps${NC}        - Lista containers"
    echo -e "  ${GREEN}exec${NC}      - Executa comando em um container"

    echo -e "\nComandos adicionais:"
    echo -e "  ${GREEN}status${NC}    - Mostra status detalhado dos containers"
    echo -e "  ${GREEN}shell${NC}     - Abre shell em um container (ex: shell mysql)"
    echo -e "  ${GREEN}restart-hard${NC} - Reinicia containers recriando-os"
    echo -e "  ${GREEN}clean${NC}     - Remove recursos Docker não utilizados"
    echo -e "  ${GREEN}prune${NC}     - Remove todos os containers parados, redes não usadas, etc."
    echo -e "  ${GREEN}ip${NC}        - Mostra IPs dos containers"
    echo -e "  ${GREEN}stats${NC}     - Mostra estatísticas de uso de recursos"
    echo -e "  ${GREEN}validate${NC}  - Valida o arquivo docker-compose.yml"
    echo -e "  ${GREEN}help${NC}      - Mostra esta ajuda"

    echo -e "\nExemplos:"
    echo -e "  $0 up -d"
    echo -e "  $0 logs -f mysql"
    echo -e "  $0 shell php"
    echo -e "  $0 exec php php -v"
}

# Função para inicializar o comando docker-compose
init_compose() {
    # Verifica se docker-compose está instalado
    if command -v docker-compose &> /dev/null; then
        echo -e "${GREEN}Usando docker-compose standalone${NC}"
        COMPOSE_CMD="docker-compose"
    elif command -v docker &> /dev/null && docker compose version &> /dev/null; then
        echo -e "${GREEN}Usando docker compose plugin${NC}"
        COMPOSE_CMD="docker compose"
    else
        echo -e "${RED}Docker Compose não encontrado!${NC}"
        exit 1
    fi

    # Sempre usa sudo se configurado para isso
    if [ "$ALWAYS_USE_SUDO" = true ]; then
        echo -e "${BLUE}Usando sudo para comandos Docker${NC}"
        COMPOSE_CMD="sudo $COMPOSE_CMD"
    fi
}

# Função para mostrar status detalhado dos containers
show_status() {
    echo -e "\n${BLUE}Status detalhado dos containers:${NC}"

    # Lista todos os containers
    local containers=$($COMPOSE_CMD ps -q)

    if [ -z "$containers" ]; then
        echo -e "${YELLOW}Nenhum container em execução!${NC}"
        return
    fi

    # Para cada container, mostra informações detalhadas
    for container in $containers; do
        local name=$(docker inspect --format='{{.Name}}' $container | sed 's/\///')
        local image=$(docker inspect --format='{{.Config.Image}}' $container)
        local status=$(docker inspect --format='{{.State.Status}}' $container)
        local ip=$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $container)
        local ports=$(docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{if $conf}}{{$p}} -> {{(index $conf 0).HostPort}}{{end}} {{end}}' $container)

        echo -e "${CYAN}$name${NC} (${PURPLE}$image${NC})"
        echo -e "  Status: ${GREEN}$status${NC}"
        echo -e "  IP: $ip"
        echo -e "  Portas: $ports"
        echo -e "  Uptime: $(docker inspect --format='{{.State.StartedAt}}' $container | xargs date -d)"
        echo ""
    done
}

# Função para abrir shell em um container
open_shell() {
    local container=$1
    local shell=${2:-bash}

    if [ -z "$container" ]; then
        echo -e "${RED}Especifique o container para abrir o shell!${NC}"
        echo -e "Uso: $0 shell <container> [shell-command]"
        return 1
    fi

    echo -e "\n${BLUE}Abrindo shell no container $container...${NC}"

    # Tenta usar o shell especificado, com fallbacks
    if ! $COMPOSE_CMD exec $container which $shell >/dev/null 2>&1; then
        if $COMPOSE_CMD exec $container which bash >/dev/null 2>&1; then
            echo -e "${YELLOW}$shell não encontrado, usando bash...${NC}"
            shell="bash"
        elif $COMPOSE_CMD exec $container which sh >/dev/null 2>&1; then
            echo -e "${YELLOW}$shell não encontrado, usando sh...${NC}"
            shell="sh"
        else
            echo -e "${RED}Nenhum shell disponível no container!${NC}"
            return 1
        fi
    fi

    $COMPOSE_CMD exec $container $shell
}

# Função para reiniciar containers recriando-os
restart_hard() {
    echo -e "\n${BLUE}Reiniciando containers (recriando)...${NC}"

    if [ $# -eq 0 ]; then
        $COMPOSE_CMD up -d --force-recreate
    else
        $COMPOSE_CMD up -d --force-recreate "$@"
    fi

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Containers reiniciados com sucesso!${NC}"
        $COMPOSE_CMD ps
    else
        echo -e "${RED}Falha ao reiniciar containers!${NC}"
    fi
}

# Função para limpar recursos Docker não utilizados
clean_docker() {
    echo -e "\n${BLUE}Limpando recursos Docker não utilizados...${NC}"

    echo -e "${YELLOW}Removendo containers parados...${NC}"
    docker container prune -f

    echo -e "${YELLOW}Removendo redes não utilizadas...${NC}"
    docker network prune -f

    echo -e "${YELLOW}Removendo imagens não utilizadas...${NC}"
    docker image prune -f

    echo -e "${GREEN}Limpeza concluída!${NC}"
}

# Função para remover todos os recursos Docker não utilizados
prune_docker() {
    echo -e "\n${BLUE}Removendo todos os recursos Docker não utilizados...${NC}"
    echo -e "${YELLOW}ATENÇÃO: Isso removerá todos os containers parados, redes não utilizadas, volumes não utilizados e imagens não utilizadas!${NC}"

    read -p "Tem certeza que deseja continuar? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        docker system prune -a --volumes -f
        echo -e "${GREEN}Limpeza completa concluída!${NC}"
    else
        echo -e "${YELLOW}Operação cancelada.${NC}"
    fi
}

# Função para mostrar IPs dos containers
show_ips() {
    echo -e "\n${BLUE}IPs dos containers:${NC}"

    # Lista todos os containers
    local containers=$($COMPOSE_CMD ps -q)

    if [ -z "$containers" ]; then
        echo -e "${YELLOW}Nenhum container em execução!${NC}"
        return
    fi

    printf "%-30s %-15s %-20s\n" "CONTAINER" "IP" "REDES"
    echo "----------------------------------------------------------------------"

    for container in $containers; do
        local name=$(docker inspect --format='{{.Name}}' $container | sed 's/\///')
        local networks=$(docker inspect --format='{{range $net, $conf := .NetworkSettings.Networks}}{{$net}} {{end}}' $container)

        for network in $networks; do
            local ip=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{if eq \"$network\" \"$net\"}}{{.IPAddress}}{{end}}{{end}}" $container)
            if [ -z "$ip" ]; then
                ip=$(docker inspect --format="{{.NetworkSettings.Networks.$network.IPAddress}}" $container)
            fi
            printf "%-30s %-15s %-20s\n" "$name" "$ip" "$network"
        done
    done
}

# Função para mostrar estatísticas de uso de recursos
show_stats() {
    echo -e "\n${BLUE}Estatísticas de uso de recursos:${NC}"

    # Lista todos os containers
    local containers=$($COMPOSE_CMD ps -q)

    if [ -z "$containers" ]; then
        echo -e "${YELLOW}Nenhum container em execução!${NC}"
        return
    fi

    docker stats --no-stream $containers
}

# Função para validar o arquivo docker-compose.yml
validate_compose() {
    echo -e "\n${BLUE}Validando arquivo docker-compose.yml...${NC}"

    if [ ! -f "$COMPOSE_FILE" ]; then
        echo -e "${RED}Arquivo $COMPOSE_FILE não encontrado!${NC}"
        return 1
    fi

    $COMPOSE_CMD config

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Arquivo docker-compose.yml é válido!${NC}"
    else
        echo -e "${RED}Arquivo docker-compose.yml contém erros!${NC}"
        return 1
    fi
}

# Função principal
handle_compose_command() {
    # Inicializa o comando docker-compose
    init_compose

    local cmd="$1"
    shift || true

    case "$cmd" in
        # Comandos básicos
        up)
            echo -e "\n${BLUE}Iniciando serviços...${NC}"
            $COMPOSE_CMD up "$@"
            ;;
        down)
            echo -e "\n${BLUE}Parando serviços...${NC}"
            $COMPOSE_CMD down "$@"
            ;;
        restart)
            echo -e "\n${BLUE}Reiniciando serviços...${NC}"
            $COMPOSE_CMD restart "$@"
            ;;
        logs)
            echo -e "\n${BLUE}Mostrando logs...${NC}"
            $COMPOSE_CMD logs "$@"
            ;;
        build)
            echo -e "\n${BLUE}Reconstruindo imagens...${NC}"
            $COMPOSE_CMD build "$@"
            ;;
        ps)
            echo -e "\n${BLUE}Containers em execução:${NC}"
            $COMPOSE_CMD ps
            ;;
        exec)
            echo -e "\n${BLUE}Executando comando...${NC}"
            $COMPOSE_CMD exec "$@"
            ;;

        # Comandos adicionais
        status)
            show_status
            ;;
        shell)
            open_shell "$@"
            ;;
        restart-hard)
            restart_hard "$@"
            ;;
        clean)
            clean_docker
            ;;
        prune)
            prune_docker
            ;;
        ip|ips)
            show_ips
            ;;
        stats)
            show_stats
            ;;
        validate)
            validate_compose
            ;;
        help|--help|-h|"")
            show_help
            ;;
        *)
            echo -e "${RED}Comando desconhecido: $cmd${NC}"
            show_help
            exit 1
            ;;
    esac
}
