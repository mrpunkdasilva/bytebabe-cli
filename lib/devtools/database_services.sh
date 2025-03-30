8

cle#!/bin/bash

# ==========================================
# DATABASE TOOLS INSTALLER - UNIVERSAL EDITION
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
    echo "║   ██████╗  █████╗ ████████╗ █████╗ ██████╗  ║"
    echo "║   ██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗ ║"
    echo "║   ██║  ██║███████║   ██║   ███████║██████╔╝ ║"
    echo "║   ██║  ██║██╔══██║   ██║   ██╔══██║██╔══██╗ ║"
    echo "║   ██████╔╝██║  ██║   ██║   ██║  ██║██████╔╝ ║"
    echo "║   ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═════╝  ║"
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
# DETECÇÃO DE SISTEMA
# ==========================================

detect_pkg_manager() {
    declare -A managers=(
        ["apt"]="/etc/debian_version"
        ["dnf"]="/etc/redhat-release"
        ["yum"]="/etc/redhat-release"
        ["pacman"]="/etc/arch-release"
        ["zypper"]="/etc/SuSE-release"
        ["apk"]="/etc/alpine-release"
    )

    for manager in "${!managers[@]}"; do
        if [[ -f "${managers[$manager]}" ]] || command -v $manager &> /dev/null; then
            echo "$manager"
            return
        fi
    done

    echo "unknown"
}

