#!/bin/bash

# Carrega paths absolutos
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Importa módulos
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/utils/config.sh"
source "$BASE_DIR/lib/utils/headers.sh"

show_cyberpunk_header
load_config  # Carrega config antes de qualquer operação

echo -e "\n${CYBER_PINK}⚡ INICIALIZANDO BYTEBABE CLI ⚡${RESET}"


# ======================
# VERIFICA DEPENDÊNCIAS
# ======================
check_dependencies curl wget git



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

configure_basics




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

configure_git_identity







# ======================
#  INSTALAÇÃO DO NVM
# ======================
install_nvm_if_needed() {
    if [ ! -d "$HOME/.nvm" ]; then
        echo -e "\n${CYBER_BLUE}▶ Instalando NVM...${RESET}"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
        save_config "NVM_INSTALLED" "true"
        echo -e "${CYBER_GREEN}✔ NVM instalado\nReinicie o terminal antes de usar${RESET}"
    fi
}

install_nvm_if_needed






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

install_docker






# ======================
# FERRAMENTAS NEOVIM
# ======================
install_neovim_tools() {
   
   echo -e "\n${CYBER_BLUE}▶ Instalando ferramentas extras...${RESET}"

    # Detectar gerenciador de pacotes
    detect_pkg_manager() {
        if command -v apt &> /dev/null; then
            echo "apt"
        elif command -v dnf &> /dev/null; then
            echo "dnf"
        elif command -v yum &> /dev/null; then
            echo "yum"
        elif command -v pacman &> /dev/null; then
            echo "pacman"
        elif command -v zypper &> /dev/null; then
            echo "zypper"
        else
            echo "unknown"
        fi
    }

    PKG_MANAGER=$(detect_pkg_manager)

    # Instalação de editores
    case $PKG_MANAGER in
        "apt")
            sudo apt install -y -qq neovim vim
            ;;
        "dnf"|"yum")
            sudo $PKG_MANAGER install -y neovim vim
            ;;
        "pacman")
            sudo pacman -S --noconfirm neovim vim
            ;;
        "zypper")
            sudo zypper install -y neovim vim
            ;;
        *)
            echo -e "${CYBER_ORANGE}⚠ Instale o Neovim manualmente para sua distro${RESET}"
            ;;
    esac

   
    # Configuração do LazyVim (universal)
    configure_lazyvim() {
        NVIM_DIR="$HOME/.config/nvim"
        LAZYVIM_REPO="https://github.com/LazyVim/starter.git"

        # Backup
        if [ -d "$NVIM_DIR" ]; then
            echo -e "${CYBER_ORANGE}⚠ Backup da configuração do Neovim em ${NVIM_DIR}.bak${RESET}"
            mv "$NVIM_DIR" "${NVIM_DIR}.bak"
        fi

        # Instalação
        git clone --depth 1 "$LAZYVIM_REPO" "$NVIM_DIR"
    }
    configure_lazyvim

 
    # Dependências para LazyVim
    install_lazyvim_deps() {
        case $PKG_MANAGER in
            "apt")
                sudo apt install -y -qq ripgrep fd-find python3-pip nodejs npm
                ;;
            "dnf"|"yum")
                sudo $PKG_MANAGER install -y ripgrep fd-find python3-pip nodejs npm
                ;;
            "pacman")
                sudo pacman -S --noconfirm ripgrep fd python-pip nodejs npm
                ;;
            "zypper")
                sudo zypper install -y ripgrep fd python3-pip nodejs npm
                ;;
            *)
                echo -e "${CYBER_ORANGE}⚠ Instale manualmente: ripgrep, fd, pip, nodejs${RESET}"
                ;;
        esac
    }
    install_lazyvim_deps


    # Mensagem final de sucesso
    echo -e "\n${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_GREEN}           CONFIGURAÇÃO COMPLETA!"
    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_BLUE}╭─────────────────────────────────────────────╮"
    echo -e "│ ${CYBER_GREEN}✔ Neovim + LazyVim ${CYBER_BLUE}configurados com sucesso!  │"
    echo -e "│                                                         │"
    echo -e "│ ${CYBER_YELLOW}Próximos passos:${CYBER_BLUE}                                    │"
    echo -e "│ 1. Abra o Neovim: ${CYBER_GREEN}nvim${CYBER_BLUE}                          │"
    echo -e "│ 2. Aguarde a instalação automática dos plugins           │"
    echo -e "│ 3. Reinicie o Neovim após a conclusão                   │"
    echo -e "╰─────────────────────────────────────────────╯${RESET}"
    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}\n"
}

install_neovim_tools






echo -e "\n${CYBER_GREEN}⚡ CONFIGURAÇÃO INICIAL COMPLETA! ⚡${RESET}"