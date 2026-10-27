#!/bin/bash
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"

# ==========================================
# FUNÇÃO UNIVERSAL DE INSTALAÇÃO
# ==========================================
install_with_pkg_manager() {
    local pkg=$1
    local pkg_manager=$(detect_pkg_manager)
    
    case $pkg_manager in
        apt)
            sudo apt update && sudo apt install -y $pkg
            ;;
        dnf|yum)
            sudo $pkg_manager install -y $pkg
            ;;
        pacman)
            sudo pacman -S --noconfirm $pkg
            ;;
        brew)
            brew install $pkg
            ;;
        apk)
            sudo apk add $pkg
            ;;
        *)
            echo -e "${CYBER_RED}Gerenciador de pacotes não suportado: $pkg_manager${RESET}"
            return 1
            ;;
    esac
}

# ==========================================
# FUNÇÕES DE INSTALAÇÃO ESPECÍFICAS
# ==========================================
install_rust() {
    echo -e "${CYBER_BLUE}Verificando Rust...${RESET}"
    if ! command -v cargo &> /dev/null; then
        echo -e "${CYBER_YELLOW}⚡ Instalando Rust...${RESET}"
        case $(detect_pkg_manager) in
            apt) sudo apt install -y rustc cargo ;;
            dnf|yum) sudo dnf install -y rust cargo ;;
            pacman) sudo pacman -S rust ;;
            brew) brew install rust ;;
            *) 
                echo -e "${CYBER_YELLOW}⚡ Instalando Rust via rustup...${RESET}"
                curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                source ~/.cargo/env
                ;;
        esac
    else
        echo -e "${CYBER_GREEN}✔ Rust já está instalado${RESET}"
    fi
}

install_nodejs() {
    echo -e "${CYBER_BLUE}Instalando Node.js...${RESET}"
    case $(detect_pkg_manager) in
        apt) sudo apt install -y nodejs npm ;;
        dnf|yum) sudo dnf install -y nodejs ;;
        pacman) sudo pacman -S nodejs npm ;;
        brew) brew install node ;;
        *) echo -e "${CYBER_RED}Não foi possível instalar Node.js automaticamente${RESET}"
           return 1 ;;
    esac
}

install_websocat() {
    echo -e "${CYBER_YELLOW}⚡ Instalando websocat...${RESET}"
    
    # Primeiro tenta instalar via cargo se já estiver disponível
    if command -v cargo &> /dev/null; then
        if cargo install websocat; then
            echo -e "${CYBER_GREEN}✔ websocat instalado via cargo${RESET}"
            return 0
        fi
    fi
    
    # Se cargo não funcionou, tenta instalar Rust primeiro
    install_rust
    
    # Tenta várias formas de carregar o cargo
    if [[ -f "$HOME/.cargo/env" ]]; then
        source "$HOME/.cargo/env"
    fi
    
    # Adiciona cargo ao PATH
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Tenta novamente com cargo
    if command -v cargo &> /dev/null; then
        if cargo install websocat; then
            echo -e "${CYBER_GREEN}✔ websocat instalado com sucesso${RESET}"
            return 0
        fi
    fi
    
    # Se ainda falhou, tenta instalar via rustup
    if command -v rustup &> /dev/null; then
        if rustup run stable cargo install websocat; then
            echo -e "${CYBER_GREEN}✔ websocat instalado via rustup${RESET}"
            return 0
        fi
    fi
    
    echo -e "${CYBER_RED}✖ Falha ao instalar websocat${RESET}"
    echo -e "${CYBER_YELLOW}💡 Dica: Execute manualmente:${RESET}"
    echo -e "${CYBER_CYAN}   source ~/.cargo/env${RESET}"
    echo -e "${CYBER_CYAN}   cargo install websocat${RESET}"
    return 1
}

install_openapi_generator() {
    if ! command -v npm &> /dev/null; then
        install_nodejs || return 1
    fi

    echo -e "${CYBER_YELLOW}➜ Instalando OpenAPI Generator...${RESET}"
    if sudo npm install -g @openapitools/openapi-generator-cli; then
        echo -e "${CYBER_GREEN}✔ OpenAPI Generator instalado com sucesso${RESET}"
        echo -e "${CYBER_BLUE}Versão: $(openapi-generator-cli version)${RESET}"
        return 0
    else
        echo -e "${CYBER_RED}✖ Falha na instalação${RESET}"
        return 1
    fi
}

