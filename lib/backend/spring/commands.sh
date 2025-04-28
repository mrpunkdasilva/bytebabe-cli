#!/bin/bash

spring_config() {
    case "$1" in
        "init")
            init_spring_config
            ;;
        "set-base")
            if [[ -z "$2" ]]; then
                echo -e "${CYBER_RED}✖ Forneça o package base${NC}"
                return 1
            fi
            set_base_package "$2"
            ;;
        "set-default")
            if [[ -z "$2" || -z "$3" ]]; then
                echo -e "${CYBER_RED}✖ Forneça o tipo e o subpackage${NC}"
                return 1
            fi
            set_default_package "$2" "$3"
            ;;
        "show")
            cat "$CONFIG_FILE" | jq '.'
            ;;
        *)
            echo -e "${CYBER_BLUE}Uso da configuração Spring:${NC}"
            echo -e "  ${CYBER_GREEN}spring config init${NC}                    # Inicializa configuração"
            echo -e "  ${CYBER_GREEN}spring config set-base <package>${NC}     # Define package base"
            echo -e "  ${CYBER_GREEN}spring config set-default <tipo> <pkg>${NC} # Define package padrão"
            echo -e "  ${CYBER_GREEN}spring config show${NC}                   # Mostra configuração"
            ;;
    esac
}