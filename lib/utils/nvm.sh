#!/bin/bash

# Função para carregar NVM no shell atual
load_nvm() {
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" >/dev/null 2>&1
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" >/dev/null 2>&1
}

# Função para instalar NVM (Node Version Manager) se necessário
install_nvm_if_needed() {
    # Garantir gawk disponível
    if ! command -v awk &>/dev/null && command -v gawk &>/dev/null; then
        ln -sf "$(command -v gawk)" /usr/local/bin/awk 2>/dev/null || true
    fi

    # Carrega NVM se já existir
    if [ -d "$HOME/.nvm" ]; then
        load_nvm
        if command -v nvm &>/dev/null; then
            echo -e "${CYBER_GREEN}✔ NVM já está instalado${RESET}"
        else
            echo -e "${CYBER_GREEN}✔ NVM já está instalado${RESET}"
        fi
    elif command -v nvm &>/dev/null; then
        echo -e "${CYBER_GREEN}✔ NVM já está instalado${RESET}"
    else
        echo -e "\n${CYBER_BLUE}▶ Instalando NVM (Node Version Manager)...${RESET}"

        if command -v curl &>/dev/null; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        elif command -v wget &>/dev/null; then
            wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        else
            echo -e "${CYBER_RED}✘ curl ou wget necessário para instalar NVM${RESET}"
            return 1
        fi
    fi

    load_nvm

    # Se Node já estiver disponível no PATH, usa ele
    if command -v node &>/dev/null && command -v npm &>/dev/null; then
        echo -e "${CYBER_GREEN}✔ Node.js $(node -v) e npm $(npm -v) já disponíveis${RESET}"
        save_config "NVM_INSTALLED" "true"
        return 0
    fi

    # Tenta instalar via NVM
    if command -v nvm &>/dev/null; then
        echo -e "${CYBER_BLUE}▶ Instalando Node.js LTS via NVM...${RESET}"
        if nvm install --lts >/dev/null 2>&1 && nvm use --lts >/dev/null 2>&1; then
            load_nvm
            hash -r 2>/dev/null
            if command -v node &>/dev/null; then
                echo -e "${CYBER_BLUE}▶ Instalando pacotes globais do npm...${RESET}"
                npm install -g npm@latest >/dev/null 2>&1 || true
                npm install -g yarn >/dev/null 2>&1 || true
                save_config "NVM_INSTALLED" "true"
                echo -e "${CYBER_GREEN}✔ Node.js $(node -v) e npm $(npm -v) configurados${RESET}"
                return 0
            fi
        else
            echo -e "${CYBER_ORANGE}⚠ Falha ao instalar Node via NVM, tentando via gerenciador de pacotes...${RESET}"
        fi
    fi

    # Fallback: instalar via gerenciador de pacotes da distro
    echo -e "${CYBER_BLUE}▶ Instalando Node.js via gerenciador de pacotes...${RESET}"
    local manager
    manager=$(detect_pkg_manager 2>/dev/null || echo "unknown")
    case "$manager" in
        apt)
            if command -v sudo &>/dev/null; then sudo apt-get update -qq && sudo apt-get install -y -qq nodejs npm; fi
            ;;
        dnf)
            if command -v sudo &>/dev/null; then sudo dnf install -y -q nodejs npm; else dnf install -y -q nodejs npm; fi
            ;;
        yum)
            if command -v sudo &>/dev/null; then sudo yum install -y -q nodejs npm; else yum install -y -q nodejs npm; fi
            ;;
        pacman)
            if command -v sudo &>/dev/null; then sudo pacman -S --needed --noconfirm nodejs npm; else pacman -S --needed --noconfirm nodejs npm; fi
            ;;
        zypper)
            if command -v sudo &>/dev/null; then sudo zypper --non-interactive install -y nodejs npm; else zypper --non-interactive install -y nodejs npm; fi
            ;;
        apk)
            if command -v sudo &>/dev/null; then sudo apk add --no-cache nodejs npm; else apk add --no-cache nodejs npm; fi
            ;;
        *)
            echo -e "${CYBER_RED}✘ Não foi possível instalar Node.js automaticamente${RESET}"
            return 1
            ;;
    esac

    hash -r 2>/dev/null
    if command -v node &>/dev/null && command -v npm &>/dev/null; then
        save_config "NVM_INSTALLED" "true"
        echo -e "${CYBER_GREEN}✔ Node.js $(node -v) e npm $(npm -v) configurados${RESET}"
        return 0
    fi

    echo -e "${CYBER_RED}✘ Falha ao instalar Node.js${RESET}"
    return 1
}
