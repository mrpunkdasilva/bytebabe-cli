#!/bin/bash

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

show_invalid_command_prime() {
  echo -e "${CYBER_RED}"
  cat << "EOF"
  ╔════════════════════════════════════════════╗
  ║      ▓▓▓ INVALID COMMAND DETECTED ▓▓▓      ║
  ╚════════════════════════════════════════════╝
EOF
  echo -e "${RESET}"

  echo -e "${CYBER_YELLOW}⚠️  Unknown command:${RESET} ${CYBER_RED}$1${RESET}"
  echo -e "${CYBER_BLUE}Available commands:${RESET}"

  echo -e "\n${CYBER_GREEN}🛠️  System Commands:${RESET}"
  echo -e "  ${CYBER_CYAN}upgrade    ${CYBER_GRAY}- ${CYBER_PURPLE}System upgrade${RESET}"
  echo -e "  ${CYBER_CYAN}install    ${CYBER_GRAY}- ${CYBER_PURPLE}Install packages${RESET}"
  echo -e "  ${CYBER_CYAN}remove     ${CYBER_GRAY}- ${CYBER_PURPLE}Remove packages${RESET}"

  echo -e "\n${CYBER_RED}🛡️  Security:${RESET}"
  echo -e "  ${CYBER_CYAN}scan       ${CYBER_GRAY}- ${CYBER_PURPLE}Security scan${RESET}"
  echo -e "  ${CYBER_CYAN}firewall   ${CYBER_GRAY}- ${CYBER_PURPLE}Firewall control${RESET}"

  echo -e "\n${CYBER_YELLOW}ℹ️  Try:${RESET}"
  echo -e "  ${CYBER_BLUE}prime help${RESET} for full documentation"
  echo -e "  ${CYBER_BLUE}prime upgrade${RESET} to start system update"

  echo -e "\n${CYBER_PURPLE}╰┈➤ ${CYBER_GRAY}Report bugs at: ${CYBER_CYAN}https://github.com/mrpunkdasilva/bytebabe${RESET}"
}