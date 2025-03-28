#!/bin/bash

# ==========================================
# BACKEND COMMANDER - UNIVERSAL INSTALLER
# ==========================================

# Importar cores
source "$(pwd)/lib/core/colors.sh"
source "$(pwd)/lib/core/helpers.sh"

# ==========================================
# DETECÇÃO DE SISTEMA E PKG MANAGER
# ==========================================

detect_pkg_manager() {
    declare -A pkg_managers=(
        ["apt"]="/etc/debian_version"
        ["dnf"]="/etc/redhat-release"
        ["yum"]="/etc/redhat-release"
        ["pacman"]="/etc/arch-release"
        ["zypper"]="/etc/SuSE-release"
        ["brew"]="$HOME/.linuxbrew"
    )

    for manager in "${!pkg_managers[@]}"; do
        if [[ -f "${pkg_managers[$manager]}" ]] || command -v $manager &> /dev/null; then
            echo "$manager"
            return
        fi
    done

    for manager in apt dnf yum pacman zypper brew; do
        if command -v $manager &> /dev/null; then
            echo "$manager"
            return
        fi
    done

    echo "unknown"
}

PKG_MANAGER=$(detect_pkg_manager)

# ==========================================
# FUNÇÕES DE INSTALAÇÃO UNIVERSAL
# ==========================================

install_with_fallback() {
    local pkg=$1
    local pkg_name=${2:-$pkg}

    echo -e "${CYBER_YELLOW}⚡ Tentando instalar $pkg_name via $PKG_MANAGER...${RESET}"

    case $PKG_MANAGER in
        apt)
            sudo apt update && sudo apt install -y $pkg || return 1
            ;;
        dnf|yum)
            sudo $PKG_MANAGER install -y $pkg || return 1
            ;;
        pacman)
            sudo pacman -Sy --noconfirm $pkg || return 1
            ;;
        zypper)
            sudo zypper install -y $pkg || return 1
            ;;
        brew)
            brew install $pkg || return 1
            ;;
        *)
            echo -e "${CYBER_RED}✘ Gerenciador não suportado: $PKG_MANAGER${RESET}"
            return 1
            ;;
    esac
}

# ==========================================
# INSTALAÇÃO DE RUNTIMES
# ==========================================

install_runtime() {
    local runtime=$1
    case $runtime in
        "node")
            echo -e "${CYBER_BLUE}▶ Configurando Node.js...${RESET}"
            if ! command -v nvm &> /dev/null; then
                echo -e "${CYBER_YELLOW}⚡ Instalando NVM...${RESET}"
                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
                source ~/.nvm/nvm.sh
            fi
            nvm install --lts && nvm use --lts
            echo -e "${CYBER_GREEN}✔ Node.js $(node -v) configurado${RESET}"
            ;;

        "python")
            echo -e "${CYBER_BLUE}▶ Verificando Python...${RESET}"
            if ! command -v python3 &> /dev/null; then
                if ! install_with_fallback "python3" "Python"; then
                    echo -e "${CYBER_PINK}⚡ Instalando Python from source...${RESET}"
                    sudo apt update
                    sudo apt install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev \
                    libssl-dev libreadline-dev libffi-dev wget
                    curl -O https://www.python.org/ftp/python/3.10.12/Python-3.10.12.tgz
                    tar xzf Python-3.10.12.tgz
                    cd Python-3.10.12
                    ./configure --enable-optimizations
                    make -j$(nproc)
                    sudo make altinstall
                    cd ..
                    rm -rf Python-3.10.12*
                fi
            fi
            echo -e "${CYBER_GREEN}✔ Python $(python3 --version) instalado${RESET}"
            ;;

        "java")
            echo -e "${CYBER_BLUE}▶ Configurando Java...${RESET}"
            if ! command -v java &> /dev/null; then
                if ! command -v sdk &> /dev/null; then
                    echo -e "${CYBER_YELLOW}⚡ Instalando SDKMAN...${RESET}"
                    curl -s "https://get.sdkman.io" | bash
                    source "$HOME/.sdkman/bin/sdkman-init.sh"
                fi
                sdk install java 17.0.8-tem
            fi
            echo -e "${CYBER_GREEN}✔ Java $(java -version 2>&1 | head -n 1) configurado${RESET}"
            ;;

        "go")
            echo -e "${CYBER_BLUE}▶ Configurando Go...${RESET}"
            if ! command -v go &> /dev/null; then
                if ! install_with_fallback "golang" "Go"; then
                    echo -e "${CYBER_PINK}⚡ Instalando Go from source...${RESET}"
                    curl -LO https://golang.org/dl/go1.20.4.linux-amd64.tar.gz
                    sudo tar -C /usr/local -xzf go1.20.4.linux-amd64.tar.gz
                    export PATH=$PATH:/usr/local/go/bin
                    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
                    rm go1.20.4.linux-amd64.tar.gz
                fi
            fi
            echo -e "${CYBER_GREEN}✔ Go $(go version) instalado${RESET}"
            ;;

        "rust")
            echo -e "${CYBER_BLUE}▶ Configurando Rust...${RESET}"
            if ! command -v rustc &> /dev/null; then
                echo -e "${CYBER_YELLOW}⚡ Instalando Rust...${RESET}"
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                source "$HOME/.cargo/env"
            fi
            echo -e "${CYBER_GREEN}✔ Rust $(rustc --version) instalado${RESET}"
            ;;
    esac
}