# ==========================================
# LISTAS DE FERRAMENTAS
# ==========================================
declare -A TOOLS=(
    # Ferramentas de Teste
    [curl]="install_with_pkg_manager curl"
    [httpie]="install_with_pkg_manager httpie"
    [jq]="install_with_pkg_manager jq"
    [yq]="install_with_pkg_manager yq"
    [grpcurl]="go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest"
    [websocat]="install_websocat"

    # Ferramentas de Documentação
    [swagger-cli]="sudo npm install -g swagger-cli"
    [openapi-generator-cli]="install_openapi_generator"
    [redoc-cli]="sudo npm install -g redoc-cli"
    [spectral]="sudo npm install -g @stoplight/spectral-cli"

    # Ferramentas de Proxy/Debug
    [mitmproxy]="sudo python3 -m pip install mitmproxy"
    [ngrok]="sudo snap install ngrok --classic"
    [wireshark]="install_with_pkg_manager wireshark"

    # Ferramentas GUI
    [postman]="sudo snap install postman --classic"
    [insomnia]="sudo snap install insomnia --classic"
    [bruno]="sudo npm install -g bruno"
)

# ==========================================
# FUNÇÕES DE INSTALAÇÃO
# ==========================================
install_tool() {
    local tool=$1
    echo -e "\n${CYBER_YELLOW}➜ Instalando $tool...${RESET}"

    if [[ -n "${TOOLS[$tool]}" ]]; then
        if eval "${TOOLS[$tool]}" 2>/dev/null; then
            echo -e "${CYBER_GREEN}✔ $tool instalado com sucesso${RESET}"
            return 0
        else
            echo -e "${CYBER_RED}✖ Falha ao instalar $tool${RESET}"
            return 1
        fi
    else
        echo -e "${CYBER_RED}✖ Ferramenta desconhecida: $tool${RESET}"
        return 1
    fi
}

install_multiple_tools() {
    local tools=($@)
    local failures=0

    for tool in "${tools[@]}"; do
        install_tool "$tool" || ((failures++))
    done

    return $failures
}

