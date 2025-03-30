#!/bin/bash

# ==========================================
# IDE SERVICES - CYBERPUNK EDITION
# ==========================================


# ==========================================
# CONFIGURAÇÕES
# ==========================================
TOOLBOX_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.4.38621.tar.gz"
FLATHUB_IDES=(
    "com.visualstudio.code"
    "dev.zed.Zed"
    "com.sublimetext.three"
    "com.jetbrains.IntelliJ-IDEA-Community"
    "com.jetbrains.PyCharm-Community"
    "com.jetbrains.CLion"
)

# ==========================================
# EFEITOS VISUAIS
# ==========================================

cyber_install_animation() {
    local text=$1
    echo -ne "${CYBER_BLUE}${CYBER_BOLD}▶ ${text}${CYBER_YELLOW}"
    for i in {1..3}; do
        echo -ne " ⚡ "
        sleep 0.2
    done
    echo -e "${RESET}"
}

show_cyber_progress() {
    local width=40
    local percent=$1
    local filled=$((width * percent / 100))
    local empty=$((width - filled))

    echo -ne "${CYBER_BG_DARK}${CYBER_PINK}["
    for i in $(seq 1 $filled); do
        echo -ne "█"
    done
    for i in $(seq 1 $empty); do
        echo -ne " "
    done
    echo -ne "] ${percent}%${RESET}\r"
}

# ==========================================
# SERVIÇOS DE INSTALAÇÃO
# ==========================================

ensure_flatpak() {
    if ! command -v flatpak &>/dev/null; then
        cyber_install_animation "INICIANDO SISTEMA FLATPAK"
        echo -e "${CYBER_ICON_INFO} ${CYBER_BLUE}ATUALIZANDO REPOSITÓRIOS${RESET}"

        # Barra de progresso simulada
        for i in {1..10}; do
            show_cyber_progress $((i * 10))
            sleep 0.1
        done
        echo

        sudo apt update > /dev/null 2>&1 && \
        sudo apt install -y flatpak > /dev/null 2>&1 && \
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo > /dev/null 2>&1

        echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}SISTEMA FLATPAK INSTALADO${RESET}"
        cyber_divider
    fi
}

install_vscode() {
    cyber_install_animation "INICIANDO INSTALAÇÃO VS CODE"
    flatpak install -y flathub com.visualstudio.code > /dev/null 2>&1

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}VS CODE INSTALADO COM SUCESSO"
    echo -e "${CYBER_ICON_TERMINAL} ${CYBER_YELLOW}COMANDO: ${CYBER_PINK}flatpak run com.visualstudio.code${RESET}"
    echo -e "${CYBER_BLUE}${CYBER_BOLD}EXTENSÕES RECOMENDADAS:"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Night Owl Theme"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Cyberpunk 2077 Theme"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Glow Neon Icons${RESET}"
    cyber_divider
}

install_zed() {
    cyber_install_animation "INICIANDO INSTALAÇÃO ZED EDITOR"
    flatpak install -y flathub dev.zed.Zed > /dev/null 2>&1

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}ZED EDITOR INSTALADO"
    echo -e "${CYBER_ICON_TERMINAL} ${CYBER_YELLOW}COMANDO: ${CYBER_PINK}flatpak run dev.zed.Zed${RESET}"
    echo -e "${CYBER_BLUE}${CYBER_BOLD}RECURSOS:"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Editor de performance extrema"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Colaboração em tempo real"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}UI minimalista${RESET}"
    cyber_divider
}

install_sublime() {
    cyber_install_animation "INICIANDO INSTALAÇÃO SUBLIME TEXT"
    flatpak install -y flathub com.sublimetext.three > /dev/null 2>&1

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}SUBLIME TEXT INSTALADO"
    echo -e "${CYBER_ICON_TERMINAL} ${CYBER_YELLOW}COMANDO: ${CYBER_PINK}flatpak run com.sublimetext.three${RESET}"
    echo -e "${CYBER_BLUE}${CYBER_BOLD}DICAS:"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Ctrl+P para busca rápida"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Multi-seleção com Ctrl+D"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Personalização total${RESET}"
    cyber_divider
}

