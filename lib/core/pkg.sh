#!/bin/bash

# Detecção e operações de gerenciadores de pacotes.
# Este arquivo apenas declara funções; nada instala ou atualiza durante o source.

if [[ -n "${_BYTEBABE_CORE_PKG_LOADED:-}" ]]; then
    return 0
fi
_BYTEBABE_CORE_PKG_LOADED=1

if [[ -z "${CYBER_BLUE:-}" ]]; then
    if [[ "${BASH_SOURCE[0]}" == */* ]]; then
        _bytebabe_pkg_dir="${BASH_SOURCE[0]%/*}"
    else
        _bytebabe_pkg_dir="."
    fi
    _bytebabe_pkg_dir="$(cd -P -- "$_bytebabe_pkg_dir" && pwd)"
    source "$_bytebabe_pkg_dir/colors.sh"
    unset _bytebabe_pkg_dir
fi

# Detecta o gerenciador de pacotes da distribuição (ou brew no macOS/Linux).
detect_pkg_manager() {
    local manager
    for manager in apt-get apt dnf yum pacman zypper apk brew; do
        if command -v "$manager" &>/dev/null; then
            case "$manager" in
                apt-get|apt) echo "apt" ;;
                yum) echo "yum" ;;
                *) echo "$manager" ;;
            esac
            return 0
        fi
    done
    echo "unknown"
}

# Detecta o gerenciador de pacotes JavaScript disponível (fallback: npm).
detect_node_pkg_manager() {
    local manager
    for manager in npm pnpm yarn bun; do
        if command -v "$manager" &>/dev/null; then
            echo "$manager"
            return 0
        fi
    done
    echo "npm"
}

# Executa comando com sudo apenas quando necessário.
_run_privileged() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

# Atualiza os índices de pacotes.
pkg_update() {
    case "$(detect_pkg_manager)" in
        apt) _run_privileged apt-get update -qq ;;
        dnf) _run_privileged dnf makecache -q ;;
        yum) _run_privileged yum makecache -q ;;
        pacman) _run_privileged pacman -Sy --noconfirm ;;
        zypper) _run_privileged zypper --non-interactive refresh ;;
        apk) _run_privileged apk update -q ;;
        brew) brew update -q ;;
        *) echo -e "${CYBER_ORANGE}⚠ Gerenciador de pacotes não suportado${RESET}"; return 1 ;;
    esac
}

# Atualiza os pacotes do sistema.
pkg_upgrade() {
    case "$(detect_pkg_manager)" in
        apt) _run_privileged apt-get update -qq && _run_privileged apt-get upgrade -y -qq ;;
        dnf) _run_privileged dnf upgrade -y -q ;;
        yum) _run_privileged yum update -y -q ;;
        pacman) _run_privileged pacman -Syu --noconfirm ;;
        zypper) _run_privileged zypper --non-interactive update -y ;;
        apk) _run_privileged apk update -q && _run_privileged apk upgrade -q ;;
        brew) brew upgrade -q ;;
        *) echo -e "${CYBER_ORANGE}⚠ Gerenciador de pacotes não suportado${RESET}"; return 1 ;;
    esac
}

# Instalação segura de pacotes (genérica, multi-distribuição).
pkg_install() {
    [ $# -eq 0 ] && return 0
    case "$(detect_pkg_manager)" in
        apt) _run_privileged apt-get install -y -qq "$@" ;;
        dnf) _run_privileged dnf install -y -q --skip-unavailable "$@" ;;
        yum) _run_privileged yum install -y -q "$@" ;;
        pacman) _run_privileged pacman -S --needed --noconfirm "$@" ;;
        zypper) _run_privileged zypper --non-interactive install -y "$@" ;;
        apk) _run_privileged apk add --no-cache "$@" ;;
        brew) brew install "$@" ;;
        *) echo -e "${CYBER_ORANGE}⚠ Gerenciador de pacotes não suportado${RESET}"; return 1 ;;
    esac
}

install_pkg() {
    local pkg="${1:-}"

    [[ -n "$pkg" ]] || return 1

    echo -e "${CYBER_BLUE}▶ Instalando $pkg...${RESET}"
    if ! pkg_install "$pkg" > /dev/null 2>&1; then
        echo -e "${CYBER_ORANGE}⚠ Falha ao instalar $pkg${RESET}"
        return 1
    fi
    echo -e "${CYBER_GREEN}✔ $pkg instalado${RESET}"
}

# Verifica e instala dependências.
check_dependencies() {
    local deps=("$@")
    local dep
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            install_pkg "$dep" || return 1
        fi
    done
}
