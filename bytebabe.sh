#!/bin/bash

# Cores cyberpunk
CYBER_BLUE="\033[38;5;45m"
CYBER_PINK="\033[38;5;201m"
CYBER_GREEN="\033[38;5;118m"
CYBER_YELLOW="\033[38;5;227m"
CYBER_ORANGE="\033[38;5;208m"
RESET="\033[0m"

# Verificar se é root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${CYBER_ORANGE}⚠ Este script requer privilégios root.${RESET}"
        echo -e "Por favor execute com:"
        echo -e "sudo bash $0"
        exit 1
    fi
}

# Header ASCII
clear
echo -e "${CYBER_PINK}"
cat << "EOF"

888888b.          888           888888b.          888              
888  "88b         888           888  "88b         888              
888  .88P         888           888  .88P         888              
8888888K. 888  888888888 .d88b. 8888888K.  8888b. 88888b.  .d88b.  
888  "Y88b888  888888   d8P  Y8b888  "Y88b    "88b888 "88bd8P  Y8b 
888    888888  888888   88888888888    888.d888888888  88888888888 
888   d88PY88b 888Y88b. Y8b.    888   d88P888  888888 d88PY8b.     
8888888P"  "Y88888 "Y888 "Y8888 8888888P" "Y88888888888P"  "Y8888  
               888                                                 
          Y8b d88P                                                 
           "Y88P"                                                  


EOF
echo -e "${CYBER_BLUE}"
cat << "EOF"
                           ╱|、
                          (˚ˎ 。7  
                           |、˜〵          
                           じしˍ,)ノ
EOF
echo -e "${RESET}"

# Verificar se é root
check_root


# Configuração principal
echo -e "\n${CYBER_ORANGE}⚡ CONFIGURANDO SEU SISTEMA ZORIN OS${RESET}"

# Verificar e instalar sudo se necessário
if ! command -v sudo &> /dev/null; then
    echo -e "\n${CYBER_BLUE}▶ Instalando sudo...${RESET}"
    apt update && apt install -y sudo || {
        echo -e "${CYBER_ORANGE}⚠ Não foi possível instalar o sudo.${RESET}"
        exit 1
    }
fi

# Atualizar repositórios
echo -e "\n${CYBER_BLUE}▶ Atualizando repositórios...${RESET}"
apt update -qq || {
    echo -e "${CYBER_ORANGE}⚠ Falha ao atualizar repositórios. Verifique sua conexão.${RESET}"
    exit 1
}

# Instalar pacotes essenciais
ESSENTIALS=("git" "curl" "wget" "build-essential" "software-properties-common")
for pkg in "${ESSENTIALS[@]}"; do
    echo -e "\n${CYBER_BLUE}▶ Instalando $pkg...${RESET}"
    apt install -y $pkg || {
        echo -e "${CYBER_ORANGE}⚠ Falha ao instalar $pkg${RESET}"
    }
done

# Configurar Flatpak
echo -e "\n${CYBER_BLUE}▶ Configurando Flatpak...${RESET}"
if ! command -v flatpak &> /dev/null; then
    apt install -y flatpak && {
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        echo -e "${CYBER_GREEN}✔ Flatpak configurado com sucesso${RESET}"
    } || {
        echo -e "${CYBER_ORANGE}⚠ Flatpak não pôde ser instalado${RESET}"
    }
else
    echo -e "${CYBER_GREEN}✔ Flatpak já está instalado${RESET}"
fi





#=========================== DOCKER

# Instalar Docker usando o script oficial
echo -e "\n${CYBER_BLUE}▶ Instalando Docker via get.docker.com...${RESET}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    
    # Adicionar usuário ao grupo docker
    usermod -aG docker $SUDO_USER
    echo -e "${CYBER_GREEN}✔ Docker $(docker --version) instalado${RESET}"
    echo -e "${CYBER_BLUE}⚠ Reinicie o sistema para aplicar as permissões do Docker${RESET}"
else
    echo -e "${CYBER_GREEN}✔ Docker já instalado (versão: $(docker --version))${RESET}"
fi

# Testar Docker
echo -e "\n${CYBER_BLUE}▶ Testando Docker...${RESET}"
if docker run --rm hello-world | grep -q "Hello from Docker!"; then
    echo -e "${CYBER_GREEN}✔ Docker funcionando corretamente${RESET}"
else
    echo -e "${CYBER_ORANGE}⚠ Docker instalado mas não está funcionando corretamente${RESET}"
