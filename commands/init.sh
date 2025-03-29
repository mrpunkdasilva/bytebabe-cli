#!/bin/bash

# Carrega paths absolutos
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Importa módulos
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/utils/config.sh"
source "$BASE_DIR/lib/utils/headers.sh"




# ======================
# CONFIGURAÇÕES BÁSICAS
# ======================
configure_basics() {
    # Configuração do sistema
    echo -e "\n${CYBER_BLUE}▶ Atualizando sistema...${RESET}"
    sudo apt update -qq && sudo apt upgrade -y -qq
    
    # Instala pacotes essenciais
    echo -e "\n${CYBER_BLUE}▶ Instalando ferramentas base...${RESET}"
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
    source "$BASE_DIR/lib/utils/get_docker.sh"

    # Configura usuário
    sudo usermod -aG docker $USER
    echo -e "${CYBER_GREEN}✔ Docker instalado"
    echo -e "${CYBER_ORANGE}⚠ Reinicie o terminal para usar Docker sem sudo${RESET}"

    save_config "DOCKER_INSTALLED" "true"
}









# ======================
# FERRAMENTAS NEOVIM
# ======================
install_neovim_tools() {
   
   echo -e "\n${CYBER_BLUE}▶ Instalando ferramentas neo vim e vim...${RESET}"

   curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
   sudo rm -rf /opt/nvim
   sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

    export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
    export PATH="$PATH:/usr/local/bin"

    # Remova a instalação anterior
    rm -rf ~/.config/nvim
    rm -rf ~/.local/share/nvim
    rm -rf ~/.local/state/nvim

    # Instale novamente
    git clone https://github.com/LazyVim/starter ~/.config/nvim

    echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
    echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.zshrc

    source ~/.bashrc
    source ~/.zshrc


    # Mensagem final de sucesso
    echo -e "\n${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_GREEN}           CONFIGURAÇÃO COMPLETA!"
    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_BLUE}╭─────────────────────────────────────────────╮"
    echo -e "│ ${CYBER_GREEN}✔ Neovim + LazyVim ${CYBER_BLUE}configurados com sucesso!  "
    echo -e "│                                                         "
    echo -e "│ ${CYBER_YELLOW}Próximos passos:${CYBER_BLUE}                                    "
    echo -e "│ 1. Abra o Neovim: ${CYBER_GREEN}nvim${CYBER_BLUE}                          "
    echo -e "│ 2. Aguarde a instalação automática dos plugins           "
    echo -e "│ 3. Reinicie o Neovim após a conclusão                   "
    echo -e "╰─────────────────────────────────────────────╯${RESET}"
    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}\n"
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