# ==========================================
# INSTALAÇÃO DE FRAMEWORKS
# ==========================================

install_framework() {
    local framework=$1
    case $framework in
        "express")
            echo -e "${CYBER_BLUE}▶ Instalando Express Generator...${RESET}"
            npm install -g express-generator
            echo -e "${CYBER_GREEN}✔ Express Generator instalado${RESET}"
            ;;

        "django")
            echo -e "${CYBER_BLUE}▶ Instalando Django...${RESET}"
            pip3 install django
            echo -e "${CYBER_GREEN}✔ Django $(django-admin --version) instalado${RESET}"
            ;;

        "flask")
            echo -e "${CYBER_BLUE}▶ Instalando Flask...${RESET}"
            pip3 install flask
            echo -e "${CYBER_GREEN}✔ Flask instalado${RESET}"
            ;;

        "spring")
            echo -e "${CYBER_BLUE}▶ Spring Boot detectado...${RESET}"
            echo -e "${CYBER_GREEN}✔ Spring Boot (pronto para uso com Java)${RESET}"
            ;;

        "nestjs")
            echo -e "${CYBER_BLUE}▶ Instalando NestJS CLI...${RESET}"
            npm install -g @nestjs/cli
            echo -e "${CYBER_GREEN}✔ NestJS CLI instalado${RESET}"
            ;;

        "laravel")
            echo -e "${CYBER_BLUE}▶ Verificando PHP...${RESET}"
            if ! command -v php &> /dev/null; then
                echo -e "${CYBER_YELLOW}⚡ Instalando PHP...${RESET}"
                if ! install_with_fallback "php" "PHP"; then
                    echo -e "${CYBER_RED}✘ Falha ao instalar PHP. Instale manualmente e tente novamente.${RESET}"
                    return 1
                fi
            fi

            echo -e "${CYBER_GREEN}✔ PHP $(php -v | head -n 1) instalado${RESET}"

            echo -e "${CYBER_BLUE}▶ Verificando Composer...${RESET}"
            if ! command -v composer &> /dev/null; then
                echo -e "${CYBER_YELLOW}⚡ Instalando Composer...${RESET}"
                EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
                php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
                ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

                if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then
                    echo -e "${CYBER_RED}✘ Checksum do Composer inválido!${RESET}"
                    rm composer-setup.php
                    return 1
                fi

                php composer-setup.php --install-dir=/usr/local/bin --filename=composer
                RESULT=$?
                rm composer-setup.php

                if [ $RESULT -ne 0 ]; then
                    echo -e "${CYBER_RED}✘ Falha na instalação do Composer${RESET}"
                    return $RESULT
                fi
            fi

            echo -e "${CYBER_GREEN}✔ Composer $(composer --version) instalado${RESET}"

            echo -e "${CYBER_BLUE}▶ Instalando Laravel Installer...${RESET}"
            composer global require laravel/installer
            echo -e "${CYBER_GREEN}✔ Laravel Installer instalado${RESET}"

            # Adiciona Composer ao PATH se não estiver
            if [[ ":$PATH:" != *":$HOME/.config/composer/vendor/bin:"* ]]; then
                echo -e "${CYBER_YELLOW}⚠ Adicionando Composer ao PATH...${RESET}"
                echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> ~/.bashrc
                source ~/.bashrc
            fi

            echo -e "${CYBER_PINK}⚡ Laravel configurado com sucesso!${RESET}"
            echo -e "${CYBER_YELLOW}Execute: ${CYBER_PINK}laravel new projeto${RESET}"
            ;;
    esac
}

# ==========================================
# MENUS INTERATIVOS
# ==========================================

show_backend_header() {
    clear
    echo -e "${CYBER_BG_DARK}${CYBER_PINK}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║   ██████╗  █████╗  ██████╗██╗  ██╗███████╗  ║"
    echo "║   ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔════╝  ║"
    echo "║   ██████╔╝███████║██║     █████╔╝ █████╗    ║"
    echo "║   ██╔══██╗██╔══██║██║     ██╔═██╗ ██╔══╝    ║"
    echo "║   ██████╔╝██║  ██║╚██████╗██║  ██╗███████╗  ║"
    echo "║   ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝  ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
    cyber_divider
}