fi




#======================== GIT
# Configuração do Git
echo -e "\n${CYBER_PINK}⚡ CONFIGURAÇÃO DO GIT${RESET}"

# Verificar se o Git está instalado
if ! command -v git &> /dev/null; then
    echo -e "${CYBER_ORANGE}⚠ Git não está instalado${RESET}"
    echo -e "${CYBER_BLUE}▶ Instalando Git...${RESET}"
    sudo apt update && sudo apt install -y git
    echo -e "${CYBER_GREEN}✔ Git instalado (versão: $(git --version))${RESET}"
else
    echo -e "${CYBER_GREEN}✔ Git já instalado (versão: $(git --version))${RESET}"
fi

# Configurar identidade
echo -e "\n${CYBER_BLUE}▶ Configurando identidade Git${RESET}"

current_name=$(git config --global user.name)
current_email=$(git config --global user.email)

if [ -z "$current_name" ]; then
    read -p "Digite seu nome para commits Git: " git_name
    git config --global user.name "$git_name"
else
    echo -e "${CYBER_GREEN}✔ Nome já configurado: ${current_name}${RESET}"
fi

if [ -z "$current_email" ]; then
    read -p "Digite seu email para commits Git: " git_email
    git config --global user.email "$git_email"
else
    echo -e "${CYBER_GREEN}✔ Email já configurado: ${current_email}${RESET}"
fi

# Configurações adicionais recomendadas
echo -e "\n${CYBER_BLUE}▶ Aplicando configurações recomendadas${RESET}"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.editor "code --wait"

echo -e "\n${CYBER_GREEN}⚡ CONFIGURAÇÃO COMPLETA!${RESET}"
echo -e "${CYBER_PINK}Seu Git está pronto para commits rebeldes!${RESET}"

# Mostrar configuração final
echo -e "\n${CYBER_BLUE}═╦═ CONFIGURAÇÃO ATUAL ═╦═${RESET}"
git config --global --list | grep -E "user.name|user.email|init.defaultbranch"
echo -e "${CYBER_BLUE}═╩══════════════════════╩═${RESET}\n"




#===================================== IDE
echo -e "\n${CYBER_PINK}⚡ INSTALAÇÃO DE FERRAMENTAS DE DESENVOLVIMENTO${RESET}"

# 1. Instalar JetBrains Toolbox
echo -e "\n${CYBER_BLUE}▶ Instalando JetBrains Toolbox...${RESET}"
mkdir -p ~/.local/share/JetBrains
cd ~/.local/share/JetBrains || exit

# Baixar e extrair a versão específica
wget -qO- https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.4.38621.tar.gz | tar -xvz
sudo mv jetbrains-toolbox-*/jetbrains-toolbox /usr/local/bin/
rm -rf jetbrains-toolbox-*

# Criar atalho
cat > ~/.local/share/applications/jetbrains-toolbox.desktop <<EOL
[Desktop Entry]
Name=JetBrains Toolbox
Exec=/usr/local/bin/jetbrains-toolbox
Icon=jetbrains-toolbox
Terminal=false
Type=Application
Categories=Development;
StartupWMClass=jetbrains-toolbox
EOL

echo -e "${CYBER_GREEN}✔ Toolbox instalado em /usr/local/bin/jetbrains-toolbox${RESET}"

# 2. Instalar VSCode via Flatpak
echo -e "\n${CYBER_BLUE}▶ Configurando Flatpak...${RESET}"
if ! command -v flatpak &> /dev/null; then
    sudo apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo -e "${CYBER_GREEN}✔ Flatpak instalado${RESET}"
fi

echo -e "\n${CYBER_BLUE}▶ Instalando VSCode...${RESET}"
flatpak install -y flathub com.visualstudio.code
echo -e "${CYBER_GREEN}✔ VSCode instalado via Flatpak${RESET}"

# 3. Finalização
echo -e "\n${CYBER_GREEN}⚡ INSTALAÇÃO COMPLETA!${RESET}"
echo -e "${CYBER_PINK}Ferramentas prontas para uso:${RESET}"
echo -e "- JetBrains Toolbox: execute 'jetbrains-toolbox'"
echo -e "- VSCode: execute 'flatpak run com.visualstudio.code'"
echo -e "\n${CYBER_BLUE}Dica: Adicione /usr/local/bin ao seu PATH se ainda não estiver${RESET}"







#=========================== CHOSE STACK