install_toolbox() {
    cyber_install_animation "INICIANDO INSTALAÇÃO JETBRAINS TOOLBOX"
    echo -e "${CYBER_GLITCH}>>> CONECTANDO A REDE JETBRAINS...${RESET}"

    local temp_dir=$(mktemp -d)
    wget --show-progress -q -O "$temp_dir/toolbox.tar.gz" "$TOOLBOX_URL"

    echo -e "${CYBER_GLITCH}>>> DECODIFICANDO PACOTE...${RESET}"
    tar -xzf "$temp_dir/toolbox.tar.gz" -C "$temp_dir" --strip-components=1

    echo -e "${CYBER_GLITCH}>>> INTEGRANDO COM SISTEMA...${RESET}"
    sudo mv "$temp_dir" /opt/jetbrains-toolbox > /dev/null 2>&1
    sudo ln -sf /opt/jetbrains-toolbox/jetbrains-toolbox /usr/local/bin/jetbrains-toolbox

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}JETBRAINS TOOLBOX INSTALADO"
    echo -e "${CYBER_ICON_TERMINAL} ${CYBER_YELLOW}COMANDO: ${CYBER_PINK}jetbrains-toolbox${RESET}"
    echo -e "${CYBER_BLUE}${CYBER_BOLD}IDES DISPONÍVEIS:"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}IntelliJ IDEA"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}PyCharm"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}CLion"
    echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}WebStorm${RESET}"
    cyber_divider

    rm -rf "$temp_dir"
}

install_jetbrains_ide() {
    local ide_name=$1
    local flatpak_id="com.jetbrains.${ide_name}-Community"

    cyber_install_animation "INICIANDO INSTALAÇÃO ${ide_name//-/ }"
    flatpak install -y flathub "$flatpak_id" > /dev/null 2>&1

    echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}${ide_name//-/ } INSTALADO"
    echo -e "${CYBER_ICON_TERMINAL} ${CYBER_YELLOW}COMANDO: ${CYBER_PINK}flatpak run ${flatpak_id}${RESET}"

    case $ide_name in
        IntelliJ-IDEA)
            echo -e "${CYBER_BLUE}${CYBER_BOLD}RECURSOS:"
            echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Java/Kotlin/Scala"
            echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Ferramentas de refatoração"
            echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Integração com Maven/Gradle${RESET}"
            ;;
        PyCharm)
            echo -e "${CYBER_BLUE}${CYBER_BOLD}RECURSOS:"
            echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Debugger visual"
            echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Suporte a Django"
            echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Integração com Jupyter${RESET}"
            ;;
        CLion)
            echo -e "${CYBER_BLUE}${CYBER_BOLD}RECURSOS:"
            echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Debugger integrado"
            echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Análise de código em tempo real"
            echo -e "  ${CYBER_PURPLE}• ${CYBER_CYAN}Suporte a CMake${RESET}"
            ;;
    esac
    cyber_divider
}

install_all_ides() {
    ensure_flatpak

    # Lista de IDs para instalação
    local ides=(
        "vscode"
        "zed"
        "sublime"
        "toolbox"
        "intellij"
        "pycharm"
        "clion"
    )

    echo -e "${CYBER_RED}${CYBER_BOLD}⚠ INICIANDO INSTALAÇÃO COMPLETA DE IDES ⚠${RESET}"
    echo -e "${CYBER_YELLOW}Este processo instalará todas as IDEs disponíveis${RESET}"
    cyber_divider

    for ide in "${ides[@]}"; do
        case $ide in
            vscode) install_vscode ;;
            zed) install_zed ;;
            sublime) install_sublime ;;
            toolbox) install_toolbox ;;
            intellij) install_jetbrains_ide "IntelliJ-IDEA" ;;
            pycharm) install_jetbrains_ide "PyCharm" ;;
            clion) install_jetbrains_ide "CLion" ;;
        esac
    done

    echo -e "${CYBER_GREEN}${CYBER_BOLD}⭐ TODAS AS IDES FORAM INSTALADAS COM SUCESSO ⭐${RESET}"
    cyber_divider
}



# ==========================================
# SERVIÇOS DE EXECUÇÃO
# ==========================================

