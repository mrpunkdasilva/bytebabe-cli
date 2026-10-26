#!/bin/bash

# Verifica se é root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${CYBER_ORANGE}⚠ Comando requer sudo!${RESET}"
        exit 1
    fi
}

# Detecta o gerenciador de pacotes da distribuição
detect_pkg_manager() {
    local manager
    for manager in apt-get dnf yum pacman zypper apk; do
        if command -v "$manager" &> /dev/null; then
            case "$manager" in
                apt-get) echo "apt" ;;
                yum) echo "yum" ;;
                *) echo "$manager" ;;
            esac
            return 0
        fi
    done
    echo "unknown"
}

# Executa comando com sudo apenas quando necessário
_run_privileged() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Atualiza os índices de pacotes
pkg_update() {
    case "$(detect_pkg_manager)" in
        apt) _run_privileged apt-get update -qq ;;
        dnf) _run_privileged dnf makecache -q ;;
        yum) _run_privileged yum makecache -q ;;
        pacman) _run_privileged pacman -Sy --noconfirm ;;
        zypper) _run_privileged zypper --non-interactive refresh ;;
        apk) _run_privileged apk update -q ;;
        *) echo -e "${CYBER_ORANGE}⚠ Gerenciador de pacotes não suportado${RESET}"; return 1 ;;
    esac
}

# Atualiza os pacotes do sistema
pkg_upgrade() {
    case "$(detect_pkg_manager)" in
        apt) _run_privileged apt-get update -qq && _run_privileged apt-get upgrade -y -qq ;;
        dnf) _run_privileged dnf upgrade -y -q ;;
        yum) _run_privileged yum update -y -q ;;
        pacman) _run_privileged pacman -Syu --noconfirm ;;
        zypper) _run_privileged zypper --non-interactive update -y ;;
        apk) _run_privileged apk update -q && _run_privileged apk upgrade -q ;;
        *) echo -e "${CYBER_ORANGE}⚠ Gerenciador de pacotes não suportado${RESET}"; return 1 ;;
    esac
}

# Instalação segura de pacotes (genérica, multi-distribuição)
pkg_install() {
    [ $# -eq 0 ] && return 0
    case "$(detect_pkg_manager)" in
        apt) _run_privileged apt-get install -y -qq "$@" ;;
        dnf) _run_privileged dnf install -y -q --skip-unavailable "$@" ;;
        yum) _run_privileged yum install -y -q "$@" ;;
        pacman) _run_privileged pacman -S --needed --noconfirm "$@" ;;
        zypper) _run_privileged zypper --non-interactive install -y "$@" ;;
        apk) _run_privileged apk add --no-cache "$@" ;;
        *) echo -e "${CYBER_ORANGE}⚠ Gerenciador de pacotes não suportado${RESET}"; return 1 ;;
    esac
}

install_pkg() {
    local pkg=$1
    echo -e "${CYBER_BLUE}▶ Instalando $pkg...${RESET}"
    if ! pkg_install "$pkg" > /dev/null 2>&1; then
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