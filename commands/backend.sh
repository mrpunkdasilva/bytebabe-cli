#!/bin/bash

# ==========================================
# BACKEND COMMANDER - UNIVERSAL INSTALLER
# ==========================================

# Carrega bibliotecas
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

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
# LISTA DE TECNOLOGIAS SUPORTADAS
# ==========================================

declare -A SUPPORTED_TECHS=(
    ["node"]="Node.js"
    ["php"]="PHP"
    ["python"]="Python"
    ["java"]="Java"
    ["go"]="Go"
    ["rust"]="Rust"
    ["express"]="Express.js"
    ["django"]="Django"
    ["flask"]="Flask"
    ["spring"]="Spring Boot"
    ["nestjs"]="NestJS"
    ["laravel"]="Laravel"
    ["elixir"]="Elixir"
)

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

        "php")
            echo -e "${CYBER_BLUE}▶ Configurando PHP...${RESET}"
            if ! command -v php &> /dev/null; then
                if ! install_with_fallback "php" "PHP"; then
                    echo -e "${CYBER_PINK}⚡ Tentando instalar PHP from source...${RESET}"

                    # Dependências para compilação
                    sudo apt update
                    sudo apt install -y build-essential libxml2-dev libssl-dev \
                        zlib1g-dev libcurl4-openssl-dev libonig-dev libsqlite3-dev

                    PHP_VERSION="8.2.10"
                    wget https://www.php.net/distributions/php-${PHP_VERSION}.tar.gz
                    tar -xzf php-${PHP_VERSION}.tar.gz
                    cd php-${PHP_VERSION}
                    ./configure --prefix=/usr/local/php \
                                --with-openssl \
                                --with-zlib \
                                --enable-mbstring \
                                --with-curl
                    make -j$(nproc)
                    sudo make install

                    # Adiciona ao PATH
                    echo 'export PATH="/usr/local/php/bin:$PATH"' >> ~/.bashrc
                    source ~/.bashrc
                    cd .. && rm -rf php-${PHP_VERSION}*
                fi
            fi
            echo -e "${CYBER_GREEN}✔ PHP $(php -v | head -n 1 | cut -d' ' -f1-2) instalado${RESET}"
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
        "elixir")
        echo -e "${CYBER_BLUE}▶ Configurando Elixir...${RESET}"
        if ! command -v elixir &> /dev/null; then
            echo -e "${CYBER_YELLOW}⚡ Instalando Elixir...${RESET}"
            curl -fsSO https://elixir-lang.org/install.sh
            sh install.sh elixir@1.18.3 otp@27.2.3
            installs_dir=$HOME/.elixir-install/installs
            export PATH=$installs_dir/otp/27.2.3/bin:$PATH
            export PATH=$installs_dir/elixir/1.18.3-otp-27/bin:$PATH
        fi
        echo -e "${CYBER_GREEN}✔ Elixir $(elixir --version) instalado${RESET}"
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
            echo -e "${CYBER_BLUE}▶ Verificando dependências para Laravel...${RESET}"

            # Verifica PHP
            if ! command -v php &> /dev/null; then
                echo -e "${CYBER_YELLOW}⚠ PHP não encontrado. Instale primeiro com:${RESET}"
                echo -e "${CYBER_PINK}bytebabe backend install php${RESET}"
                return 1
            fi

            echo -e "${CYBER_BLUE}▶ Verificando Composer...${RESET}"

            if ! command -v composer &> /dev/null; then
                echo -e "${CYBER_YELLOW}⚡ Instalando Composer...${RESET}"

                php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
                php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }"
                php composer-setup.php
                php -r "unlink('composer-setup.php');"

                sudo mv composer.phar /usr/local/bin/composer

                if [ $RESULT -ne 0 ]; then
                    echo -e "${CYBER_RED}✘ Falha na instalação do Composer${RESET}"
                    return $RESULT
                fi
            fi

            echo -e "${CYBER_GREEN}✔ Composer $(composer --version) instalado${RESET}"

            echo -e "${CYBER_BLUE}▶ Instalando Laravel Installer...${RESET}"
            composer global require laravel/installer

            echo -e "${CYBER_GREEN}✔ Laravel Installer instalado${RESET}"
            echo -e "${CYBER_PINK}⚡ Use: ${CYBER_YELLOW}laravel new projeto${RESET} para criar um novo projeto"
            ;;
        "phoenix")
            echo -e "${CYBER_BLUE}▶ Instalando Phoenix...${RESET}"
            if ! command -v mix &> /dev/null; then
                echo -e "${CYBER_YELLOW}⚠ Elixir não encontrado. Instale primeiro com:${RESET}"
                echo -e "${CYBER_PINK}bytebabe backend install elixir${RESET}"
            fi

            echo -e "${CYBER_PINK}⚡ Instalando Hex (gerenciador de pacotes)...${RESET}"
            mix local.hex --force

            echo -e "${CYBER_PINK}⚡ Instalando Phoenix...${RESET}"
            mix archive.install hex phx_new 1.7.21

            echo -e "${CYBER_GREEN}✔ Phoenix instalado com sucesso!${RESET}"
            echo -e "${CYBER_PINK}Dica: Use ${CYBER_YELLOW}mix phx.new meu_app${RESET} para criar um novo projeto Phoenix${RESET}"
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

