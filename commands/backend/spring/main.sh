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
source "$BASE_DIR/lib/backend/spring/templates.sh"
source "$BASE_DIR/lib/backend/spring/dependency.sh"
source "$BASE_DIR/lib/backend/spring/profile.sh"

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
    
    template)
        shift
        case "$1" in
            list)
                list_templates
                ;;
            add)
                shift
                add_template "$@"
                ;;
            *)
                show_spring_template_help
                ;;
        esac
        ;;
        
    dependency|dep)
        shift
        case "$1" in
            list)
                list_dependencies
                ;;
            add)
                shift
                add_dependency "$@"
                ;;
            remove)
                shift
                remove_dependency "$@"
                ;;
            *)
                show_spring_dependency_help
                ;;
        esac
        ;;
        
    profile)
        shift
        case "$1" in
            list)
                list_profiles
                ;;
            create)
                shift
                create_profile "$@"
                ;;
            set-active)
                shift
                set_active_profile "$@"
                ;;
            *)
                show_spring_profile_help
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
            controller|ctrl)
                shift
                generate_controller "$@"
                ;;
            service|svc)
                shift
                generate_service "$@"
                ;;
            repository|repo)
                shift
                generate_repository "$@"
                ;;
            entity)
                shift
                generate_entity "$@"
                ;;
            dto)
                shift
                generate_dto "$@"
                ;;
            crud)
                shift
                generate_crud "$@"
                ;;
            security)
                shift
                generate_security_config "$@"
                ;;
            all)
                shift
                local name="$1"
                if [[ -z "$name" ]]; then
                    echo -e "${CYBER_RED}✘ Nome da entidade é obrigatório${RESET}"
                    exit 1
                fi
                generate_entity "$name"
                generate_repository "$name"
                generate_service "$name"
                generate_controller "$name"
                generate_dto "$name"
                echo -e "${CYBER_GREEN}✔ Todos os componentes foram gerados para ${name}${RESET}"
                ;;
            *)
                echo -e "${CYBER_RED}✘ Gerador não encontrado: $1${RESET}"
                echo -e "Use ${CYBER_YELLOW}bytebabe spring generator list${RESET} para ver os geradores disponíveis"
                exit 1
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
            service)
                shift
                generate_service_test "$@"
                ;;
            controller)
                shift
                generate_controller_test "$@"
                ;;
            run)
                shift
                mvn test "$@"
                ;;
            *)
                show_spring_test_help
                ;;
        esac
        ;;

    docs)
        shift
        case "$1" in
            setup)
                setup_swagger
                ;;
            *)
                show_spring_docs_help
                ;;
        esac
        ;;

    docker)
        shift
        case "$1" in
            setup)
                generate_docker_files
                ;;
            build)
                docker-compose build
                ;;
            up)
                docker-compose up -d
                ;;
            down)
                docker-compose down
                ;;
            *)
                show_spring_docker_help
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