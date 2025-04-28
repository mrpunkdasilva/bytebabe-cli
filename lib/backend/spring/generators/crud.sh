#!/bin/bash

generate_crud() {
    local name=""
    local package=""
    local table_name=""

    # Se o primeiro argumento não começa com '-', é o nome
    if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
        name="$1"
        shift
    fi

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
            -t|--table)
                table_name="$2"
                shift 2
                ;;
            *)
                echo -e "${CYBER_RED}✘ Opção inválida: $1${RESET}"
                show_spring_generate_help
                return 1
                ;;
        esac
    done

    # Validações
    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome é obrigatório${RESET}"
        show_spring_generate_help
        return 1
    fi

    # Se package não foi fornecido, usa o padrão da configuração
    if [[ -z "$package" ]]; then
        package=$(get_base_package)
        if [[ -z "$package" ]]; then
            echo -e "${CYBER_RED}✘ Package é obrigatório. Configure um package base ou forneça via -p${RESET}"
            return 1
        fi
    fi

    echo -e "${CYBER_BLUE}▶ Gerando CRUD completo para: ${name}...${RESET}"
    
    # Gera a entity
    generate_entity -n "$name" -p "$package.model" ${table_name:+-t "$table_name"}
    
    # Gera o DTO
    generate_dto -n "${name}DTO" -p "$package.dto" -e "$name"
    
    # Gera o repository
    generate_repository -n "${name}Repository" -p "$package.repository" -e "$name"
    
    # Gera o service
    generate_service -n "${name}Service" -p "$package.service"
    
    # Gera o controller
    generate_controller -n "${name}Controller" -p "$package.controller"
    
    echo -e "${CYBER_GREEN}✔ CRUD completo gerado com sucesso!${RESET}"
    echo -e "${CYBER_BLUE}▶ Estrutura gerada:${RESET}"
    echo -e "  ${CYBER_CYAN}├─ model/${name}.java${RESET}"
    echo -e "  ${CYBER_CYAN}├─ dto/${name}DTO.java${RESET}"
    echo -e "  ${CYBER_CYAN}├─ repository/${name}Repository.java${RESET}"
    echo -e "  ${CYBER_CYAN}├─ service/${name}Service.java${RESET}"
    echo -e "  ${CYBER_CYAN}└─ controller/${name}Controller.java${RESET}"
}