#!/bin/bash

# Carrega o diretório base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"

# Carrega as dependências
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/backend/spring/help.sh"
source "$BASE_DIR/lib/backend/spring/config.sh"
source "$BASE_DIR/lib/backend/spring/generators.sh"
source "$BASE_DIR/lib/backend/spring/project.sh"
source "$BASE_DIR/lib/backend/spring/commands.sh"

# Verifica se Java e Maven estão instalados
check_requirements() {
    if ! command -v java &> /dev/null; then
        echo -e "${CYBER_RED}✘ Java não encontrado! Por favor, instale o Java JDK${RESET}"
        exit 1
    fi

    if ! command -v mvn &> /dev/null; then
        echo -e "${CYBER_RED}✘ Maven não encontrado! Por favor, instale o Maven${RESET}"
        exit 1
    fi
}

# Carrega geradores customizados no início
load_custom_generators

# Handler principal de comandos
case "$1" in
    new|create)
        shift
        case "$1" in
            help|--help|-h)
                show_spring_new_help
                ;;
            *)
                check_requirements
                create_spring_project "$@"
                ;;
        esac
        ;;
    
    config)
        shift
        spring_config "$@"
        ;;
        
    generator|gen)
        shift
        case "$1" in
            add)
                shift
                add_custom_generator "$@"
                ;;
            remove|rm)
                shift
                remove_custom_generator "$@"
                ;;
            edit|e)
                shift
                edit_custom_generator "$@"
                ;;
            list|ls)
                list_all_generators
                ;;
            help|--help|-h)
                echo -e "${CYBER_BLUE}Comandos disponíveis para generator:${RESET}"
                echo -e "  ${CYBER_GREEN}add${RESET}    - Adiciona um novo gerador customizado"
                echo -e "  ${CYBER_GREEN}remove${RESET} - Remove um gerador customizado"
                echo -e "  ${CYBER_GREEN}edit${RESET}   - Edita um gerador customizado"
                echo -e "  ${CYBER_GREEN}list${RESET}   - Lista todos os geradores disponíveis"
                ;;
            *)
                echo -e "${CYBER_RED}✘ Comando inválido para generator${RESET}"
                echo -e "Use ${CYBER_YELLOW}bytebabe spring generator --help${RESET} para ver os comandos disponíveis"
                ;;
        esac
        ;;
        
    generate|g)
        shift
        case "$1" in
            help|--help|-h)
                show_spring_generate_help
                ;;
            controller|service|repository|entity|dto|crud)
                local generator_type=$1
                shift
                "generate_$generator_type" "$@"
                ;;
            *)
                if generator_exists "$1"; then
                    local generator_name=$1
                    shift
                    "generate_$generator_name" "$@"
                else
                    echo -e "${CYBER_RED}✘ Gerador não encontrado: $1${RESET}"
                    echo -e "Use ${CYBER_YELLOW}bytebabe spring generator list${RESET} para ver os geradores disponíveis"
                    return 1
                fi
                ;;
        esac
        ;;

    run)
        shift
        case "$1" in
            help|--help|-h)
                show_spring_run_help
                ;;
            *)
                check_requirements
                mvn spring-boot:run "$@"
                ;;
        esac
        ;;

    build)
        shift
        case "$1" in
            help|--help|-h)
                show_spring_build_help
                ;;
            *)
                check_requirements
                mvn clean package "$@"
                ;;
        esac
        ;;

    test)
        shift
        case "$1" in
            help|--help|-h)
                show_spring_test_help
                ;;
            *)
                check_requirements
                mvn test "$@"
                ;;
        esac
        ;;

    clean)
        shift
        case "$1" in
            help|--help|-h)
                show_spring_clean_help
                ;;
            *)
                check_requirements
                mvn clean "$@"
                ;;
        esac
        ;;

    help|--help|-h)
        show_spring_help
        ;;
        
    *)
        show_spring_help
        ;;
esac