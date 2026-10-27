#!/bin/bash

if [[ -z "${BASE_DIR:-}" ]]; then
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"

# ==========================================
# BROWSER SERVICES - CYBERPUNK EDITION
# ==========================================

# Cores e efeitos visuais
CYBER_RED='\033[0;31m'
CYBER_GREEN='\033[0;32m'
CYBER_YELLOW='\033[0;33m'
CYBER_BLUE='\033[0;34m'
CYBER_PURPLE='\033[0;35m'
CYBER_CYAN='\033[0;36m'
CYBER_WHITE='\033[0;37m'
CYBER_BOLD='\033[1m'
CYBER_RESET='\033[0m'
CYBER_BG_DARK='\033[48;5;234m'
CYBER_GLITCH='\033[38;5;201m'

# Ícones
CYBER_ICON_SUCCESS="${CYBER_GREEN}✔${CYBER_RESET}"
CYBER_ICON_ERROR="${CYBER_RED}✘${CYBER_RESET}"
CYBER_ICON_INFO="${CYBER_BLUE}ℹ${CYBER_RESET}"
CYBER_ICON_WARNING="${CYBER_YELLOW}⚠${CYBER_RESET}"
CYBER_ICON_TERMINAL="${CYBER_PURPLE}⌨${CYBER_RESET}"

# ==========================================
# FUNÇÕES VISUAIS
# ==========================================

cyber_header() {
    clear
    echo -e "${CYBER_BG_DARK}${CYBER_PURPLE}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║   ██████╗ ██████╗  ██████╗ ██╗    ██╗███████╗║"
    echo "║   ██╔══██╗██╔══██╗██╔═══██╗██║    ██║██╔════╝║"
    echo "║   ██████╔╝██████╔╝██║   ██║██║ █╗ ██║███████╗║"
    echo "║   ██╔══██╗██╔══██╗██║   ██║██║███╗██║╚════██║║"
    echo "║   ██████╔╝██║  ██║╚██████╔╝╚███╔███╔╝███████║║"
    echo "║   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝  ╚══╝╚══╝ ╚══════╝║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${CYBER_RESET}"
}

cyber_divider() {
    echo -e "${CYBER_PURPLE}==========================================${CYBER_RESET}"
}

cyber_install_animation() {
    local text=$1
    echo -ne "${CYBER_BLUE}${CYBER_BOLD}⚡ ${text}${CYBER_YELLOW}"
    for i in {1..3}; do
        echo -ne " ► "
        sleep 0.15
    done
    echo -e "${CYBER_RESET}"
}

show_progress() {
    local pid=$1
    local delay=0.25
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}


# ==========================================
# FUNÇÕES DE INSTALAÇÃO GENÉRICAS
# ==========================================

install_deb() {
    local url=$1
    local pkg_name="/tmp/$(basename "$url")"

    wget --show-progress -qO "$pkg_name" "$url" &
    show_progress $!
    sudo dpkg -i "$pkg_name" > /dev/null 2>&1
    sudo apt-get install -f -y > /dev/null 2>&1
    rm "$pkg_name"
}

install_rpm() {
    local url=$1
    local pkg_name="/tmp/$(basename "$url")"

    wget --show-progress -qO "$pkg_name" "$url" &
    show_progress $!
    sudo rpm -ivh "$pkg_name" || sudo dnf install -y "$pkg_name"
    rm "$pkg_name"
}

install_aur() {
    local pkg=$1
    if ! command -v yay &> /dev/null; then
        sudo pacman -S --needed --noconfirm git base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
    fi
    yay -S --noconfirm "$pkg"
}

# ==========================================
# INSTALAÇÃO DOS NAVEGADORES
# ==========================================

install_chrome() {
    cyber_install_animation "Instalando Google Chrome"

    case $PKG_MANAGER in
        apt)
            wget -qO - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
            echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
            sudo apt update
            sudo apt install -y google-chrome-stable
            ;;
        dnf|yum)
            sudo dnf install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
            ;;
        pacman)
            install_aur google-chrome
            ;;
        *)
            echo -e "${CYBER_RED}Não foi possível instalar o Chrome nesta distribuição${CYBER_RESET}"
            return 1
            ;;
    esac

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}Google Chrome instalado com sucesso!${CYBER_RESET}"
    echo -e "${CYBER_ICON_TERMINAL} Comando: ${CYBER_PURPLE}google-chrome-stable${CYBER_RESET}"
    cyber_divider
}

install_firefox() {
    cyber_install_animation "Instalando Mozilla Firefox"

    case $PKG_MANAGER in
        apt)
            sudo apt install -y firefox
            ;;
        dnf|yum)
            sudo dnf install -y firefox
            ;;
        pacman)
            sudo pacman -S --noconfirm firefox
            ;;
        *)
            if command -v snap &> /dev/null; then
                sudo snap install firefox
            else
                echo -e "${CYBER_RED}Não foi possível instalar o Firefox${CYBER_RESET}"
                return 1
            fi
            ;;
    esac

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}Firefox instalado com sucesso!${CYBER_RESET}"
    echo -e "${CYBER_ICON_TERMINAL} Comando: ${CYBER_PURPLE}firefox${CYBER_RESET}"
    cyber_divider
}

install_brave() {
    cyber_install_animation "Instalando Brave Browser"

    case $PKG_MANAGER in
        apt)
            sudo apt install -y curl
            curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
            sudo apt update
            sudo apt install -y brave-browser
            ;;
        dnf|yum)
            sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
            sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
            sudo dnf install -y brave-browser
            ;;
        pacman)
            install_aur brave-bin
            ;;
        *)
            echo -e "${CYBER_RED}Não foi possível instalar o Brave nesta distribuição${CYBER_RESET}"
            return 1
            ;;
    esac

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}Brave Browser instalado com sucesso!${CYBER_RESET}"
    echo -e "${CYBER_ICON_TERMINAL} Comando: ${CYBER_PURPLE}brave-browser${CYBER_RESET}"
    cyber_divider
}

