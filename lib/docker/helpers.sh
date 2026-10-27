#!/bin/bash

# Configuração e validação do ambiente Docker. Não executa nada no source.

if [[ -z "${CYBER_BLUE:-}" ]]; then
    if [[ "${BASH_SOURCE[0]}" == */* ]]; then
        _bytebabe_docker_helpers_dir="${BASH_SOURCE[0]%/*}"
    else
        _bytebabe_docker_helpers_dir="."
    fi
    _bytebabe_docker_helpers_dir="$(cd -P -- "$_bytebabe_docker_helpers_dir" && pwd)"
    source "$_bytebabe_docker_helpers_dir/../core/helpers.sh"
    unset _bytebabe_docker_helpers_dir
fi

cmd_docker="${cmd_docker:-docker}"
cmd_docker_compose="${cmd_docker_compose:-}"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

configure_docker() {
    local docker_bin="${DOCKER_BIN:-docker}"

    if ! command -v "$docker_bin" &>/dev/null; then
        echo -e "${CYBER_RED}✖ Docker não instalado!${RESET}"
        echo -e "${CYBER_BLUE}▶ Instale em: https://docs.docker.com/engine/install/${RESET}"
        return 1
    fi

    if "$docker_bin" ps &>/dev/null; then
        cmd_docker="$docker_bin"
        echo -e "${CYBER_GREEN}✔ Docker acessível sem sudo${RESET}"
    elif command -v sudo &>/dev/null && sudo "$docker_bin" ps &>/dev/null; then
        cmd_docker="sudo $docker_bin"
        echo -e "${CYBER_YELLOW}⚠ Docker requer sudo${RESET}"
        echo -e "${CYBER_BLUE}▶ Para evitar sudo:${RESET}"
        echo -e "   ${CYBER_CYAN}sudo usermod -aG docker \$USER${RESET}"
        echo -e "   ${CYBER_YELLOW}(Reinicie a sessão depois)${RESET}"
    else
        echo -e "${CYBER_RED}✖ Não foi possível conectar ao Docker!${RESET}"
        echo -e "${CYBER_YELLOW}▶ Verifique se o daemon está ativo e se você tem permissão.${RESET}"
        return 1
    fi

    export cmd_docker
    return 0
}

configure_docker_compose() {
    if [[ -z "${cmd_docker:-}" ]]; then
        configure_docker || return 1
    fi

    if $cmd_docker compose version &>/dev/null; then
        cmd_docker_compose="$cmd_docker compose"
    elif command -v docker-compose &>/dev/null; then
        if [[ "$cmd_docker" == sudo\ * ]]; then
            cmd_docker_compose="sudo docker-compose"
        else
            cmd_docker_compose="docker-compose"
        fi
        echo -e "${CYBER_YELLOW}⚠ Usando versão legada docker-compose${RESET}"
    else
        echo -e "${CYBER_RED}✖ Docker Compose não instalado!${RESET}"
        echo -e "${CYBER_BLUE}▶ Instale o plugin docker compose.${RESET}"
        return 1
    fi

    export cmd_docker_compose
    return 0
}

check_docker_dependencies() {
    local missing=()

    if ! command -v jq &>/dev/null; then
        missing+=("jq")
    fi

    if ! command -v less &>/dev/null; then
        missing+=("less")
    fi

    if [ ${#missing[@]} -eq 0 ]; then
        return 0
    fi

    echo -e "${CYBER_YELLOW}⚠ Dependências faltando:${RESET}"
    for dep in "${missing[@]}"; do
        echo -e " - ${CYBER_RED}$dep${RESET}"
    done
    echo -e "${CYBER_BLUE}▶ Instale com:${RESET}"
    if command -v apt &>/dev/null; then
        echo -e "   ${CYBER_CYAN}sudo apt install ${missing[*]}${RESET}"
    elif command -v dnf &>/dev/null; then
        echo -e "   ${CYBER_CYAN}sudo dnf install ${missing[*]}${RESET}"
    elif command -v yum &>/dev/null; then
        echo -e "   ${CYBER_CYAN}sudo yum install ${missing[*]}${RESET}"
    else
        echo -e "   ${CYBER_CYAN}Instale: ${missing[*]}${RESET}"
    fi
    echo
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

filter_containers_by_status() {
    local status=$1
    $cmd_docker ps --filter "status=$status" --format "{{.Names}}" | sort
}