PKG_MANAGER=$(detect_pkg_manager)
OS_ARCH=$(uname -m)
DISTRO=$(lsb_release -si 2>/dev/null || cat /etc/*release 2>/dev/null | head -n1 | cut -d= -f2)

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
# INSTALAÇÃO DAS FERRAMENTAS
# ==========================================

install_tableplus() {
    cyber_install_animation "Instalando TablePlus"

    case $PKG_MANAGER in
        apt)
            sudo apt install -y software-properties-common
            sudo add-apt-repository -y "deb [arch=amd64] https://deb.tableplus.com/debian/22 tableplus main"
            wget -qO - https://deb.tableplus.com/apt.tableplus.com.gpg.key | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/tableplus.gpg
            sudo apt update
            sudo apt install -y tableplus
            ;;
        dnf|yum)
            sudo rpm -v --import https://yum.tableplus.com/tableplus.repo
            sudo dnf config-manager --add-repo https://yum.tableplus.com/tableplus.repo
            sudo dnf install -y tableplus
            ;;
        pacman)
            install_aur tableplus
            ;;
        *)
            if [ "$OS_ARCH" = "x86_64" ]; then
                if [ -f "/etc/debian_version" ]; then
                    install_deb "https://tableplus.com/debian/11/pool/main/t/tableplus/tableplus_4.8.0_amd64.deb"
                else
                    install_rpm "https://tableplus.com/rpm/tableplus.x86_64.rpm"
                fi
            else
                echo -e "${CYBER_RED}Arquitetura não suportada: $OS_ARCH${CYBER_RESET}"
                return 1
            fi
            ;;
    esac

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}TablePlus instalado com sucesso!${CYBER_RESET}"
    echo -e "${CYBER_ICON_TERMINAL} Comando: ${CYBER_PURPLE}tableplus${CYBER_RESET}"
    cyber_divider
}

install_dbeaver() {
    cyber_install_animation "Instalando DBeaver CE"

    case $PKG_MANAGER in
        apt)
            wget -O - https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
            echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list
            sudo apt update
            sudo apt install -y dbeaver-ce
            ;;
        dnf|yum)
            install_rpm "https://dbeaver.io/files/dbeaver-ce-latest-stable.x86_64.rpm"
            ;;
        pacman)
            install_aur dbeaver-ce
            ;;
        *)
            if command -v snap &> /dev/null; then
                sudo snap install dbeaver-ce
            else
                echo -e "${CYBER_RED}Não foi possível instalar o DBeaver nesta distribuição${CYBER_RESET}"
                return 1
            fi
            ;;
    esac

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}DBeaver CE instalado com sucesso!${CYBER_RESET}"
    echo -e "${CYBER_ICON_TERMINAL} Comando: ${CYBER_PURPLE}dbeaver-ce${CYBER_RESET}"
    cyber_divider
}

install_mongodb_compass() {
    cyber_install_animation "Instalando MongoDB Compass"

    case $PKG_MANAGER in
        apt)
            install_deb "https://downloads.mongodb.com/compass/mongodb-compass_1.36.4_amd64.deb"
            ;;
        dnf|yum)
            install_rpm "https://downloads.mongodb.com/compass/mongodb-compass-1.36.4.x86_64.rpm"
            ;;
        *)
            if command -v snap &> /dev/null; then
                sudo snap install mongodb-compass
            else
                echo -e "${CYBER_RED}Não foi possível instalar o MongoDB Compass${CYBER_RESET}"
                return 1
            fi
            ;;
    esac

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}MongoDB Compass instalado com sucesso!${CYBER_RESET}"
    echo -e "${CYBER_ICON_TERMINAL} Comando: ${CYBER_PURPLE}mongodb-compass${CYBER_RESET}"
    cyber_divider
}

install_pgadmin() {
    cyber_install_animation "Instalando pgAdmin 4"

    case $PKG_MANAGER in
        apt)
            curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
            sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
            sudo apt update
            sudo apt install -y pgadmin4-desktop
            ;;
        dnf|yum)
            sudo rpm -i https://ftp.postgresql.org/pub/pgadmin/pgadmin4/yum/pgadmin4-redhat-repo-1-1.noarch.rpm
            sudo dnf install -y pgadmin4-desktop
            ;;
        pacman)
            install_aur pgadmin4-desktop
            ;;
        *)
            if command -v pip3 &> /dev/null; then
                pip3 install pgadmin4==6.12
                echo -e "${CYBER_YELLOW}Instalado via pip. Execute com: ${CYBER_PURPLE}pgadmin4${CYBER_RESET}"
            else
                echo -e "${CYBER_RED}Não foi possível instalar o pgAdmin${CYBER_RESET}"
                return 1
            fi
            ;;
    esac

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}pgAdmin 4 instalado com sucesso!${CYBER_RESET}"
    echo -e "${CYBER_ICON_TERMINAL} Comando: ${CYBER_PURPLE}pgadmin4${CYBER_RESET}"
    cyber_divider
}

install_mysql_workbench() {
    cyber_install_animation "Instalando MySQL Workbench"

    case $PKG_MANAGER in
        apt)
            sudo apt install -y mysql-workbench-community
            ;;
        dnf|yum)
            install_rpm "https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community-8.0.33-1.el8.x86_64.rpm"
            ;;
        pacman)
            install_aur mysql-workbench
            ;;
        *)
            echo -e "${CYBER_RED}Não foi possível instalar o MySQL Workbench${CYBER_RESET}"
            return 1
            ;;
    esac

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}MySQL Workbench instalado com sucesso!${CYBER_RESET}"
    echo -e "${CYBER_ICON_TERMINAL} Comando: ${CYBER_PURPLE}mysql-workbench${CYBER_RESET}"
    cyber_divider
}

# ==========================================
# FUNÇÕES AUXILIARES
# ==========================================

list_installed_tools() {
    declare -A tools=(
        ["tableplus"]="TablePlus"
        ["dbeaver-ce"]="DBeaver"
        ["mongodb-compass"]="MongoDB Compass"
        ["pgadmin4"]="pgAdmin"
        ["mysql-workbench"]="MySQL Workbench"
    )

    echo -e "${CYBER_BLUE}${CYBER_BOLD}🛠️  Ferramentas instaladas:${CYBER_RESET}"

    local any_installed=0
    for cmd in "${!tools[@]}"; do
        if command -v "$cmd" &>/dev/null || \
           dpkg -l | grep -q "$cmd" || \
           rpm -qa | grep -q "$cmd" || \
           pacman -Q "$cmd" &>/dev/null; then
            echo -e "  ${CYBER_GREEN}✔ ${tools[$cmd]}${CYBER_RESET}"
            any_installed=1
        fi
    done

    if [ "$any_installed" -eq 0 ]; then
        echo -e "  ${CYBER_RED}Nenhuma ferramenta instalada${CYBER_RESET}"
    fi
    cyber_divider
}

install_all_tools() {
    local tools=(
        "tableplus"
        "dbeaver"
        "mongodb_compass"
        "pgadmin"
        "mysql_workbench"
    )

    for tool in "${tools[@]}"; do
        if ! "install_$tool"; then
            echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}Falha na instalação de ${tool}${CYBER_RESET}"
        fi
    done
}

# ==========================================
# MENU PRINCIPAL
# ==========================================

show_menu() {
    cyber_header
    echo -e "${CYBER_BLUE}${CYBER_BOLD}  🗄️  MENU DE FERRAMENTAS DE BANCO DE DADOS  🗄️${CYBER_RESET}"
    echo ""
    echo -e "${CYBER_PURPLE}1) Instalar TablePlus"
    echo -e "2) Instalar DBeaver"
    echo -e "3) Instalar MongoDB Compass"
    echo -e "4) Instalar pgAdmin"
    echo -e "5) Instalar MySQL Workbench"
    echo -e "6) Instalar TODAS as ferramentas"
    echo -e "7) Listar ferramentas instaladas"
    echo -e "8) Sair${CYBER_RESET}"
    echo ""
    cyber_divider
}

# ==========================================
# EXECUÇÃO PRINCIPAL
# ==========================================

case $1 in
    tableplus) install_tableplus ;;
    dbeaver) install_dbeaver ;;
    compass) install_mongodb_compass ;;
    pgadmin) install_pgadmin ;;
    mysql) install_mysql_workbench ;;
    all) install_all_tools ;;
    list) list_installed_tools ;;
    *)
        while true; do
            show_menu
            read -p $'\e[1;35m  ⌘ Selecione uma opção: \e[0m' choice

            case $choice in
                1) install_tableplus ;;
                2) install_dbeaver ;;
                3) install_mongodb_compass ;;
                4) install_pgadmin ;;
                5) install_mysql_workbench ;;
                6) install_all_tools ;;
                7) list_installed_tools ;;
                8) exit 0 ;;
                *) echo -e "${CYBER_RED}Opção inválida!${CYBER_RESET}" ;;
            esac

            read -p $'\e[1;36mPressione ENTER para continuar...\e[0m'
        done
        ;;
esac