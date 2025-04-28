#!/bin/bash

show_frontend_new_help() {
    echo -e "${CYBER_BLUE}${CYBER_BOLD}CRIAR NOVO PROJETO FRONTEND${RESET}"
    echo ""
    echo -e "${CYBER_YELLOW}Uso: bytebabe frontend new <framework> <nome> [template]${RESET}"
    echo ""
    echo -e "${CYBER_PINK}Frameworks Disponíveis:${RESET}"
    echo -e "  ${CYBER_GREEN}react${RESET}    Create React App ou Vite"
    echo -e "  ${CYBER_GREEN}vue${RESET}      Vue 3 com Vite"
    echo -e "  ${CYBER_GREEN}angular${RESET}  Angular CLI"
    echo -e "  ${CYBER_GREEN}next${RESET}     Next.js"
    echo -e "  ${CYBER_GREEN}svelte${RESET}   Svelte com Vite"
    echo ""
    echo -e "${CYBER_PINK}Templates:${RESET}"
    echo -e "  ${CYBER_GREEN}default${RESET}  Template padrão do framework"
    echo -e "  ${CYBER_GREEN}vite${RESET}     Usando Vite (React/Vue)"
    echo ""
    echo -e "${CYBER_PINK}Exemplos:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe frontend new react my-app${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe frontend new vue my-app vite${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe frontend new next my-app${RESET}"
}

show_frontend_add_help() {
    echo -e "${CYBER_BLUE}${CYBER_BOLD}ADICIONAR FUNCIONALIDADES${RESET}"
    echo ""
    echo -e "${CYBER_YELLOW}Uso: bytebabe frontend add <feature> [opções]${RESET}"
    echo ""
    echo -e "${CYBER_PINK}Funcionalidades Disponíveis:${RESET}"
    echo -e "  ${CYBER_GREEN}tailwind${RESET}  Adiciona TailwindCSS"
    echo -e "  ${CYBER_GREEN}redux${RESET}     Adiciona Redux Toolkit"
    echo -e "  ${CYBER_GREEN}router${RESET}    Adiciona roteamento"
    echo -e "  ${CYBER_GREEN}i18n${RESET}      Adiciona internacionalização"
    echo ""
    echo -e "${CYBER_PINK}Exemplos:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe frontend add tailwind${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe frontend add redux${RESET}"
}