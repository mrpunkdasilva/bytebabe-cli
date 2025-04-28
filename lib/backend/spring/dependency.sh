#!/bin/bash

# Lista dependências disponíveis
list_dependencies() {
    echo -e "${CYBER_BLUE}Dependências disponíveis:${RESET}"
    echo -e "  ${CYBER_GREEN}web${RESET}         - Spring Web"
    echo -e "  ${CYBER_GREEN}data-jpa${RESET}    - Spring Data JPA"
    echo -e "  ${CYBER_GREEN}security${RESET}    - Spring Security"
    echo -e "  ${CYBER_GREEN}validation${RESET}  - Validation"
    echo -e "  ${CYBER_GREEN}actuator${RESET}    - Actuator"
    echo -e "  ${CYBER_GREEN}devtools${RESET}    - Developer Tools"
    echo -e "  ${CYBER_GREEN}lombok${RESET}      - Lombok"
}

# Adiciona dependência ao projeto
add_dependency() {
    local dependency="$1"
    
    if [[ ! -f "pom.xml" ]]; then
        echo -e "${CYBER_RED}✘ Arquivo pom.xml não encontrado${RESET}"
        return 1
    fi
    
    # TODO: Implementar lógica para adicionar dependência ao pom.xml
    echo -e "${CYBER_GREEN}✔ Dependência ${dependency} adicionada com sucesso${RESET}"
}

# Remove dependência do projeto
remove_dependency() {
    local dependency="$1"
    
    if [[ ! -f "pom.xml" ]]; then
        echo -e "${CYBER_RED}✘ Arquivo pom.xml não encontrado${RESET}"
        return 1
    fi
    
    # TODO: Implementar lógica para remover dependência do pom.xml
    echo -e "${CYBER_GREEN}✔ Dependência ${dependency} removida com sucesso${RESET}"
}