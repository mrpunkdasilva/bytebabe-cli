#!/bin/bash

# Importa módulos
source "$(dirname "$0")/request.sh"

# Menu principal
show_main_menu() {
    while true; do
        clear
        echo -e "${HEADER_STYLE}╔════════════════════════════════════════════════╗${RESET}"
        echo -e "${HEADER_STYLE}║           BYTEBABE FLUX API CLIENT             ║${RESET}"
        echo -e "${HEADER_STYLE}╚════════════════════════════════════════════════╝${RESET}"
        echo
        echo -e "1) ${CYBER_CYAN}Enviar GET request${RESET}"
        echo -e "2) ${CYBER_CYAN}Enviar POST request${RESET}"
        echo -e "3) ${CYBER_CYAN}Enviar PUT request${RESET}"
        echo -e "4) ${CYBER_CYAN}Enviar DELETE request${RESET}"
        echo -e "5) ${CYBER_CYAN}Configurar headers${RESET}"
        echo -e "H) ${CYBER_CYAN}Histórico de Requisições${RESET}"  # Nova opção
        echo -e "Q) ${CYBER_CYAN}Sair${RESET}"
        echo
        read -p "Escolha uma opção: " option
        
        case $option in
            1)
                handle_get_request
                ;;
            2)
                handle_post_request
                ;;
            3)
                handle_put_request
                ;;
            4)
                handle_delete_request
                ;;
            5)
                handle_headers_config
                ;;
            [Hh])
                handle_history_option  # Novo handler
                ;;
            [Qq])
                return
                ;;
            *)
                echo -e "${CYBER_RED}✗ Opção inválida${RESET}"
                sleep 1
                ;;
        esac
    done
}

# Inicia o menu principal
show_main_menu