# ==========================================
# SISTEMA DE MENUS
# ==========================================
show_submenu() {
    local title="$1"
    local -a menu_options=("${!2}")
    local -a menu_commands=("${!3}")

    while true; do
        clear
        echo -e "\n${CYBER_PURPLE}$title${RESET}"
        echo -e "${CYBER_BLUE}Opções disponíveis:${RESET}"

        # Mostra opções numeradas
        for i in "${!menu_options[@]}"; do
            echo "$((i+1))) ${menu_options[$i]}"
        done
        echo "$(( ${#menu_options[@]} + 1 ))) Voltar"

        read -p $'\e[1;35m⌘ Selecione uma opção: \e[0m' choice

        # Verifica se quer voltar
        if [[ "$choice" == $((${#menu_options[@]} + 1)) ]]; then
            return 0
        fi

        # Valida escolha
        if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#menu_options[@]} )); then
            local selected="${menu_options[$choice-1]}"
            local cmd="${menu_commands[$choice-1]}"

            echo -e "\n${CYBER_YELLOW}➜ Executando: $selected${RESET}"
            eval "$cmd"
            read -p $'\e[1;36mPressione ENTER para continuar...\e[0m'
        else
            echo -e "${CYBER_RED}Opção inválida!${RESET}"
            sleep 1
        fi
    done
}

# ==========================================
# MENUS ESPECÍFICOS
# ==========================================
show_test_menu() {
    local -a options=(
        "curl"
        "httpie"
        "jq"
        "yq"
        "grpcurl"
        "websocat"
        "Todas de Teste"
    )

    local -a commands=(
        "install_multiple_tools curl"
        "install_multiple_tools httpie"
        "install_multiple_tools jq"
        "install_multiple_tools yq"
        "install_multiple_tools grpcurl"
        "install_multiple_tools websocat"
        "install_multiple_tools curl httpie jq yq grpcurl websocat"
    )

    show_submenu "🧪 Ferramentas de Teste de API" options[@] commands[@]
}

show_docs_menu() {
    local -a options=(
        "Swagger CLI"
        "OpenAPI Generator"
        "Redoc CLI"
        "Spectral"
        "Todas de Documentação"
    )

    local -a commands=(
        "install_multiple_tools swagger-cli"
        "install_openapi_generator"
        "install_multiple_tools redoc-cli"
        "install_multiple_tools spectral"
        "install_multiple_tools swagger-cli openapi-generator-cli redoc-cli spectral"
    )

    show_submenu "📚 Ferramentas de Documentação" options[@] commands[@]
}

show_proxy_menu() {
    local -a options=(
        "mitmproxy"
        "ngrok"
        "Wireshark"
        "Todas de Proxy"
    )

    local -a commands=(
        "install_multiple_tools mitmproxy"
        "install_multiple_tools ngrok"
        "install_multiple_tools wireshark"
        "install_multiple_tools mitmproxy ngrok wireshark"
    )

    show_submenu "🔍 Ferramentas de Proxy/Debug" options[@] commands[@]
}

show_gui_menu() {
    local -a options=(
        "Postman"
        "Insomnia"
        "Bruno"
        "Todas GUI"
    )

    local -a commands=(
        "install_multiple_tools postman"
        "install_multiple_tools insomnia"
        "install_multiple_tools bruno"
        "install_multiple_tools postman insomnia bruno"
    )

    show_submenu "🖥️  Ferramentas GUI" options[@] commands[@]
}

# ==========================================
# MENU PRINCIPAL
# ==========================================
show_main_menu() {
    PKG_MANAGER=$(detect_pkg_manager)

    while true; do
        clear
        echo -e "\n${CYBER_CYAN}📦 Gerenciador detectado: $PKG_MANAGER${RESET}"
        echo -e "${CYBER_BLUE}Menu Principal:${RESET}"

        PS3=$'\e[1;35m⌘ Selecione uma categoria: \e[0m'
        options=(
            "Ferramentas de Teste de API"
            "Ferramentas de Documentação"
            "Ferramentas de Proxy/Debug"
            "Ferramentas GUI"
            "Instalar TUDO"
            "Sair"
        )

        select opt in "${options[@]}"; do
            case $REPLY in
                1) show_test_menu; break ;;
                2) show_docs_menu; break ;;
                3) show_proxy_menu; break ;;
                4) show_gui_menu; break ;;
                5)
                    echo -e "\n${CYBER_YELLOW}⚠ Instalando TODAS as ferramentas...${RESET}"
                    install_multiple_tools "${!TOOLS[@]}"
                    read -p $'\e[1;36mPressione ENTER para continuar...\e[0m'
                    break
                    ;;
                6) return 0 ;;
                *) echo -e "${CYBER_RED}Opção inválida!${RESET}"; sleep 1; break ;;
            esac
        done
    done
}

# ==========================================
# EXECUÇÃO PRINCIPAL
# ==========================================
api_services_main() {
    echo -e "${CYBER_GREEN}⚡ Configurando DevTools para APIs${RESET}"

    if [[ $# -gt 0 ]]; then
        case $1 in
            --test)
                if [[ $# -eq 1 ]]; then
                    # Se apenas --test foi passado, instalar todas as ferramentas de teste
                    echo -e "${CYBER_YELLOW}⚡ Instalando todas as ferramentas de teste de API...${RESET}"
                    install_multiple_tools curl httpie jq yq grpcurl websocat
                else
                    # Se há argumentos adicionais, instalar apenas eles
                    install_multiple_tools "${@:2}"
                fi
                ;;
            --docs)
                if [[ "${2:-}" == "all" ]]; then
                    install_multiple_tools swagger-cli openapi-generator-cli redoc-cli spectral
                else
                    install_openapi_generator
                fi
                ;;
            --proxy) install_multiple_tools "${@:2}" ;;
            --gui) install_multiple_tools "${@:2}" ;;
            *)
                echo -e "${CYBER_RED}Opção desconhecida!${RESET}"
                return 1
                ;;
        esac
    else
        show_main_menu
    fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    api_services_main "$@"
fi
