#!/bin/bash
source "$(pwd)/../lib/core/colors.sh"
source "$(pwd)/../lib/core/helpers.sh"

echo -e "${CYBER_GREEN}⚡ Configurando DevTools para APIs${RESET}"

# ==========================================
# FUNÇÃO PARA DETECTAR O GERENCIADOR DE PACOTES
# ==========================================
detect_pkg_manager() {
    if command -v apt-get &> /dev/null; then
        echo "apt"
    elif command -v dnf &> /dev/null; then
        echo "dnf"
    elif command -v yum &> /dev/null; then
        echo "yum"
    elif command -v pacman &> /dev/null; then
        echo "pacman"
    elif command -v brew &> /dev/null; then
        echo "brew"
    elif command -v apk &> /dev/null; then
        echo "apk"
    else
        echo "unknown"
    fi
}

# ==========================================
# LISTAS DE FERRAMENTAS (ORGANIZADAS POR CATEGORIA)
# ==========================================
declare -A TOOLS=(
    # Ferramentas de Teste
    [curl]="sudo apt install curl"
    [httpie]="sudo apt install httpie"
    [jq]="sudo apt install jq"
    [yq]="sudo apt install yq"
    [grpcurl]="go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest"
    [websocat]="cargo install websocat"

    # Ferramentas de Documentação
    [swagger-cli]="npm install -g swagger-cli"
    [openapi-generator-cli]="npm install -g @openapitools/openapi-generator-cli"

    # Ferramentas de Proxy/Debug
    [mitmproxy]="python3 -m pip install mitmproxy"
    [ngrok]="snap install ngrok"
    [wireshark]="sudo apt install wireshark"

    # Ferramentas GUI
    [postman]="snap install postman"
    [insomnia]="snap install insomnia"
    [bruno]="npm install -g bruno"
)

# ==========================================
# FUNÇÕES DE INSTALAÇÃO
# ==========================================
install_tool() {
    local tool=$1
    echo -e "\n${CYBER_YELLOW}➜ Instalando $tool...${RESET}"

    if [[ -n "${TOOLS[$tool]}" ]]; then
        eval "${TOOLS[$tool]}" 2>/dev/null && \
        echo -e "${CYBER_GREEN}✔ $tool instalado com sucesso${RESET}" || \
        echo -e "${CYBER_RED}✖ Falha ao instalar $tool${RESET}"
    else
        echo -e "${CYBER_RED}✖ Ferramenta desconhecida: $tool${RESET}"
    fi
}

install_multiple_tools() {
    local tools=(${1//,/ })
    for tool in "${tools[@]}"; do
        install_tool "$tool"
    done
}

# ==========================================
# SUBMENUS ESPECÍFICOS
# ==========================================
show_gui_menu() {
    echo -e "\n${CYBER_PURPLE}🖥️  Selecione as ferramentas GUI:${RESET}"
    PS3=$'\e[1;35m⌘ Selecione (separar por vírgula): \e[0m'
    options=(
        "Postman"
        "Insomnia"
        "Bruno"
        "Todas as GUI"
        "Voltar"
    )

    select opt in "${options[@]}"; do
        case $REPLY in
            1) install_multiple_tools "postman"; break ;;
            2) install_multiple_tools "insomnia"; break ;;
            3) install_multiple_tools "bruno"; break ;;
            4) install_multiple_tools "postman,insomnia,bruno"; break ;;
            5) return ;;
            *) echo -e "${CYBER_RED}Opção inválida!${RESET}"; break ;;
        esac
    done
}

show_test_menu() {
    echo -e "\n${CYBER_PURPLE}🧪 Selecione as ferramentas de Teste:${RESET}"
    PS3=$'\e[1;35m⌘ Selecione (separar por vírgula): \e[0m'
    options=(
        "curl"
        "httpie"
        "jq + yq"
        "grpcurl"
        "websocat"
        "Todas de Teste"
        "Voltar"
    )

    select opt in "${options[@]}"; do
        case $REPLY in
            1) install_multiple_tools "curl"; break ;;
            2) install_multiple_tools "httpie"; break ;;
            3) install_multiple_tools "jq,yq"; break ;;
            4) install_multiple_tools "grpcurl"; break ;;
            5) install_multiple_tools "websocat"; break ;;
            6) install_multiple_tools "curl,httpie,jq,yq,grpcurl,websocat"; break ;;
            7) return ;;
            *) echo -e "${CYBER_RED}Opção inválida!${RESET}"; break ;;
        esac
    done
}

# (Adicione menus similares para docs, proxy, etc...)

# ==========================================
# MENU PRINCIPAL
# ==========================================
show_main_menu() {
    PKG_MANAGER=$(detect_pkg_manager)

    while true; do
        echo -e "\n${CYBER_CYAN}📦 Gerenciador detectado: $PKG_MANAGER${RESET}"
        echo -e "${CYBER_BLUE}Menu Principal:${RESET}"

        PS3=$'\e[1;35m⌘ Selecione a categoria: \e[0m'
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
                5) install_multiple_tools "${!TOOLS[@]}"; break ;;
                6) exit 0 ;;
                *) echo -e "${CYBER_RED}Opção inválida!${RESET}"; break ;;
            esac
        done
    done
}

# ==========================================
# EXECUÇÃO PRINCIPAL
# ==========================================
if [[ $# -gt 0 ]]; then
    # Modo não interativo (via parâmetros)
    case $1 in
        --gui) install_multiple_tools "${2:-postman,insomnia,bruno}" ;;
        --test) install_multiple_tools "${2:-curl,httpie,jq,yq}" ;;
        # Adicione outros casos conforme necessário...
        *) echo -e "${CYBER_RED}Opção desconhecida!${RESET}"; exit 1 ;;
    esac
else
    # Modo interativo
    show_main_menu
fi