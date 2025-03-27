#!/bin/bash

source ./core/colors.sh

# Verifica se é root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${CYBER_ORANGE}⚠ Comando requer sudo!${RESET}"
        exit 1
    fi
}

# Instalação segura de pacotes
install_pkg() {
    local pkg=$1
    echo -e "${CYBER_BLUE}▶ Instalando $pkg...${RESET}"
    if ! apt install -y $pkg > /dev/null 2>&1; then
        echo -e "${CYBER_ORANGE}⚠ Falha ao instalar $pkg${RESET}"
        return 1
    fi
    echo -e "${CYBER_GREEN}✔ $pkg instalado${RESET}"
}

# Verifica e instala dependências
check_dependencies() {
    local deps=("$@")
    for dep in "${deps[@]}"; do
        if ! command -v $dep &> /dev/null; then
            install_pkg $dep || return 1
        fi
    done
}

# Animação de loading
show_spinner() {
    local pid=$1
    local msg=$2
    local delay=0.1
    local spinstr='⣾⣽⣻⢿⡿⣟⣯⣷'

    echo -ne "${CYBER_BLUE}   [ ] $msg${RESET}"
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        for i in $(seq 0 7); do
            echo -ne "${CYBER_PINK}\b${spinstr:$i:1}${RESET}"
            sleep $delay
        done
    done
    echo -e "\b${CYBER_GREEN}✔${RESET}"
}