# Função para instalar Node via NVM
install_node_nvm() {
    echo -e "\n${CYBER_BLUE}▶ Instalando NVM e Node.js...${RESET}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    echo -e "${CYBER_GREEN}✔ Node.js $(node -v) via NVM instalado${RESET}"
}

# Menu de perfil
echo -e "\n${CYBER_PINK}⚡ SELECIONE SEU PERFIL ⚡${RESET}"
echo -e "${CYBER_BLUE}1) Frontend"
echo -e "2) Backend"
echo -e "3) Fullstack${RESET}"
read -p "Escolha (1-3): " dev_type

# Fluxo Frontend
if [ "$dev_type" == "1" ]; then
    echo -e "\n${CYBER_PINK}⚡ CONFIGURAÇÃO FRONTEND ⚡${RESET}"
    
    # Instala Node via NVM
    install_node_nvm

    # Gerenciador de pacotes
    echo -e "\n${CYBER_YELLOW}● ESCOLHA SEU GERENCIADOR (ou 5 para todos):${RESET}"
    echo -e "${CYBER_BLUE}1) npm"
    echo -e "2) yarn"
    echo -e "3) pnpm"
    echo -e "4) bun"
    echo -e "5) Todos${RESET}"
    read -p "Opção (1-5): " pkg_manager

    case $pkg_manager in
        1) npm_list=("npm") ;;
        2) npm_list=("yarn") ;;
        3) npm_list=("pnpm") ;;
        4) npm_list=("bun") ;;
        5) npm_list=("npm" "yarn" "pnpm" "bun") ;;
    esac

    for pkg in "${npm_list[@]}"; do
        case $pkg in
            "yarn") 
                npm install -g yarn
                echo -e "${CYBER_GREEN}✔ Yarn $(yarn --version) instalado${RESET}" ;;
            "pnpm") 
                npm install -g pnpm
                echo -e "${CYBER_GREEN}✔ pnpm $(pnpm --version) instalado${RESET}" ;;
            "bun") 
                curl -fsSL https://bun.sh/install | bash
                echo -e "${CYBER_GREEN}✔ Bun instalado${RESET}" ;;
            *) 
                echo -e "${CYBER_GREEN}✔ npm $(npm --version) (pré-instalado)${RESET}" ;;
        esac
    done

    # Frameworks (com opção TODOS)
    echo -e "\n${CYBER_YELLOW}● ESCOLHA SEU FRAMEWORK (ou 5 para todos):${RESET}"
    echo -e "${CYBER_BLUE}1) React"
    echo -e "2) Vue"
    echo -e "3) Angular"
    echo -e "4) Next.js"
    echo -e "5) Todos${RESET}"
    read -p "Opção (1-5): " framework

    case $framework in
        1) frameworks=("react") ;;
        2) frameworks=("vue") ;;
        3) frameworks=("angular") ;;
        4) frameworks=("next") ;;
        5) frameworks=("react" "vue" "angular" "next") ;;
    esac

    for fw in "${frameworks[@]}"; do
        case $fw in
            "react")
                npm install -g create-react-app create-vite
                echo -e "${CYBER_GREEN}✔ React + Vite instalados${RESET}" ;;
            "vue")
                npm install -g @vue/cli
                echo -e "${CYBER_GREEN}✔ Vue CLI $(vue --version) instalado${RESET}" ;;
            "angular")
                npm install -g @angular/cli
                echo -e "${CYBER_GREEN}✔ Angular CLI instalado${RESET}" ;;
            "next")
                npm install -g create-next-app
                echo -e "${CYBER_GREEN}✔ Next.js instalado${RESET}" ;;
        esac
    done

    # Finalização
    echo -e "\n${CYBER_PINK}⚡ CONFIGURAÇÃO COMPLETA! ⚡${RESET}"
    echo -e "${CYBER_BLUE}Ferramentas instaladas:"
    echo -e "• Node.js $(node -v) (via NVM)"
    echo -e "• Gerenciadores: ${npm_list[*]}"
    echo -e "• Frameworks: ${frameworks[*]}${RESET}"
fi


























# Conclusão
echo -e "\n${CYBER_GREEN}⚡ CONFIGURAÇÃO CONCLUÍDA!${RESET}"
echo -e "${CYBER_PINK}Byte Babe está pronta para ação! ${RESET}\n"

# Dica final
echo -e "${CYBER_BLUE}Dica: Reinicie seu terminal ou execute:${RESET}"
echo -e "source ~/.bashrc\n"