select_runtimes() {
    echo -e "${CYBER_YELLOW}● SELECIONE SEUS RUNTIMES (separados por vírgulas ou 6 para todos):${RESET}"
    echo -e "${CYBER_BLUE}1) Node.js"
    echo -e "2) Python"
    echo -e "3) Java"
    echo -e "4) Go"
    echo -e "5) Rust"
    echo -e "6) Todos${RESET}"
    read -p "Opções (ex: 1,3,5): " runtime_choices

    # Converter entrada em array
    IFS=',' read -ra choices <<< "$runtime_choices"

    if [[ " ${choices[*]} " =~ "6" ]]; then
      runtimes=("node" "python" "java" "go" "rust")
    else
        runtimes=()
        for choice in "${choices[@]}"; do
            case $choice in
                1) runtimes+=("node") ;;
                2) runtimes+=("python") ;;
                3) runtimes+=("java") ;;
                4) runtimes+=("go") ;;
                5) runtimes+=("rust") ;;
            esac
        done
    fi

    for rt in "${runtimes[@]}"; do
        install_runtime "$rt"
    done
}

select_frameworks() {
    echo -e "\n${CYBER_YELLOW}● SELECIONE SEUS FRAMEWORKS (separados por vírgulas ou 7 para todos):${RESET}"
    echo -e "${CYBER_BLUE}1) Express.js"
    echo -e "2) Django"
    echo -e "3) Flask"
    echo -e "4) Spring Boot"
    echo -e "5) NestJS"
    echo -e "6) Laravel"
    echo -e "7) Todos${RESET}"
    read -p "Opções (ex: 2,4,6): " fw_choices

    # Converter entrada em array
    IFS=',' read -ra choices <<< "$fw_choices"

    if [[ " ${choices[*]} " == *"7"* ]]; then
        frameworks=("express" "django" "flask" "spring" "nestjs" "laravel")
    else
        frameworks=()
        for choice in "${choices[@]}"; do
            case $choice in
                1) frameworks+=("express") ;;
                2) frameworks+=("django") ;;
                3) frameworks+=("flask") ;;
                4) frameworks+=("spring") ;;
                5) frameworks+=("nestjs") ;;
                6) frameworks+=("laravel") ;;
            esac
        done
    fi

    for fw in "${frameworks[@]}"; do
        install_framework "$fw"
    done
}


# ==========================================
# PROCESSAMENTO DE COMANDOS
# ==========================================

process_setup() {
    show_backend_header

    # Instalar runtimes
    select_runtimes

    # Instalar frameworks (condicional)
   for rt in "${runtimes[@]}"; do
        if [[ "$rt" == "node" || "$rt" == "python" ]]; then
            select_frameworks
            break
        fi
    done

    if [[ "$rt" != "node" && "$rt" != "python" ]]; then
        echo -e "${CYBER_YELLOW}⚠ Frameworks disponíveis apenas para Node.js/Python${RESET}"
    fi

    # Finalização
    echo -e "\n${CYBER_PINK}⚡ BACKEND CONFIGURADO! ⚡${RESET}"
    echo -e "${CYBER_BLUE}Resumo:"
    echo -e "• Runtimes: ${runtimes[*]}"
    echo -e "• Frameworks: ${frameworks[*]}${RESET}"
    echo -e "\n${CYBER_YELLOW}Dica: Use ${CYBER_PINK}bytebabe db${RESET} ${CYBER_YELLOW}para bancos de dados${RESET}"
}

show_help() {
    show_backend_header
    echo -e "${CYBER_BLUE}USO: bytebabe backend [comando]"
    echo -e "\nCOMANDOS DISPONÍVEIS:"
    echo -e "  ${CYBER_PINK}setup${RESET}    - Configura ambiente backend"
    echo -e "  ${CYBER_PINK}help${RESET}     - Mostra esta ajuda"
    echo -e "\nEXEMPLOS:"
    echo -e "  ${CYBER_YELLOW}bytebabe backend setup"
    echo -e "  ${CYBER_YELLOW}bytebabe backend help${RESET}"
    cyber_divider
}

# ==========================================
# FUNÇÃO PRINCIPAL
# ==========================================

main() {
    case $1 in
        "setup")
            process_setup
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            echo -e "${CYBER_RED}⚠ Comando inválido! Use 'help' para ver as opções${RESET}"
            ;;
    esac
}

# Iniciar
main "$@"