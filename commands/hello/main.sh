#!/bin/bash

# Carrega as bibliotecas necessárias
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

# Array com frases cyberpunk
CYBER_QUOTES=(
    "Wake up, samurai. We have code to write. 🌆"
    "In a world of 1's and 0's, be the glitch. ⚡"
    "Hack the planet! 🌍"
    "Stay connected, stay dangerous. 💻"
    "Reality is just another simulation. 🕹️"
    "Code never dies, it just gets recompiled. 🔄"
    "Living life in neon dreams. 🌈"
    "Error 404: Normal life not found. 🚫"
    "Born to code, forced to adult. 🤖"
    "Keep coding and carry on. ⌨️"
    "Time to split some bits. 🎯"
    "Loading personality... please wait... 📶"
    "chmod 777 your_mind 🧠"
    "sudo make me_awesome 🚀"
    "Coffee.exe has stopped working ☕"
    "git commit -m \"fixed my life\" 💾"
)

# Função para mostrar o header personalizado
show_hello_header() {
    echo -e "${CYBER_PINK}╔════════════════════════════════════════════════╗"
    echo -e "║${CYBER_CYAN}           BYTEBABE SAYS HI! (⌐■_■)${CYBER_PINK}           ║"
    echo -e "╚════════════════════════════════════════════════╝${RESET}"
}

# Função para mostrar uma frase aleatória
show_random_quote() {
    # Gera um índice aleatório
    local random_index=$((RANDOM % ${#CYBER_QUOTES[@]}))
    
    # Pega a frase correspondente
    local quote="${CYBER_QUOTES[$random_index]}"
    
    # Exibe a frase com estilo
    echo -e "\n${CYBER_GREEN}${quote}${RESET}\n"
}

# Função principal
main() {
    show_hello_header
    show_random_quote
}

# Executa o comando
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
