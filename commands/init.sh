#!/bin/bash

# Carrega paths absolutos
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Importa módulos
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/utils/config.sh"
source "$BASE_DIR/lib/utils/headers.sh"
source "$BASE_DIR/lib/utils/nvm.sh"
source "$BASE_DIR/commands/neovim_tools.sh"



# ======================
# CONFIGURAÇÕES BÁSICAS
# ======================
configure_basics() {
    # Configuração do sistema
    echo -e "\n${CYBER_BLUE}▶ Atualizando sistema...${RESET}"
    echo -e "${CYBER_YELLOW}Deseja atualizar o sistema? (s/n)${RESET}"
    read -r resposta
    
    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        echo -e "${CYBER_BLUE}Atualizando pacotes...${RESET}"
        sudo apt update -qq && sudo apt upgrade -y -qq
    else
        echo -e "${CYBER_YELLOW}Atualização do sistema ignorada.${RESET}"
    fi
    
    # Instala pacotes essenciais
    echo -e "\n${CYBER_BLUE}▶ Instalando ferramentas base...${RESET}"
    echo -e "${CYBER_YELLOW}Deseja instalar ferramentas de desenvolvimento essenciais? (s/n)${RESET}"
    read -r resposta
    
    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        echo -e "${CYBER_BLUE}Instalando pacotes essenciais...${RESET}"
        sudo apt install -y -qq \
            build-essential \
            libssl-dev \
            zlib1g-dev \
            libbz2-dev \
            libreadline-dev \
            libsqlite3-dev \
            llvm \
            libncursesw5-dev \
            xz-utils \
            tk-dev \
            libxml2-dev \
            libxmlsec1-dev \
            libffi-dev \
            liblzma-dev \
            jq \
            unzip \
            tree \
            htop \
            neofetch
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
install_docker
install_neovim_tools


echo -e "\n${CYBER_GREEN}⚡ CONFIGURAÇÃO INICIAL COMPLETA! ⚡${RESET}"
