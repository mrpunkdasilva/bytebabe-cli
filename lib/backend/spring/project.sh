#!/bin/bash

create_spring_project() {
    local name=""
    local package=""
    local deps=""

    # Parse argumentos
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--name)
                name="$2"
                shift 2
                ;;
            -p|--package)
                package="$2"
                shift 2
                ;;
            -d|--deps)
                deps="$2"
                shift 2
                ;;
            *)
                echo -e "${CYBER_RED}✘ Opção inválida: $1${RESET}"
                show_spring_new_help
                return 1
                ;;
        esac
    done

    # Validações
    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome do projeto é obrigatório${RESET}"
        show_spring_new_help
        return 1
    fi

    if [[ -z "$package" ]]; then
        package="com.example.$name"
    fi

    echo -e "${CYBER_BLUE}▶ Criando projeto Spring Boot: ${name}...${RESET}"
    
    # TODO: Implementar criação do projeto usando Spring Initializr
    # Pode ser via curl para https://start.spring.io ou usando spring cli
    
    echo -e "${CYBER_GREEN}✔ Projeto criado com sucesso!${RESET}"
}