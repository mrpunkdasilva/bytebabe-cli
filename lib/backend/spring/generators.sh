#!/bin/bash

# Carrega todos os geradores
source "$BASE_DIR/lib/backend/spring/generators/entity.sh"
source "$BASE_DIR/lib/backend/spring/generators/dto.sh"
source "$BASE_DIR/lib/backend/spring/generators/repository.sh"
source "$BASE_DIR/lib/backend/spring/generators/service.sh"
source "$BASE_DIR/lib/backend/spring/generators/controller.sh"
source "$BASE_DIR/lib/backend/spring/generators/crud.sh"
source "$BASE_DIR/lib/backend/spring/generators/custom.sh"

# Função para verificar se um gerador existe
generator_exists() {
    local name=$1
    type "generate_$name" &>/dev/null
    return $?
}

# Função para listar todos os geradores disponíveis
list_all_generators() {
    echo -e "${CYBER_BLUE}Geradores padrão:${RESET}"
    echo -e "  ${CYBER_GREEN}entity${RESET}     - Gera uma entidade JPA"
    echo -e "  ${CYBER_GREEN}dto${RESET}        - Gera um DTO"
    echo -e "  ${CYBER_GREEN}repository${RESET} - Gera um repositório Spring Data"
    echo -e "  ${CYBER_GREEN}service${RESET}    - Gera uma camada de serviço"
    echo -e "  ${CYBER_GREEN}controller${RESET} - Gera um controller REST"
    echo -e "  ${CYBER_GREEN}crud${RESET}       - Gera um CRUD completo"
    echo
    list_custom_generators
}
