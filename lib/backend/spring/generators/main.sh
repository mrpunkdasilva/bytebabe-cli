#!/bin/bash

# Carrega todos os geradores
source "$BASE_DIR/lib/backend/spring/generators/entity.sh"
source "$BASE_DIR/lib/backend/spring/generators/repository.sh"
source "$BASE_DIR/lib/backend/spring/generators/service.sh"
source "$BASE_DIR/lib/backend/spring/generators/controller.sh"
source "$BASE_DIR/lib/backend/spring/generators/dto.sh"
source "$BASE_DIR/lib/backend/spring/generators/mapper.sh"
source "$BASE_DIR/lib/backend/spring/generators/exception_handler.sh"
source "$BASE_DIR/lib/backend/spring/generators/security_config.sh"

# Função principal para geração de código
generate_spring_component() {
    local component_type="$1"
    shift

    case "$component_type" in
        "entity")
            generate_entity "$@"
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
        "dto")
            generate_dto "$@"
            ;;
        "mapper")
            generate_mapper "$@"
            ;;
        "exception-handler")
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


