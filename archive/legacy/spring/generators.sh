#!/bin/bash

# Carrega todos os geradores
source "$BASE_DIR/lib/backend/spring/generators/entity.sh"
source "$BASE_DIR/lib/backend/spring/generators/dto.sh"
source "$BASE_DIR/lib/backend/spring/generators/repository.sh"
source "$BASE_DIR/lib/backend/spring/generators/service.sh"
source "$BASE_DIR/lib/backend/spring/generators/controller.sh"
source "$BASE_DIR/lib/backend/spring/generators/crud.sh"
source "$BASE_DIR/lib/backend/spring/generators/custom.sh"
source "$BASE_DIR/lib/backend/spring/generators/security_config.sh"

# Verifica se um gerador existe
generator_exists() {
    local generator_name="$1"
    case "$generator_name" in
        "entity"|"dto"|"repository"|"service"|"controller"|"crud"|"security")
            return 0
            ;;
        *)
            # Verifica se existe um gerador customizado com este nome
            if [[ -f "$CUSTOM_GENERATORS_DIR/$generator_name.sh" ]]; then
                return 0
            fi
            return 1
            ;;
    esac
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
    echo -e "  ${CYBER_GREEN}security${RESET}   - Gera configuração de segurança com JWT"
    echo
    list_custom_generators
}