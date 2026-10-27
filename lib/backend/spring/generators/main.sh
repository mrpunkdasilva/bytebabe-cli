#!/bin/bash

# Carregador canônico dos geradores Spring.
# Cada tipo deve ter uma única implementação ativa listada aqui.

source "$BASE_DIR/lib/backend/spring/generators/help.sh"
source "$BASE_DIR/lib/backend/spring/generators/entity.sh"
source "$BASE_DIR/lib/backend/spring/generators/dto.sh"
source "$BASE_DIR/lib/backend/spring/generators/repository.sh"
source "$BASE_DIR/lib/backend/spring/generators/service.sh"
source "$BASE_DIR/lib/backend/spring/generators/controller.sh"
source "$BASE_DIR/lib/backend/spring/generators/crud.sh"
source "$BASE_DIR/lib/backend/spring/generators/mapper.sh"
source "$BASE_DIR/lib/backend/spring/generators/exception_handler.sh"
source "$BASE_DIR/lib/backend/spring/generators/security_config.sh"
source "$BASE_DIR/lib/backend/spring/generators/test_generator.sh"
source "$BASE_DIR/lib/backend/spring/generators/docker_generator.sh"
source "$BASE_DIR/lib/backend/spring/generators/docs_generator.sh"
source "$BASE_DIR/lib/backend/spring/generators/custom.sh"

# Verifica se um gerador existe
generator_exists() {
    local generator_name="$1"
    case "$generator_name" in
        "entity"|"dto"|"repository"|"service"|"controller"|"crud"|"mapper"|"exception-handler"|"security")
            return 0
            ;;
        *)
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
    echo -e "  ${CYBER_GREEN}entity${RESET}            - Gera uma entidade JPA"
    echo -e "  ${CYBER_GREEN}dto${RESET}               - Gera um DTO"
    echo -e "  ${CYBER_GREEN}repository${RESET}        - Gera um repositório Spring Data"
    echo -e "  ${CYBER_GREEN}service${RESET}           - Gera uma camada de serviço"
    echo -e "  ${CYBER_GREEN}controller${RESET}        - Gera um controller REST"
    echo -e "  ${CYBER_GREEN}crud${RESET}              - Gera um CRUD completo"
    echo -e "  ${CYBER_GREEN}mapper${RESET}            - Gera um mapper MapStruct"
    echo -e "  ${CYBER_GREEN}exception-handler${RESET} - Gera um exception handler global"
    echo -e "  ${CYBER_GREEN}security${RESET}          - Gera configuração de segurança com JWT"
    echo
    list_custom_generators
}

# Função principal para geração de código
generate_spring_component() {
    local component_type="$1"
    shift

    case "$component_type" in
        "entity")
            generate_entity "$@"
            ;;
        "dto")
            generate_dto "$@"
            ;;
        "repository")
            generate_repository "$@"
            ;;
        "service")
            generate_service "$@"
            ;;
        "controller")
            generate_controller "$@"
            ;;
        "crud")
            generate_crud "$@"
            ;;
        "mapper")
            generate_mapper "$@"
            ;;
        "exception-handler"|"exception")
            generate_exception_handler "$@"
            ;;
        "security")
            generate_security_config "$@"
            ;;
        *)
            echo -e "${CYBER_RED}✘ Tipo de componente inválido: $component_type${RESET}"
            show_spring_generate_help
            return 1
            ;;
    esac
}