install_edge() {
    cyber_install_animation "Instalando Microsoft Edge"

    case $PKG_MANAGER in
        apt)
            curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
            sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg
            sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list'
            sudo rm microsoft.gpg
            sudo apt update
            sudo apt install -y microsoft-edge-stable
            ;;
        dnf|yum)
            sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
            sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
            sudo dnf install -y microsoft-edge-stable
            ;;
        pacman)
            install_aur microsoft-edge-stable-bin
            ;;
        *)
            echo -e "${CYBER_RED}Não foi possível instalar o Edge nesta distribuição${CYBER_RESET}"
            return 1
            ;;
    esac

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}Microsoft Edge instalado com sucesso!${CYBER_RESET}"
    echo -e "${CYBER_ICON_TERMINAL} Comando: ${CYBER_PURPLE}microsoft-edge${CYBER_RESET}"
    cyber_divider
}

install_vivaldi() {
    cyber_install_animation "Instalando Vivaldi"

    case $PKG_MANAGER in
        apt)
            wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | sudo dd of=/usr/share/keyrings/vivaldi-browser.gpg
            echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi-archive.list
            sudo apt update
            sudo apt install -y vivaldi-stable
            ;;
        dnf|yum)
            sudo dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo
            sudo dnf install -y vivaldi-stable
            ;;
        pacman)
            install_aur vivaldi
            ;;
        *)
            echo -e "${CYBER_RED}Não foi possível instalar o Vivaldi nesta distribuição${CYBER_RESET}"
            return 1
            ;;
    esac

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}Vivaldi instalado com sucesso!${CYBER_RESET}"
    echo -e "${CYBER_ICON_TERMINAL} Comando: ${CYBER_PURPLE}vivaldi${CYBER_RESET}"
    cyber_divider
}

# ==========================================
# FUNÇÕES AUXILIARES
# ==========================================

list_installed_browsers() {
    declare -A browsers=(
        ["google-chrome-stable"]="Google Chrome"
        ["firefox"]="Mozilla Firefox"
        ["brave-browser"]="Brave Browser"
        ["microsoft-edge"]="Microsoft Edge"
        ["vivaldi"]="Vivaldi"
    )

    echo -e "${CYBER_BLUE}${CYBER_BOLD}🌐 Navegadores instalados:${CYBER_RESET}"

    local any_installed=0
    for cmd in "${!browsers[@]}"; do
        if command -v "$cmd" &>/dev/null || \
           dpkg -l | grep -q "$cmd" || \
           rpm -qa | grep -q "$cmd" || \
           pacman -Q "$cmd" &>/dev/null; then
            echo -e "  ${CYBER_GREEN}✔ ${browsers[$cmd]}${CYBER_RESET}"
            any_installed=1
        fi
    done

    if [ "$any_installed" -eq 0 ]; then
        echo -e "  ${CYBER_RED}Nenhum navegador instalado${CYBER_RESET}"
    fi
    cyber_divider
}

install_all_browsers() {
    local browsers=(
        "chrome"
        "firefox"
        "brave"
        "edge"
        "vivaldi"
    )

    for browser in "${browsers[@]}"; do
        if ! "install_$browser"; then
            echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}Falha na instalação de ${browser}${CYBER_RESET}"
        fi
    done
}

# ==========================================
# MENU PRINCIPAL
# ==========================================

show_menu() {
    cyber_header
    echo -e "${CYBER_BLUE}${CYBER_BOLD}  🌐 MENU DE NAVEGADORES  🌐${CYBER_RESET}"
    echo ""
    echo -e "${CYBER_PURPLE}1) Instalar Google Chrome"
    echo -e "2) Instalar Mozilla Firefox"
    echo -e "3) Instalar Brave Browser"
    echo -e "4) Instalar Microsoft Edge"
    echo -e "5) Instalar Vivaldi"
    echo -e "6) Instalar TODOS os navegadores"
    echo -e "7) Listar navegadores instalados"
    echo -e "8) Sair${CYBER_RESET}"
    echo ""
    cyber_divider
}

# ==========================================
# EXECUÇÃO PRINCIPAL
# ==========================================

browser_services_main() {
    PKG_MANAGER=$(detect_pkg_manager)
    OS_ARCH=$(uname -m)
    DISTRO=$(lsb_release -si 2>/dev/null || cat /etc/*release 2>/dev/null | head -n1 | cut -d= -f2)

    case ${1:-} in
        chrome) install_chrome ;;
        firefox) install_firefox ;;
        brave) install_brave ;;
        edge) install_edge ;;
        vivaldi) install_vivaldi ;;
        all) install_all_browsers ;;
        list) list_installed_browsers ;;
        *)
            while true; do
                show_menu
                read -p $'\e[1;35m  ⌘ Selecione uma opção: \e[0m' choice

                case $choice in
                    1) install_chrome ;;
                    2) install_firefox ;;
                    3) install_brave ;;
                    4) install_edge ;;
                    5) install_vivaldi ;;
                    6) install_all_browsers ;;
                    7) list_installed_browsers ;;
                    8) return 0 ;;
                    *) echo -e "${CYBER_RED}Opção inválida!${CYBER_RESET}" ;;
                esac

                read -p $'\e[1;36mPressione ENTER para continuar...\e[0m'
            done
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    browser_services_main "$@"
fi
