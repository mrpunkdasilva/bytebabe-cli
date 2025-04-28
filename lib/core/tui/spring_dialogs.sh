#!/bin/bash

# Dialog para criar novo projeto Spring
create_spring_project_dialog() {
    local project_name
    local package_name
    local dependencies=""
    
    # Nome do projeto
    project_name=$(get_input "New Spring Project" "Enter project name:")
    if [ -z "$project_name" ]; then
        return
    fi
    
    # Package name
    package_name=$(get_input "Package Name" "Enter package name:" "com.example")
    if [ -z "$package_name" ]; then
        return
    }
    
    # Seleção de dependências
    dependencies=$(dialog --clear \
                        --backtitle "$DIALOG_BACKTITLE" \
                        --title "[ Select Dependencies ]" \
                        --checklist "Choose dependencies:" \
                        15 60 8 \
                        "web" "Spring Web" on \
                        "data-jpa" "Spring Data JPA" on \
                        "security" "Spring Security" off \
                        "actuator" "Spring Actuator" off \
                        "devtools" "Spring DevTools" off \
                        "validation" "Validation" off \
                        "postgresql" "PostgreSQL Driver" off \
                        "mysql" "MySQL Driver" off \
                        2>&1 >/dev/tty)
    
    if [ $? -ne 0 ]; then
        return
    fi
    
    # Confirmação
    if confirm_dialog "Confirm" "Create project with these settings?\n\nProject: $project_name\nPackage: $package_name\nDependencies: $dependencies"; then
        show_progress "Creating Project" "create_spring_project \"$project_name\" \"$package_name\" \"$dependencies\""
        show_message "Success" "Project created successfully!\n\nLocation: $(pwd)/$project_name"
    fi
}

# Dialog para gerar componentes
generate_components_dialog() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Generate Components ]" \
                       --menu "Select component to generate:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 8 \
                       "1" "🎯 Controller" \
                       "2" "⚙️ Service" \
                       "3" "💾 Repository" \
                       "4" "📦 Entity" \
                       "5" "📄 DTO" \
                       "6" "🔄 Full CRUD" \
                       "7" "🔒 Security Config" \
                       "8" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) generate_controller_dialog ;;
            2) generate_service_dialog ;;
            3) generate_repository_dialog ;;
            4) generate_entity_dialog ;;
            5) generate_dto_dialog ;;
            6) generate_crud_dialog ;;
            7) generate_security_dialog ;;
            8) break ;;
            *) break ;;
        esac
    done
}

# Dialog para gerenciar dependências
manage_dependencies_dialog() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Dependency Management ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 4 \
                       "1" "📋 List Dependencies" \
                       "2" "➕ Add Dependency" \
                       "3" "➖ Remove Dependency" \
                       "4" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) list_dependencies_dialog ;;
            2) add_dependency_dialog ;;
            3) remove_dependency_dialog ;;
            4) break ;;
            *) break ;;
        esac
    done
}

# Dialog para executar o projeto
run_spring_project_dialog() {
    local profile
    
    # Seleciona o profile
    profile=$(dialog --clear \
                    --backtitle "$DIALOG_BACKTITLE" \
                    --title "[ Run Project ]" \
                    --menu "Select profile:" \
                    $DIALOG_HEIGHT $DIALOG_WIDTH 4 \
                    "1" "🔧 Development (dev)" \
                    "2" "🧪 Test" \
                    "3" "🚀 Production (prod)" \
                    "4" "Cancel" \
                    2>&1 >/dev/tty)

    case $profile in
        1) profile="dev" ;;
        2) profile="test" ;;
        3) profile="prod" ;;
        4) return ;;
        *) return ;;
    esac
    
    if confirm_dialog "Confirm" "Run project with profile: $profile?"; then
        clear
        echo -e "${CYBER_GREEN}Starting Spring Boot application with profile: $profile${RESET}"
        mvn spring-boot:run -Dspring-boot.run.profiles=$profile
        
        echo -e "\n${CYBER_YELLOW}Press any key to continue...${RESET}"
        read -n 1
    fi
}

# Dialog para build do projeto
build_spring_project_dialog() {
    if confirm_dialog "Build Project" "Build project with Maven?"; then
        show_progress "Building Project" "mvn clean package"
        show_message "Success" "Project built successfully!"
    fi
}

# Dialog para testes
run_spring_tests_dialog() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Test Operations ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 5 \
                       "1" "🧪 Run All Tests" \
                       "2" "📝 Generate Service Test" \
                       "3" "🎯 Generate Controller Test" \
                       "4" "📊 Show Test Report" \
                       "5" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) run_all_tests_dialog ;;
            2) generate_service_test_dialog ;;
            3) generate_controller_test_dialog ;;
            4) show_test_report_dialog ;;
            5) break ;;
            *) break ;;
        esac
    done
}

# Dialog para documentação
generate_spring_docs_dialog() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Documentation ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 4 \
                       "1" "📚 Setup Swagger/OpenAPI" \
                       "2" "📖 Generate API Docs" \
                       "3" "🌐 Start Swagger UI" \
                       "4" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) setup_swagger_dialog ;;
            2) generate_api_docs_dialog ;;
            3) start_swagger_ui_dialog ;;
            4) break ;;
            *) break ;;
        esac
    done
}

# Dialog para operações Docker
spring_docker_dialog() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Docker Operations ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 5 \
                       "1" "🔧 Setup Docker Files" \
                       "2" "🏗️ Build Image" \
                       "3" "▶️ Start Containers" \
                       "4" "⏹️ Stop Containers" \
                       "5" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) setup_docker_files_dialog ;;
            2) build_docker_image_dialog ;;
            3) start_docker_containers_dialog ;;
            4) stop_docker_containers_dialog ;;
            5) break ;;
            *) break ;;
        esac
    done
}