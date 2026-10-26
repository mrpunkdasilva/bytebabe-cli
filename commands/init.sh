#!/bin/bash

# Set BASE_DIR if not already set (for direct execution)
if [ -z "$BASE_DIR" ]; then
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi

# Importa módulos
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"
source "${BASE_DIR}/lib/utils/config.sh"
source "${BASE_DIR}/lib/utils/headers.sh"
source "${BASE_DIR}/lib/utils/nvm.sh"
source "${BASE_DIR}/commands/neovim_tools.sh"

# ======================
# CONFIGURAÇÕES BÁSICAS
# ======================
# Pacotes essenciais por gerenciador de pacotes
get_essential_packages() {
    case "$(detect_pkg_manager)" in
        apt)
            echo "build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev libxml2-dev \
libxmlsec1-dev libffi-dev liblzma-dev jq unzip tree htop neofetch curl wget gawk"
            ;;
        dnf|yum)
            echo "gcc gcc-c++ make openssl-devel zlib-devel bzip2-devel readline-devel \
sqlite-devel llvm ncurses-devel xz-devel tk-devel libxml2-devel libffi-devel \
jq unzip tree htop curl wget gawk git"
            ;;
        pacman)
            echo "base-devel openssl zlib bzip2 readline sqlite llvm ncurses xz tk \
libxml2 libffi jq unzip tree htop neofetch curl wget gawk git"
            ;;
        zypper)
            echo "gcc gcc-c++ make libopenssl-devel zlib-devel libbz2-devel readline-devel \
sqlite3-devel llvm ncurses-devel xz-devel tk-devel libxml2-devel libffi-devel \
jq unzip tree htop neofetch curl wget gawk git"
            ;;
        apk)
            echo "build-base openssl-dev zlib-dev bzip2-dev readline-dev sqlite-dev \
llvm ncurses-dev xz-dev tk-dev libxml2-dev libffi-dev jq unzip tree htop curl wget gawk git"
            ;;
        *)
            echo ""
            ;;
    esac
}

configure_basics() {
    local manager
    manager=$(detect_pkg_manager)

    if [ "$manager" = "unknown" ]; then
        echo -e "${CYBER_ORANGE}⚠ Gerenciador de pacotes não identificado. Pulando configuração base.${RESET}"
        return 0
    fi

    # Configuração do sistema
    echo -e "\n${CYBER_BLUE}▶ Atualizando sistema...${RESET}"
    echo -e "${CYBER_YELLOW}Deseja atualizar o sistema? (s/n)${RESET}"
    read -r resposta

    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        echo -e "${CYBER_BLUE}Atualizando pacotes...${RESET}"
        if ! pkg_upgrade; then
            echo -e "${CYBER_ORANGE}⚠ Falha ao atualizar o sistema.${RESET}"
        fi
    else
        echo -e "${CYBER_YELLOW}Atualização do sistema ignorada.${RESET}"
    fi

    # Instala pacotes essenciais
    echo -e "\n${CYBER_BLUE}▶ Instalando ferramentas base...${RESET}"
    echo -e "${CYBER_YELLOW}Deseja instalar ferramentas de desenvolvimento essenciais? (s/n)${RESET}"
    read -r resposta

    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        echo -e "${CYBER_BLUE}Instalando pacotes essenciais...${RESET}"
        local packages
        packages=$(get_essential_packages)
        if [ -z "$packages" ]; then
            echo -e "${CYBER_ORANGE}⚠ Nenhum pacote essencial definido para $manager.${RESET}"
        elif ! pkg_install $packages; then
            echo -e "${CYBER_ORANGE}⚠ Falha ao instalar alguns pacotes essenciais.${RESET}"
        fi
    else
        echo -e "${CYBER_YELLOW}Instalação de ferramentas ignorada.${RESET}"
    fi
}

# ======================
#  CONFIGURAÇÃO DO GIT
# ======================
configure_git_identity() {
    if [ -z "$(git config --global user.name)" ]; then
        read -p "Nome para commits Git: " git_name
        git config --global user.name "$git_name"
        save_config "GIT_NAME" "$git_name"
    fi

    if [ -z "$(git config --global user.email)" ]; then
        read -p "Email para commits Git: " git_email
        git config --global user.email "$git_email"
        save_config "GIT_EMAIL" "$git_email"
    fi
    
    # Configurações extras do Git
    git config --global init.defaultBranch main
    git config --global pull.rebase true
    git config --global core.editor "code --wait"
}

# ======================
# INSTALAÇÃO DO DOCKER
# ======================
install_docker() {
    echo -e "\n${CYBER_BLUE}▶ Instalando Docker...${RESET}"
    echo -e "${CYBER_YELLOW}Deseja instalar o Docker? (s/n)${RESET}"
    read -r resposta
    
    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        echo -e "${CYBER_BLUE}Instalando Docker...${RESET}"
        source "$BASE_DIR/lib/utils/get_docker.sh"

        # Configura usuário
        sudo usermod -aG docker $USER
        echo -e "${CYBER_GREEN}✔ Docker instalado"
        echo -e "${CYBER_ORANGE}⚠ Reinicie o terminal para usar Docker sem sudo${RESET}"

        save_config "DOCKER_INSTALLED" "true"
    else
        echo -e "${CYBER_YELLOW}Instalação do Docker ignorada.${RESET}"
    fi
}

main() {
    show_cyberpunk_header
    load_config

    echo -e "\n${CYBER_PINK}⚡ INICIALIZANDO BYTEBABE CLI ⚡${RESET}"

    # ======================
    # VERIFICA DEPENDÊNCIAS
    # ======================
    check_dependencies curl wget git

    configure_basics
    configure_git_identity
    install_nvm_if_needed
    check_dependencies node npm 2>/dev/null || true
    install_docker
    install_neovim_tools

    echo -e "\n${CYBER_GREEN}⚡ CONFIGURAÇÃO INICIAL COMPLETA! ⚡${RESET}"
}

# Só executa main se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
