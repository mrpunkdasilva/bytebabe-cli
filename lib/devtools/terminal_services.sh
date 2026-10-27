#!/bin/bash

# ==========================================
# TERMINAL SERVICES - ZSH & THEMES INSTALLER
# ==========================================

# Importar módulos
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"

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
# CONFIGURAÇÃO DE PLUGINS
# ==========================================

configure_zsh_plugins() {
    echo -e "${CYBER_BLUE}▶ Configurando plugins do Zsh...${RESET}"

    # Configuração do zsh-autosuggestions
    if [[ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]]; then
        echo -e "${CYBER_YELLOW}⚡ Instalando zsh-autosuggestions...${RESET}"
        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi

    # Configuração do zsh-syntax-highlighting
    if [[ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]]; then
        echo -e "${CYBER_YELLOW}⚡ Instalando zsh-syntax-highlighting...${RESET}"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    fi

    # Configuração do zsh-completions (autocomplete aprimorado)
    if [[ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions" ]]; then
        echo -e "${CYBER_YELLOW}⚡ Instalando zsh-completions...${RESET}"
        git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions
    fi

    # Configuração do colorize (syntax highlighting para arquivos)
    if [[ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/colorize" ]]; then
        echo -e "${CYBER_YELLOW}⚡ Instalando colorize...${RESET}"
        git clone https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/colorize ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/colorize
    fi

    # Atualizar arquivo .zshrc
    echo -e "${CYBER_YELLOW}⚡ Atualizando configuração do Zsh...${RESET}"

    # Configuração dos plugins
    local plugins=(
        git
        zsh-autosuggestions
        zsh-syntax-highlighting
        zsh-completions
        colorize
        colored-man-pages
    )

    # Converter array para string formatada
    local plugins_str="${plugins[@]}"
    plugins_str="${plugins_str// / }"

    # Atualizar o arquivo .zshrc
    sed -i.bak "s/^plugins=.*/plugins=($plugins_str)/" ~/.zshrc

    # Configurações adicionais para melhorar a experiência
    echo -e "\n# Configurações adicionais para plugins" >> ~/.zshrc
    echo 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#ff00ff,bg=cyan,bold,underline"' >> ~/.zshrc
    echo 'ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd history completion)' >> ~/.zshrc
    echo 'ZSH_AUTOSUGGEST_USE_ASYNC=true' >> ~/.zshrc
    echo 'ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor root line)' >> ~/.zshrc
    echo 'ZSH_HIGHLIGHT_STYLES[cursor]="bg=blue"' >> ~/.zshrc
    echo 'ZSH_COLORIZE_STYLE="solarized-dark"' >> ~/.zshrc
    echo 'autoload -U compinit && compinit' >> ~/.zshrc

    # Carregar completions do zsh-completions
    if [[ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions" ]]; then
        echo 'fpath+=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-completions/src' >> ~/.zshrc
    fi

    echo -e "${CYBER_GREEN}✔ Plugins configurados com sucesso!${RESET}"
}

# ==========================================
# INSTALAÇÃO DO ZSH
# ==========================================

install_zsh() {
    echo -e "${CYBER_BLUE}▶ Verificando Zsh...${RESET}"

    if ! command -v zsh &> /dev/null; then
        echo -e "${CYBER_YELLOW}⚡ Instalando Zsh...${RESET}"

        if ! install_with_fallback "zsh" "Zsh"; then
            echo -e "${CYBER_PINK}⚡ Tentando instalar Zsh from source...${RESET}"

            # Dependências para compilação
            sudo apt update
            sudo apt install -y build-essential libncurses-dev

            # Baixar e compilar Zsh
            ZSH_VERSION="5.9"
            wget -O zsh.tar.xz https://sourceforge.net/projects/zsh/files/zsh/${ZSH_VERSION}/zsh-${ZSH_VERSION}.tar.xz/download
            tar -xf zsh.tar.xz
            cd zsh-${ZSH_VERSION}
            ./configure --prefix=/usr/local
            make -j$(nproc)
            sudo make install
            cd ..
            rm -rf zsh-${ZSH_VERSION}*
        fi
    fi

    echo -e "${CYBER_GREEN}✔ Zsh $(zsh --version | cut -d' ' -f1-2) instalado${RESET}"

    # Definir Zsh como shell padrão
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        echo -e "${CYBER_YELLOW}⚡ Configurando Zsh como shell padrão...${RESET}"
        sudo chsh -s $(which zsh) $USER
        echo -e "${CYBER_GREEN}✔ Zsh configurado como shell padrão${RESET}"
    fi
}

# ==========================================
# INSTALAÇÃO DO OH MY ZSH
# ==========================================

install_ohmyzsh() {
    echo -e "${CYBER_BLUE}▶ Verificando Oh My Zsh...${RESET}"

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        echo -e "${CYBER_YELLOW}⚡ Instalando Oh My Zsh...${RESET}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

        if [[ $? -eq 0 ]]; then
            echo -e "${CYBER_GREEN}✔ Oh My Zsh instalado com sucesso${RESET}"

            # Configurações básicas
            echo -e "${CYBER_YELLOW}⚡ Aplicando configurações básicas...${RESET}"
            sed -i 's/ZSH_THEME=.*/ZSH_THEME="robbyrussell"/' ~/.zshrc
            echo -e "\n# Configurações adicionais" >> ~/.zshrc
            echo 'export UPDATE_ZSH_DAYS=7' >> ~/.zshrc

            # Configurar plugins
            configure_zsh_plugins

            echo -e "${CYBER_GREEN}✔ Configurações aplicadas${RESET}"
        else
            echo -e "${CYBER_RED}✘ Falha na instalação do Oh My Zsh${RESET}"
            return 1
        fi
    else
        echo -e "${CYBER_GREEN}✔ Oh My Zsh já está instalado${RESET}"
        configure_zsh_plugins
    fi
}

# ==========================================
# INSTALAÇÃO DO SPACESHIP PROMPT
# ==========================================

install_spaceship() {
    echo -e "${CYBER_BLUE}▶ Verificando Spaceship Prompt...${RESET}"

    if [[ ! -d "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" ]]; then
        echo -e "${CYBER_YELLOW}⚡ Instalando Spaceship Prompt...${RESET}"

        # Instalar o tema
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" --depth=1
        ln -s "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"

        # Configurar o tema
        sed -i 's/ZSH_THEME=.*/ZSH_THEME="spaceship"/' ~/.zshrc

        # Configurações adicionais do Spaceship
        echo -e "\n# Configurações do Spaceship" >> ~/.zshrc
        echo 'SPACESHIP_PROMPT_ADD_NEWLINE="true"' >> ~/.zshrc
        echo 'SPACESHIP_PROMPT_SEPARATE_LINE="true"' >> ~/.zshrc
        echo 'SPACESHIP_CHAR_SYMBOL="➜"' >> ~/.zshrc
        echo 'SPACESHIP_CHAR_SUFFIX=" "' >> ~/.zshrc
        echo 'SPACESHIP_PROMPT_ORDER=(' >> ~/.zshrc
        echo '  time user dir host git exec_time line_sep' >> ~/.zshrc
        echo '  vi_mode jobs exit_code char' >> ~/.zshrc
        echo ')' >> ~/.zshrc

        echo -e "${CYBER_GREEN}✔ Spaceship Prompt instalado e configurado${RESET}"
    else
        echo -e "${CYBER_GREEN}✔ Spaceship Prompt já está instalado${RESET}"
    fi
}

# ==========================================
# INSTALAÇÃO DO ATUIN (HISTÓRICO DE SHELL)
# ==========================================

atuin_shell_init() {
    local rc_file=$1
    case "$(basename "$rc_file")" in
        .zshrc) echo 'eval "$(atuin init zsh)"' ;;
        .bashrc|.bash_profile) echo 'eval "$(atuin init bash)"' ;;
        *) echo '' ;;
    esac
}

configure_atuin() {
    local updated=0
    local rc_file

    for rc_file in "$HOME/.zshrc" "$HOME/.bashrc"; do
        [[ -f "$rc_file" ]] || continue

        local init_line
        init_line=$(atuin_shell_init "$rc_file")
        [ -z "$init_line" ] && continue

        if ! grep -qE '\.atuin/bin/env|\.atuin/bin:\$PATH' "$rc_file"; then
            # Remove init antigo para garantir que o PATH seja definido antes
            local tmp_file
            tmp_file=$(mktemp)
            grep -v 'atuin init' "$rc_file" > "$tmp_file" || true
            mv "$tmp_file" "$rc_file"

            {
                echo ""
                echo "# Atuin - shell history"
                echo 'export PATH="$HOME/.atuin/bin:$PATH"'
                echo "$init_line"
            } >> "$rc_file"
            updated=1
        elif ! grep -q 'atuin init' "$rc_file"; then
            echo "$init_line" >> "$rc_file"
            updated=1
        fi
    done

    if [[ $updated -eq 1 ]]; then
        echo -e "${CYBER_GREEN}✔ Atuin configurado no shell${RESET}"
    fi
}

install_atuin() {
    echo -e "${CYBER_BLUE}▶ Verificando Atuin...${RESET}"

    if command -v atuin &> /dev/null; then
        echo -e "${CYBER_GREEN}✔ Atuin já está instalado ($(atuin --version 2>/dev/null | head -n1))${RESET}"
        configure_atuin
        return 0
    fi

    echo -e "${CYBER_YELLOW}⚡ Instalando Atuin...${RESET}"

    case $PKG_MANAGER in
        brew)
            brew install atuin || return 1
            ;;
        pacman)
            sudo pacman -S --needed --noconfirm atuin || return 1
            ;;
        *)
            if command -v curl &> /dev/null; then
                curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --non-interactive || return 1
            elif command -v wget &> /dev/null; then
                wget -qO- https://setup.atuin.sh | sh -s -- --non-interactive || return 1
            else
                echo -e "${CYBER_RED}✘ curl ou wget necessário para instalar Atuin${RESET}"
                return 1
            fi
            ;;
    esac

    export PATH="$HOME/.atuin/bin:$PATH"
    hash -r 2>/dev/null

    if command -v atuin &> /dev/null; then
        echo -e "${CYBER_GREEN}✔ Atuin $(atuin --version 2>/dev/null | head -n1) instalado${RESET}"
        configure_atuin
        echo -e "${CYBER_BLUE}Reinicie o terminal para ativar o atalho Ctrl+R do Atuin.${RESET}"
        return 0
    fi

    echo -e "${CYBER_RED}✘ Falha ao instalar Atuin${RESET}"
    return 1
}

