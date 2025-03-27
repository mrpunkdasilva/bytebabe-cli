#!/bin/bash

source "../core/colors.sh"
source "../core/helpers.sh"
source "../utils/config.sh"
source "../utils/headers.sh"

show_cyberpunk_header
load_config

echo -e "\n${CYBER_PINK}⚡ INICIALIZANDO BYTEBABE CLI ⚡${RESET}"

# Dependências básicas
check_dependencies curl wget git

# Configuração do usuário
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

# Instala NVM se necessário
if [ ! -d "$HOME/.nvm" ]; then
    echo -e "${CYBER_BLUE}▶ Instalando NVM...${RESET}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
    save_config "NVM_INSTALLED" "true"
fi

echo -e "\n${CYBER_GREEN}⚡ CONFIGURAÇÃO INICIAL COMPLETA! ⚡${RESET}"