#!/bin/bash

# Verifica se Docker está rodando
check_docker_daemon() {
    # Mensagem inicial explicativa
    echo -e "\n${CYBER_BLUE}🔍 Verificando o status do Docker...${RESET}"
    echo -e "${CYBER_YELLOW}▶ Esta operação requer privilégios de root para verificar/iniciar o serviço Docker.${RESET}"
    echo -e "${CYBER_YELLOW}▶ Você pode precisar digitar sua senha de administrador.${RESET}\n"

    # Verifica se o Docker está respondendo (sem sudo primeiro)
    if docker ps >/dev/null 2>&1; then
        echo -e "${CYBER_GREEN}✔ Docker está rodando e acessível sem privilégios root!${RESET}"
        return 0
    fi

    # Verifica com sudo se necessário
    if sudo docker ps >/dev/null 2>&1; then
        echo -e "${CYBER_GREEN}✔ Docker está rodando (acesso requer privilégios root).${RESET}"
        echo -e "${CYBER_YELLOW}⚠ Dica: Adicione seu usuário ao grupo docker para evitar usar sudo:"
        echo -e "  sudo usermod -aG docker \$USER${RESET}"
        return 0
    fi

    echo -e "${CYBER_RED}⚡️ Docker não está respondendo!${RESET}"

    # Verifica se está instalado
    if ! command -v docker &>/dev/null; then
        echo -e "${CYBER_RED}✖ Docker não está instalado no sistema!${RESET}"
        echo -e "${CYBER_BLUE}▶ Por favor instale o Docker antes de continuar.${RESET}"
        exit 1
    fi

    # Verifica status do serviço
    local service_status="unknown"
    if command -v systemctl &>/dev/null; then
        echo -e "${CYBER_BLUE}▶ Verificando status do serviço...${RESET}"
        service_status=$(sudo systemctl is-active docker 2>/dev/null || echo "inactive")
    fi

    case $service_status in
        active)
            echo -e "${CYBER_YELLOW}⚠ Docker está ativo mas não responde. Tentando reiniciar...${RESET}"
            sudo systemctl restart docker
            sleep 3
            ;;
        inactive)
            echo -e "${CYBER_YELLOW}▶ O serviço Docker está parado.${RESET}"
            read -p "${CYBER_BLUE}? Deseja iniciar o serviço Docker agora? (Y/n): ${RESET}" choice
            if [[ "$choice" =~ ^[Nn] ]]; then
                echo -e "${CYBER_YELLOW}▶ Operação cancelada. O Docker precisa estar rodando.${RESET}"
                exit 1
            fi
            echo -e "${CYBER_YELLOW}▶ Iniciando Docker...${RESET}"
            sudo systemctl start docker
            sleep 5  # Dá mais tempo para inicialização
            ;;
        *)
            echo -e "${CYBER_RED}✖ Não foi possível verificar o status do serviço.${RESET}"
            ;;
    esac

    # Verificação final
    echo -e "${CYBER_BLUE}▶ Verificando conexão com Docker...${RESET}"
    if docker ps >/dev/null 2>&1 || sudo docker ps >/dev/null 2>&1; then
        echo -e "${CYBER_GREEN}✔ Docker está respondendo com sucesso!${RESET}"
        return 0
    fi

    # Mensagens de erro detalhadas
    echo -e "\n${CYBER_RED}✖ Falha ao conectar ao Docker!${RESET}"
    echo -e "${CYBER_YELLOW}Possíveis causas e soluções:"
    echo -e "1. Serviço não iniciou corretamente:"
    echo -e "   sudo systemctl status docker"
    echo -e "2. Problemas de permissão:"
    echo -e "   sudo usermod -aG docker \$USER"
    echo -e "   (você precisará fazer logout e login após)"
    echo -e "3. Problema na instalação:"
    echo -e "   Consulte https://docs.docker.com/engine/install/${RESET}"

    exit 1
}

# Formata saida do docker ps
format_container_info() {
    local container=$1
    local status=$(docker inspect --format '{{.State.Status}}' "$container")
    local color

    case $status in
        running) color="${CYBER_GREEN}" ;;
        exited) color="${CYBER_RED}" ;;
        paused) color="${CYBER_YELLOW}" ;;
        *) color="${CYBER_BLUE}" ;;
    esac

    echo "${color}${container}${RESET}"
}

# Filtra containers por status
filter_containers_by_status() {
    local status=$1
    docker ps --filter "status=$status" --format "{{.Names}}" | sort
}