# ==========================================
# MENUS INTERATIVOS
# ==========================================

show_terminal_header() {
    clear
    echo -e "${CYBER_BG_DARK}${CYBER_PINK}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║   ████████╗███████╗██████╗ ███╗   ███╗      ║"
    echo "║   ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║      ║"
    echo "║      ██║   █████╗  ██████╔╝██╔████╔██║      ║"
    echo "║      ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║      ║"
    echo "║      ██║   ███████╗██║  ██║██║ ╚═╝ ██║      ║"
    echo "║      ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝      ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
    cyber_divider
}

show_terminal_menu() {
    echo -e "${CYBER_BLUE}${CYBER_BOLD}  ⚡ MENU DE CONFIGURAÇÃO DO TERMINAL ⚡${RESET}"
    echo ""
    echo -e "${CYBER_PINK}1) Instalar Zsh e definir como padrão"
    echo -e "2) Instalar Oh My Zsh"
    echo -e "3) Instalar Spaceship Prompt"
    echo -e "4) Instalar Atuin (histórico de shell)"
    echo -e "5) Instalar Tudo (Zsh + Oh My Zsh + Spaceship + Atuin)"
    echo -e "6) Configurar Plugins (cores, autocomplete)"
    echo -e "7) Ajuda"
    echo -e "0) Voltar${RESET}"
    echo ""
    cyber_divider
}