show_backend_menu() {
    echo -e "${CYBER_BLUE}${CYBER_BOLD}  ⚡ MENU DE CONFIGURAÇÃO BACKEND ⚡${RESET}"
    echo ""
    echo -e "${CYBER_PINK}1) Configuração Interativa"
    echo -e "2) Instalar Tecnologia Específica"
    echo -e "3) Listar Tecnologias Suportadas"
    echo -e "4) Ajuda"
    echo -e "0) Voltar${RESET}"
    echo ""
    cyber_divider
}

select_runtimes() {
    echo -e "${CYBER_YELLOW}● SELECIONE SEUS RUNTIMES (separados por vírgulas ou 7 para todos):${RESET}"
    echo -e "${CYBER_BLUE}1) Node.js"
    echo -e "2) PHP"
    echo -e "3) Python"
    echo -e "4) Java"
    echo -e "5) Go"
    echo -e "6) Rust"
    echo -e "7) Elixir"
    echo -e "8) Todos${RESET}"
    read -p "Opções (ex: 1,3,5): " runtime_choices

    IFS=',' read -ra choices <<< "$runtime_choices"

    if [[ " ${choices[*]} " =~ "7" ]]; then
        runtimes=("node" "php" "python" "java" "go" "rust" "elixir")
    else
        runtimes=()
        for choice in "${choices[@]}"; do
            case $choice in
                1) runtimes+=("node") ;;
                2) runtimes+=("php") ;;
                3) runtimes+=("python") ;;
                4) runtimes+=("java") ;;
                5) runtimes+=("go") ;;
                6) runtimes+=("rust") ;;
                7) runtimes+=("elixir") ;;
            esac
        done
    fi

    for rt in "${runtimes[@]}"; do
        install_runtime "$rt"
    done
}

select_frameworks() {
    echo -e "\n${CYBER_YELLOW}● SELECIONE SEUS FRAMEWORKS (separados por vírgulas ou 8 para todos):${RESET}"
    echo -e "${CYBER_BLUE}1) Express.js"
    echo -e "2) Django"
    echo -e "3) Flask"
    echo -e "4) Spring Boot"
    echo -e "5) NestJS"
    echo -e "6) Laravel"
    echo -e "7) Phoenix"
    echo -e "8) Todos${RESET}"
    read -p "Opções (ex: 2,4,6): " fw_choices

    IFS=',' read -ra choices <<< "$fw_choices"

    if [[ " ${choices[*]} " =~ "7" ]]; then
        frameworks=("express" "django" "flask" "spring" "nestjs" "laravel" "phoenix")
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
                7) frameworks+=("phoenix") ;;
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
    if [[ " ${runtimes[*]} " =~ "node" || " ${runtimes[*]} " =~ "python" || " ${runtimes[*]} " =~ "php" ]]; then
        select_frameworks
    else
        echo -e "${CYBER_YELLOW}⚠ Frameworks disponíveis apenas para Node.js/Python/PHP${RESET}"
    fi

    # Finalização
    echo -e "\n${CYBER_PINK}⚡ BACKEND CONFIGURADO! ⚡${RESET}"
    echo -e "${CYBER_BLUE}Resumo:"
    echo -e "• Runtimes: ${runtimes[*]}"
    echo -e "• Frameworks: ${frameworks[*]}${RESET}"
    echo -e "\n${CYBER_YELLOW}Dica: Use ${CYBER_PINK}bytebabe db${RESET} ${CYBER_YELLOW}para bancos de dados${RESET}"
}

