#!/bin/bash

# Função de ajuda do módulo remove
show_remove_help() {
    show_header_custom "LEGACY MODULE PURGE" "☠️" "${CYBER_RED}"
    
    echo -e "${CYBER_BLUE}USAGE:${NC}"
    echo -e "  prime remove ${CYBER_YELLOW}[options] <package>${NC}"
    echo -e "  prime rm ${CYBER_YELLOW}[options] <package>${NC}"
    echo
    
    echo -e "${CYBER_BLUE}OPTIONS:${NC}"
    echo -e "  ${CYBER_GREEN}-c, --complete${NC}    Remove package and its dependencies"
    echo -e "  ${CYBER_GREEN}-p, --purge${NC}       Remove package, deps and configurations"
    echo -e "  ${CYBER_GREEN}-h, --help${NC}        Show this help message"
    echo
    
    echo -e "${CYBER_BLUE}EXAMPLES:${NC}"
    echo -e "  ${CYBER_YELLOW}prime remove nginx${NC}           # Simple remove"
    echo -e "  ${CYBER_YELLOW}prime rm -c mongodb${NC}         # Complete remove"
    echo -e "  ${CYBER_YELLOW}prime remove --purge mysql${NC}  # Purge remove"
    echo -e "  ${CYBER_YELLOW}prime rm${NC}                   # Interactive mode"
    echo
    
    echo -e "${CYBER_BLUE}REMOVAL MODES:${NC}"
    echo -e "  ${CYBER_GREEN}Simple${NC}    - Only removes the package"
    echo -e "  ${CYBER_YELLOW}Complete${NC}  - Removes package and dependencies"
    echo -e "  ${CYBER_RED}Purge${NC}     - Removes package, deps and configs"
    echo
    
    echo -e "${CYBER_BLUE}SAFETY FEATURES:${NC}"
    echo -e "  ${CYBER_GREEN}• Automatic backup before removal"
    echo -e "  ${CYBER_GREEN}• Dependency checking"
    echo -e "  ${CYBER_GREEN}• Critical package protection"
    echo -e "  ${CYBER_GREEN}• Detailed logs${NC}"
    
    cyber_divider
}

# Função para remover pacote de forma simples
simple_remove() {
    local package="$1"
    echo -e "\n${CYBER_YELLOW}🔍 SCANNING PACKAGE: ${package}${NC}"
    
    if command -v apt-get &>/dev/null; then
        sudo apt-get remove -y "$package"
    elif command -v dnf &>/dev/null; then
        sudo dnf remove -y "$package"
    elif command -v pacman &>/dev/null; then
        sudo pacman -R "$package"
    else
        echo -e "${CYBER_RED}⚠ No compatible package manager found${NC}"
        return 1
    fi
}

# Função para remover pacote com todas as dependências
complete_remove() {
    local package="$1"
    echo -e "\n${CYBER_YELLOW}🔍 DEEP SCANNING PACKAGE: ${package}${NC}"
    
    if command -v apt-get &>/dev/null; then
        sudo apt-get autoremove -y "$package"
    elif command -v dnf &>/dev/null; then
        sudo dnf autoremove -y "$package"
    elif command -v pacman &>/dev/null; then
        sudo pacman -Rs "$package"
    else
        echo -e "${CYBER_RED}⚠ No compatible package manager found${NC}"
        return 1
    fi
}

# Função para remover pacote com configurações (purge)
purge_remove() {
    local package="$1"
    echo -e "\n${CYBER_RED}☢️ INITIATING PURGE: ${package}${NC}"
    
    if command -v apt-get &>/dev/null; then
        sudo apt-get purge -y "$package"
        sudo apt-get autoremove -y
    elif command -v dnf &>/dev/null; then
        sudo dnf remove -y "$package"
        sudo dnf clean all
    elif command -v pacman &>/dev/null; then
        sudo pacman -Rns "$package"
    else
        echo -e "${CYBER_RED}⚠ No compatible package manager found${NC}"
        return 1
    fi
}

# Função para criar backup antes da remoção
create_backup() {
    local package="$1"
    local backup_dir="/var/backups/prime/packages"
    local date_stamp=$(date +%Y%m%d_%H%M%S)
    
    echo -e "\n${CYBER_BLUE}💾 Creating safety backup...${NC}"
    
    # Cria diretório de backup se não existir
    sudo mkdir -p "$backup_dir"
    
    # Lista arquivos do pacote e cria backup
    if command -v apt-get &>/dev/null; then
        dpkg -L "$package" 2>/dev/null | while read -r file; do
            if [ -f "$file" ]; then
                sudo cp --parents "$file" "$backup_dir/${package}_${date_stamp}/"
            fi
        done
    elif command -v dnf &>/dev/null; then
        rpm -ql "$package" 2>/dev/null | while read -r file; do
            if [ -f "$file" ]; then
                sudo cp --parents "$file" "$backup_dir/${package}_${date_stamp}/"
            fi
        done
    fi
    
    echo -e "${CYBER_GREEN}✓ Backup created: ${backup_dir}/${package}_${date_stamp}${NC}"
}

# Menu interativo de remoção
interactive_menu() {
    show_header_custom "PACKAGE REMOVAL INTERFACE" "⚡" "${CYBER_BLUE}"
    
    echo -e "\n${CYBER_YELLOW}Available Packages:${NC}"
    if command -v apt-get &>/dev/null; then
        dpkg -l | grep '^ii' | awk '{print $2}'
    elif command -v dnf &>/dev/null; then
        dnf list installed
    elif command -v pacman &>/dev/null; then
        pacman -Q
    fi
    
    echo -e "\n${CYBER_BLUE}Select removal mode:${NC}"
    echo -e "${CYBER_GREEN}1) Simple Remove${NC}"
    echo -e "${CYBER_YELLOW}2) Complete Remove${NC}"
    echo -e "${CYBER_RED}3) Purge Remove${NC}"
    echo -e "${CYBER_PURPLE}4) Exit${NC}"
    
    read -p "$(echo -e ${CYBER_BLUE}"\nEnter choice [1-4]: "${NC})" choice
    
    if [ "$choice" != "4" ]; then
        read -p "$(echo -e ${CYBER_YELLOW}"\nEnter package name: "${NC})" package
        
        # Criar backup antes da remoção
        create_backup "$package"
        
        case $choice in
            1) simple_remove "$package" ;;
            2) complete_remove "$package" ;;
            3) purge_remove "$package" ;;
            *) echo -e "${CYBER_RED}Invalid option!${NC}" ;;
        esac
    fi
}

# Função principal de remoção
run_remove() {
    if [ $# -eq 0 ]; then
        interactive_menu
    else
        local mode="simple"
        local package=""
        
        # Processar argumentos
        while [[ $# -gt 0 ]]; do
            case "$1" in
                --help|-h)
                    show_remove_help
                    return 0
                    ;;
                --purge|-p)
                    mode="purge"
                    shift
                    ;;
                --complete|-c)
                    mode="complete"
                    shift
                    ;;
                *)
                    package="$1"
                    shift
                    ;;
            esac
        done
        
        # Verificar se o pacote foi especificado
        if [ -z "$package" ]; then
            echo -e "${CYBER_RED}⚠ No package specified!${NC}"
            show_remove_help
            return 1
        fi
        
        # Criar backup antes da remoção
        create_backup "$package"
        
        # Executar remoção no modo apropriado
        case "$mode" in
            purge)
                purge_remove "$package"
                ;;
            complete)
                complete_remove "$package"
                ;;
            simple)
                simple_remove "$package"
                ;;
        esac
    fi
}