# ==========================================
# PROCESSAMENTO DE COMANDOS
# ==========================================

process_installation() {
    case $1 in
        "zsh"|"z")
            install_zsh
            ;;
        "ohmyzsh"|"omz"|"oh-my-zsh")
            if ! command -v zsh &> /dev/null; then
                echo -e "${CYBER_RED}✘ Zsh não está instalado. Instale primeiro.${RESET}"
                return 1
            fi
            install_ohmyzsh
            ;;
        "spaceship"|"sp"|"space")
            if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
                echo -e "${CYBER_RED}✘ Oh My Zsh não está instalado. Instale primeiro.${RESET}"
                return 1
            fi
            install_spaceship
            ;;
        "atuin"|"altuin"|"at")
            install_atuin
            ;;
        "plugins"|"p")
            if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
                echo -e "${CYBER_RED}✘ Oh My Zsh não está instalado. Instale primeiro.${RESET}"
                return 1
            fi
            configure_zsh_plugins
            ;;
        "all"|"a")
            install_zsh
            install_ohmyzsh
            install_spaceship
            install_atuin
            configure_zsh_plugins
            echo -e "${CYBER_PINK}⚡ TERMINAL CONFIGURADO! ⚡${RESET}"
            echo -e "${CYBER_BLUE}Reinicie seu terminal para aplicar as mudanças.${RESET}"
            ;;
        *)
            echo -e "${CYBER_RED}✘ Opção inválida!${RESET}"
            return 1
            ;;
    esac
}