list_installed_ides() {
    echo -e "${CYBER_BLUE}${CYBER_BOLD}  🔍 IDES INSTALADAS NO SISTEMA:${RESET}"
    echo ""

    local ides=(
        "com.visualstudio.code"
        "dev.zed.Zed"
        "com.sublimetext.three"
        "com.jetbrains.IntelliJ-IDEA-Community"
        "com.jetbrains.PyCharm-Community"
        "com.jetbrains.CLion"
    )

    local found=0
    for ide in "${ides[@]}"; do
        if flatpak list | grep -q "$ide"; then
            local display_name
            case "$ide" in
                "com.visualstudio.code") display_name="VS Code" ;;
                "dev.zed.Zed") display_name="Zed Editor" ;;
                "com.sublimetext.three") display_name="Sublime Text" ;;
                *) display_name=$(echo "$ide" | cut -d. -f3-) ;;
            esac
            echo -e "  ${CYBER_PURPLE}• ${CYBER_GREEN}$display_name ${CYBER_YELLOW}($ide)${RESET}"
            ((found++))
        fi
    done

    if [[ $found -eq 0 ]]; then
        echo -e "  ${CYBER_RED}Nenhuma IDE instalada via Flatpak${RESET}"
    fi

    cyber_divider
}

run_ide() {
    local ide=$1
    local ide_id

    case "$ide" in
        code|vscode) ide_id="com.visualstudio.code" ;;
        zed) ide_id="dev.zed.Zed" ;;
        sublime) ide_id="com.sublimetext.three" ;;
        intellij) ide_id="com.jetbrains.IntelliJ-IDEA-Community" ;;
        pycharm) ide_id="com.jetbrains.PyCharm-Community" ;;
        clion) ide_id="com.jetbrains.CLion" ;;
        *)
            echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}IDE desconhecida: $ide${RESET}"
            return 1
            ;;
    esac

    if flatpak list | grep -q "$ide_id"; then
        echo -e "${CYBER_ICON_INFO} ${CYBER_BLUE}Iniciando ${ide}...${RESET}"
        flatpak run "$ide_id" > /dev/null 2>&1 &
        echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}IDE iniciada em background${RESET}"
    else
        echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}IDE não instalada: $ide${RESET}"
        echo -e "${CYBER_YELLOW}Instale primeiro com: bytebabe ide install ${ide}${RESET}"
        return 1
    fi
}

# ==========================================
# SERVIÇOS DE GERENCIAMENTO
# ==========================================

ide_status() {
    local ide=$1
    local ide_id

    case "$ide" in
        code|vscode) ide_id="com.visualstudio.code" ;;
        zed) ide_id="dev.zed.Zed" ;;
        sublime) ide_id="com.sublimetext.three" ;;
        intellij) ide_id="com.jetbrains.IntelliJ-IDEA-Community" ;;
        pycharm) ide_id="com.jetbrains.PyCharm-Community" ;;
        clion) ide_id="com.jetbrains.CLion" ;;
        *)
            echo -e "${CYBER_ICON_ERROR} ${CYBER_RED}IDE desconhecida: $ide${RESET}"
            return 1
            ;;
    esac

    if pgrep -f "flatpak run $ide_id" > /dev/null; then
        echo -e "${CYBER_ICON_SUCCESS} ${CYBER_GREEN}${ide} está em execução${RESET}"
        return 0
    else
        echo -e "${CYBER_ICON_INFO} ${CYBER_YELLOW}${ide} não está em execução${RESET}"
        return 1
    fi
}




# ==========================================
# VERIFICAÇÃO DE SISTEMA
# ==========================================

verify_system() {
    if ! command -v wget &>/dev/null; then
        echo -e "${CYBER_ICON_WARNING} ${CYBER_YELLOW}INSTALANDO WGET...${RESET}"
        sudo apt install -y wget
    fi

    if ! command -v tar &>/dev/null; then
        echo -e "${CYBER_ICON_WARNING} ${CYBER_YELLOW}INSTALANDO TAR...${RESET}"
        sudo apt install -y tar
    fi
}

# Verificar dependências ao carregar
verify_system