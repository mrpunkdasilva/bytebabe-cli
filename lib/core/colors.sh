#!/bin/bash

# Cores Cyberpunk
CYBER_BLUE="\033[38;5;45m"
CYBER_PINK="\033[38;5;201m"
CYBER_GREEN="\033[38;5;118m"
CYBER_YELLOW="\033[38;5;227m"
CYBER_ORANGE="\033[38;5;208m"
RESET="\033[0m"


# Cores Principais
CYBER_PURPLE="\033[38;5;129m"      # Roxo digital
CYBER_RED="\033[38;5;196m"         # Vermelho alerta

# Efeitos Especiais
CYBER_GLITCH="\033[38;5;45;5m"     # Efeito glitch piscante
CYBER_BLINK="\033[5m"              # Piscamento
CYBER_BOLD="\033[1m"               # Negrito
CYBER_UNDERLINE="\033[4m"          # Sublinhado

# Fundos
CYBER_BG_BLACK="\033[48;5;0m"      # Fundo preto
CYBER_BG_DARK="\033[48;5;234m"     # Fundo escuro

# Reset
RESET="\033[0m"

# ======================
# ELEMENTOS GRÁFICOS
# ======================

# Barras e Divisores
CYBER_DIVIDER="${CYBER_BG_BLACK}${CYBER_PURPLE}$(printf '■%.0s' {1..80})${RESET}"
CYBER_LINE="${CYBER_BG_BLACK}${CYBER_BLUE}$(printf '─%.0s' {1..80})${RESET}"

# Ícones
CYBER_ICON_SUCCESS="${CYBER_GREEN}✓${RESET}"
CYBER_ICON_ERROR="${CYBER_RED}✗${RESET}"
CYBER_ICON_WARNING="${CYBER_YELLOW}⚠${RESET}"
CYBER_ICON_INFO="${CYBER_BLUE}ℹ${RESET}"
CYBER_ICON_TERMINAL="${CYBER_PINK}⌘${RESET}"

# ======================
# FUNÇÕES DE ESTILO
# ======================

cyber_header() {
    echo -e "${CYBER_BG_BLACK}${CYBER_PINK}"
    echo "╔══════════════════════════════════════════════╗"
    echo "║  ██████╗██╗   ██╗██████╗ ███████╗██████╗   ║"
    echo "║  ██╔═══╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗  ║"
    echo "║  ██████╗ ╚████╔╝ ██████╔╝█████╗  ██████╔╝  ║"
    echo "║  ╚════██╗ ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗  ║"
    echo "║  ██████╔╝  ██║   ██████╔╝███████╗██║  ██║  ║"
    echo "║  ╚═════╝   ╚═╝   ╚═════╝ ╚══════╝╚═╝  ╚═╝  ║"
    echo "╚══════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

cyber_divider() {
    echo -e "${CYBER_DIVIDER}"
}

cyber_echo() {
    local color=$1
    local text=$2
    echo -e "${!color}${CYBER_BOLD}${text}${RESET}"
}