process_direct_install() {
    if [[ -z "$1" ]]; then
        echo -e "${CYBER_RED}✘ Especifique uma tecnologia para instalar${RESET}"
        echo -e "${CYBER_YELLOW}Exemplo: ${CYBER_PINK}bytebabe backend install node${RESET}"
        return 1
    fi

    for tech in "$@"; do
        case $tech in
            node|php|python|java|go|rust|elixir)
                install_runtime "$tech"
                ;;
            express|django|flask|spring|nestjs|laravel|phoenix)
                install_framework "$tech"
                ;;
            *)
                echo -e "${CYBER_RED}✘ Tecnologia não suportada: $tech${RESET}"
                echo -e "${CYBER_YELLOW}Use ${CYBER_PINK}bytebabe backend list${RESET} para ver as opções"
                return 1
                ;;
        esac
    done
}

list_supported_techs() {
    show_backend_header
    echo -e "${CYBER_BLUE}${CYBER_BOLD}  🛠️ TECNOLOGIAS SUPORTADAS:${RESET}"
    echo ""
    echo -e "${CYBER_YELLOW}${CYBER_BOLD}Runtimes:${RESET}"
    echo -e "  ${CYBER_PINK}node${RESET}    - Node.js"
    echo -e "  ${CYBER_PINK}php${RESET}     - PHP"
    echo -e "  ${CYBER_PINK}python${RESET}  - Python"
    echo -e "  ${CYBER_PINK}java${RESET}    - Java (via SDKMAN)"
    echo -e "  ${CYBER_PINK}go${RESET}      - Go"
    echo -e "  ${CYBER_PINK}rust${RESET}    - Rust"
    echo -e "  ${CYBER_PINK}elixir${RESET}  - Elixir"

    echo -e "\n${CYBER_YELLOW}${CYBER_BOLD}Frameworks:${RESET}"
    echo -e "  ${CYBER_PINK}express${RESET} - Express.js"
    echo -e "  ${CYBER_PINK}django${RESET}  - Django"
    echo -e "  ${CYBER_PINK}flask${RESET}   - Flask"
    echo -e "  ${CYBER_PINK}spring${RESET}  - Spring Boot"
    echo -e "  ${CYBER_PINK}nestjs${RESET}  - NestJS"
    echo -e "  ${CYBER_PINK}laravel${RESET} - Laravel"
    echo -e "  ${CYBER_PINK}phoenix${RESET} - Phoenix"
    cyber_divider
}

show_help() {
    show_backend_header
    echo -e "${CYBER_BLUE}USO: bytebabe backend [comando]"
    echo -e "\nCOMANDOS DISPONÍVEIS:"
    echo -e "  ${CYBER_PINK}setup${RESET}    - Configura ambiente backend"
    echo -e "  ${CYBER_PINK}install${RESET}  - Instala tecnologia específica"
    echo -e "  ${CYBER_PINK}list${RESET}     - Lista tecnologias suportadas"
    echo -e "  ${CYBER_PINK}help${RESET}     - Mostra esta ajuda"
    echo -e "\nEXEMPLOS:"
    echo -e "  ${CYBER_YELLOW}bytebabe backend setup"
    echo -e "  ${CYBER_YELLOW}bytebabe backend install php laravel"
    echo -e "  ${CYBER_YELLOW}bytebabe backend list${RESET}"
    cyber_divider
}

# ==========================================
# FUNÇÃO PRINCIPAL
# ==========================================

main() {
    case $1 in
        "setup")
            if [[ -z "$2" ]]; then
                # Modo interativo
                while true; do
                    show_backend_header
                    show_backend_menu
                    read -p $'\e[1;35m  ⌘ SELECIONE UMA OPÇÃO: \e[0m' choice

                    case $choice in
                        1)
                            process_setup
                            read -p $'\e[1;36m  Pressione ENTER para continuar...\e[0m'
                            ;;
                        2)
                            read -p $'\e[1;36m  Digite a(s) tecnologia(s) separadas por espaços: \e[0m' techs
                            process_direct_install $techs
                            read -p $'\e[1;36m  Pressione ENTER para continuar...\e[0m'
                            ;;
                        3)
                            list_supported_techs
                            read -p $'\e[1;36m  Pressione ENTER para continuar...\e[0m'
                            ;;
                        4)
                            show_help
                            read -p $'\e[1;36m  Pressione ENTER para continuar...\e[0m'
                            ;;
                        0)
                            break
                            ;;
                        *)
                            echo -e "${CYBER_RED}✘ Opção inválida!${RESET}"
                            sleep 1
                            ;;
                    esac
                done
            else
                # Modo direto
                process_direct_install "${@:2}"
            fi
            ;;
        "install")
            process_direct_install "${@:2}"
            ;;
        "list")
            list_supported_techs
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            show_help
            ;;
    esac
}

# ==========================================
# INICIALIZAÇÃO
# ==========================================

main "$@"