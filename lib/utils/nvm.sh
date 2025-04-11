#!/bin/bash

# Função para instalar NVM (Node Version Manager) se necessário
install_nvm_if_needed() {
    # Verifica se NVM já está instalado
    if [ -d "$HOME/.nvm" ] || command -v nvm &>/dev/null; then
        echo -e "${CYBER_GREEN}✔ NVM já está instalado${RESET}"
        return 0
    fi

    echo -e "\n${CYBER_BLUE}▶ Instalando NVM (Node Version Manager)...${RESET}"
    
    # Baixa e instala NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    
    # Configura NVM no ambiente atual
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Verifica se a instalação foi bem-sucedida
    if command -v nvm &>/dev/null; then
        echo -e "${CYBER_GREEN}✔ NVM instalado com sucesso${RESET}"
        
        # Instala a versão LTS do Node.js
        echo -e "${CYBER_BLUE}▶ Instalando Node.js LTS...${RESET}"
        nvm install --lts
        nvm use --lts
        
        # Configura alguns pacotes globais úteis
        echo -e "${CYBER_BLUE}▶ Instalando pacotes globais do npm...${RESET}"
        npm install -g npm@latest
        npm install -g yarn
        
        # Salva configuração
        save_config "NVM_INSTALLED" "true"
        
        echo -e "${CYBER_GREEN}✔ Node.js $(node -v) e npm $(npm -v) configurados${RESET}"
    else
        echo -e "${CYBER_RED}✘ Falha ao instalar NVM${RESET}"
        return 1
    fi
}
