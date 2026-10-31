#!/bin/bash

# Cores Cyberpunk
CYBER_RED='\033[38;5;196m'
CYBER_GREEN='\033[38;5;118m'
CYBER_BLUE='\033[38;5;45m'
CYBER_YELLOW='\033[38;5;227m'
CYBER_PURPLE='\033[38;5;93m'
NC='\033[0m'

# Efeitos
FLASH="\033[5m"
BOLD="\033[1m"
RESET="\033[0m"

# ASCII Art Header
show_header() {
  clear
  echo -e "${CYBER_RED}"
  echo -e " █▀▀ █░░ █▀▀ █▄░█ █▀▄ ▄▀█ █▀▀ █▀▀"
  echo -e " █▄▄ █▄▄ ██▄ █░▀█ █▄▀ █▀█ █▄█ ██▄"
  echo -e "${CYBER_BLUE}"
  echo -e "╔════════════════════════════════════════╗"
  echo -e "║   ${CYBER_RED}⚡ ${CYBER_YELLOW}SYSTEM PURGE v2.0 ${CYBER_BLUE}⚡   ║"
  echo -e "╚════════════════════════════════════════╝${NC}"
  echo
}

# Limpeza básica do sistema
basic_clean() {
  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_BLUE}⌛ INITIATING SYSTEM PURGE SEQUENCE...${NC}"

  # Limpeza de cache
  echo -e "\n${CYBER_YELLOW}🧹 CLEARING CACHE...${NC}"
  sudo rm -rf /var/cache/* 2>/dev/null
  echo -e "${CYBER_GREEN}✔ System cache cleared${NC}"

  # Limpeza de logs antigos
  echo -e "\n${CYBER_YELLOW}📝 ROTATING LOGS...${NC}"
  sudo journalctl --vacuum-time=7d 2>/dev/null
  echo -e "${CYBER_GREEN}✔ Logs rotated${NC}"

  # Limpeza de pacotes órfãos
  echo -e "\n${CYBER_YELLOW}📦 CLEANING ORPHANED PACKAGES...${NC}"
  if command -v apt-get &>/dev/null; then
    sudo apt-get autoremove -y 2>/dev/null
    echo -e "${CYBER_GREEN}✔ Orphaned packages removed (APT)${NC}"
  elif command -v dnf &>/dev/null; then
    sudo dnf autoremove -y 2>/dev/null
    echo -e "${CYBER_GREEN}✔ Orphaned packages removed (DNF)${NC}"
  elif command -v yum &>/dev/null; then
    sudo yum autoremove -y 2>/dev/null
    echo -e "${CYBER_GREEN}✔ Orphaned packages removed (YUM)${NC}"
  fi

  # Limpeza de thumbnails
  echo -e "\n${CYBER_YELLOW}🖼️ CLEARING THUMBNAILS...${NC}"
  rm -rf ~/.cache/thumbnails/* 2>/dev/null
  echo -e "${CYBER_GREEN}✔ Thumbnails cleared${NC}"

  echo -e "\n${CYBER_GREEN}✅ SYSTEM PURGE COMPLETE!${NC}"
  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Limpeza profunda (opcional)
deep_clean() {
  echo -e "\n${CYBER_RED}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_RED}☠️ WARNING: INITIATING DEEP PURGE SEQUENCE...☠️${NC}"
  echo -e "${CYBER_YELLOW}This will remove all unnecessary system files and temporary data${NC}"

  read -p "$(echo -e "${CYBER_RED}Are you sure? (y/N): ${NC}")" confirm
  if [[ $confirm =~ ^[Yy]$ ]]; then
    # Limpeza de pacotes não utilizados
    echo -e "\n${CYBER_YELLOW}🗑️ REMOVING UNUSED PACKAGES...${NC}"
    if command -v apt-get &>/dev/null; then
      sudo apt-get clean 2>/dev/null
    elif command -v dnf &>/dev/null; then
      sudo dnf clean all 2>/dev/null
    elif command -v yum &>/dev/null; then
      sudo yum clean all 2>/dev/null
    fi
    echo -e "${CYBER_GREEN}✔ Unused packages cleaned${NC}"

    # Limpeza de arquivos temporários
    echo -e "\n${CYBER_YELLOW}⏳ CLEANING TEMPORARY FILES...${NC}"
    sudo rm -rf /tmp/* /var/tmp/* 2>/dev/null
    echo -e "${CYBER_GREEN}✔ Temporary files removed${NC}"

    # Limpeza de docker (se instalado)
    if command -v docker &>/dev/null; then
      echo -e "\n${CYBER_YELLOW}🐳 CLEANING DOCKER...${NC}"
      docker system prune -af 2>/dev/null
      echo -e "${CYBER_GREEN}✔ Docker cleanup complete${NC}"
    fi

    # Limpeza de flatpak (se instalado)
    if command -v flatpak &>/dev/null; then
      echo -e "\n${CYBER_YELLOW}📦 CLEANING FLATPAK...${NC}"
      flatpak uninstall --unused -y 2>/dev/null
      rm -rf ~/.var/app/*/cache/* 2>/dev/null
      echo -e "${CYBER_GREEN}✔ Flatpak cleanup complete${NC}"
    fi

    echo -e "\n${CYBER_GREEN}✅ DEEP PURGE COMPLETE!${NC}"
  else
    echo -e "\n${CYBER_BLUE}🚫 PURGE SEQUENCE ABORTED!${NC}"
  fi
  echo -e "${CYBER_RED}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Menu interativo
interactive_menu() {
  show_header
  echo -e "${CYBER_BLUE}1) ${CYBER_GREEN}Basic System Clean"
  echo -e "${CYBER_BLUE}2) ${CYBER_RED}Deep Clean (Advanced)"
  echo -e "${CYBER_BLUE}3) ${CYBER_PURPLE}Exit${NC}"
  echo -e "\n${CYBER_YELLOW}Select an option:${NC} "

  read -r choice
  case $choice in
    1) basic_clean ;;
    2) deep_clean ;;
    3) return 0 ;;
    *) echo -e "${CYBER_RED}Invalid option!${NC}" ;;
  esac
}

# Modo direto
direct_mode() {
  case "$1" in
    basic)
      basic_clean
      ;;
    deep)
      deep_clean
      ;;
    *)
      echo -e "${CYBER_RED}Usage:"
      echo -e "  clean basic"
      echo -e "  clean deep${NC}"
      return 1
      ;;
  esac
}

# Função de ajuda do módulo clean
show_clean_help() {
    show_header_custom "SYSTEM PURGE" "🧹" "${CYBER_BLUE}"
    
    echo -e "${CYBER_BLUE}USAGE:${NC}"
    echo -e "  prime clean ${CYBER_YELLOW}[command]${NC}"
    echo
    
    echo -e "${CYBER_BLUE}COMMANDS:${NC}"
    echo -e "  ${CYBER_GREEN}basic${NC}     Basic system cleanup"
    echo -e "  ${CYBER_RED}deep${NC}      Deep system cleanup"
    echo
    
    echo -e "${CYBER_BLUE}OPTIONS:${NC}"
    echo -e "  ${CYBER_YELLOW}-y, --yes${NC}    Auto-confirm all operations"
    echo -e "  ${CYBER_YELLOW}-h, --help${NC}   Show this help message"
    echo
    
    echo -e "${CYBER_BLUE}EXAMPLES:${NC}"
    echo -e "  ${CYBER_YELLOW}prime clean${NC}           # Interactive mode"
    echo -e "  ${CYBER_YELLOW}prime clean basic${NC}     # Basic cleanup"
    echo -e "  ${CYBER_YELLOW}prime clean deep -y${NC}   # Deep cleanup with auto-confirm"
}

# Função principal de limpeza
run_clean() {
    local auto_confirm=false
    local mode=""

    # Processar argumentos
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                show_clean_help
                return 0
                ;;
            --yes|-y)
                auto_confirm=true
                shift
                ;;
            basic|deep)
                mode="$1"
                shift
                ;;
            *)
                echo -e "${CYBER_RED}Invalid option: $1${NC}"
                show_clean_help
                return 1
                ;;
        esac
    done

    # Se modo não especificado, usar menu interativo
    if [ -z "$mode" ]; then
        interactive_menu
        return
    fi

    # Se modo especificado, executar diretamente
    if [ "$auto_confirm" = true ]; then
        export AUTO_CONFIRM=true
    fi
    
    direct_mode "$mode"
}

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_clean "$@"
fi