show_help() {
    show_terminal_header
    echo -e "${CYBER_BLUE}USO: bytebabe terminal [comando]"
    echo -e "\nCOMANDOS DISPONÍVEIS:"
    echo -e "  ${CYBER_PINK}zsh, z${RESET}            - Instala e configura o Zsh"
    echo -e "  ${CYBER_PINK}ohmyzsh, omz${RESET}      - Instala o Oh My Zsh"
    echo -e "  ${CYBER_PINK}spaceship, sp${RESET}     - Instala o Spaceship Prompt"
    echo -e "  ${CYBER_PINK}atuin, at${RESET}         - Instala o Atuin (histórico de shell)"
    echo -e "  ${CYBER_PINK}plugins, p${RESET}        - Configura plugins (cores, autocomplete)"
    echo -e "  ${CYBER_PINK}all, a${RESET}            - Instala tudo (Zsh + Oh My Zsh + Spaceship + Atuin + Plugins)"
    echo -e "  ${CYBER_PINK}help, h${RESET}           - Mostra esta ajuda"
    echo -e "\nEXEMPLOS:"
    echo -e "  ${CYBER_YELLOW}bytebabe terminal zsh${RESET} ou ${CYBER_YELLOW}bytebabe devtools t z"
    echo -e "  ${CYBER_YELLOW}bytebabe terminal atuin${RESET} ou ${CYBER_YELLOW}bytebabe devtools t at"
    echo -e "  ${CYBER_YELLOW}bytebabe terminal all"
    echo -e "  ${CYBER_YELLOW}bytebabe terminal plugins"
    echo -e "  ${CYBER_YELLOW}bytebabe terminal help${RESET}"
    cyber_divider
}

# ==========================================
# FUNÇÃO PRINCIPAL
# ==========================================

terminal_services_main() {
    PKG_MANAGER=$(detect_pkg_manager)

    case ${1:-} in
        "zsh"|"z"|"ohmyzsh"|"omz"|"oh-my-zsh"|"spaceship"|"sp"|"space"|"atuin"|"altuin"|"at"|"plugins"|"p"|"all"|"a")
            process_installation "$1"
            ;;
        "help"|"--help"|"-h"|"h")
            show_help
            ;;
        *)
            # Modo interativo
            while true; do
                show_terminal_header
                show_terminal_menu
                read -p $'\e[1;35m  ⌘ SELECIONE UMA OPÇÃO: \e[0m' choice

                case $choice in
                    1) process_installation "zsh" ;;
                    2) process_installation "ohmyzsh" ;;
                    3) process_installation "spaceship" ;;
                    4) process_installation "atuin" ;;
                    5) process_installation "all" ;;
                    6) process_installation "plugins" ;;
                    7) show_help ;;
                    0) break ;;
                    *)
                        echo -e "${CYBER_RED}✘ Opção inválida!${RESET}"
                        sleep 1
                        ;;
                esac
                [[ "$choice" != "7" && "$choice" != "0" ]] && read -p $'\e[1;36m  Pressione ENTER para continuar...\e[0m'
            done
            ;;
    esac
}

# ==========================================
# INICIALIZAÇÃO
# ==========================================

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    terminal_services_main "$@"
fi
