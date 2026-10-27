#!/bin/bash

# Carrega cores e helpers
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"

show_spring_header() {
    echo -e "${CYBER_GREEN}╔════════════════════════════════════════════════╗"
    echo -e "║             🍃 SPRING BOOT CLI              ║"
    echo -e "╚════════════════════════════════════════════════╝${RESET}"
}

show_spring_help() {
    show_spring_header
    
    echo -e "\n${CYBER_BLUE}USAGE:${RESET}"
    echo -e "  bytebabe spring ${CYBER_YELLOW}[command] [options]${RESET}"
    
    echo -e "\n${CYBER_BLUE}COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}new, create${RESET}    Create new Spring Boot project"
    echo -e "  ${CYBER_GREEN}config${RESET}         Configure Spring settings"
    echo -e "  ${CYBER_GREEN}generate, g${RESET}    Generate Spring components"
    echo -e "  ${CYBER_GREEN}run${RESET}            Run Spring Boot application"
    echo -e "  ${CYBER_GREEN}build${RESET}          Build Spring Boot application"
    echo -e "  ${CYBER_GREEN}test${RESET}           Run tests"
    echo -e "  ${CYBER_GREEN}clean${RESET}          Clean build files"
    
    echo -e "\n${CYBER_BLUE}GENERATE COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}controller${RESET}     Generate REST controller"
    echo -e "  ${CYBER_GREEN}service${RESET}        Generate service class"
    echo -e "  ${CYBER_GREEN}repository${RESET}     Generate JPA repository"
    echo -e "  ${CYBER_GREEN}entity${RESET}         Generate JPA entity"
    echo -e "  ${CYBER_GREEN}dto${RESET}            Generate DTO class"
    echo -e "  ${CYBER_GREEN}crud${RESET}           Generate complete CRUD"
    echo -e "  ${CYBER_GREEN}mapper${RESET}         Generate MapStruct mapper"
    echo -e "  ${CYBER_GREEN}exception-handler${RESET} Generate global exception handler"
    echo -e "  ${CYBER_GREEN}security${RESET}       Generate security configuration"
    
    echo -e "\n${CYBER_BLUE}OPTIONS:${RESET}"
    echo -e "  ${CYBER_YELLOW}-n, --name${RESET}        Name of component/project"
    echo -e "  ${CYBER_YELLOW}-p, --package${RESET}     Base package name"
    echo -e "  ${CYBER_YELLOW}-d, --deps${RESET}        Additional dependencies"
    echo -e "  ${CYBER_YELLOW}-h, --help${RESET}        Show command help"
    
    echo -e "\n${CYBER_BLUE}EXAMPLES:${RESET}"
    echo -e "  ${CYBER_CYAN}# Create new project${RESET}"
    echo -e "  bytebabe spring new -n my-api -p com.example.api"
    
    echo -e "\n  ${CYBER_CYAN}# Generate CRUD${RESET}"
    echo -e "  bytebabe spring g crud -n User -p com.example.api.user"
    
    echo -e "\n  ${CYBER_CYAN}# Generate single component${RESET}"
    echo -e "  bytebabe spring g controller -n UserController -p com.example.api.controller"
    
    echo -e "\n${CYBER_BLUE}DOCUMENTATION:${RESET}"
    echo -e "  Run ${CYBER_YELLOW}bytebabe spring <command> --help${RESET} for more information about a command"
}

# Função para mostrar help específico do comando generate
show_spring_generate_help() {
    show_spring_header
    
    echo -e "\n${CYBER_BLUE}GENERATE COMMAND USAGE:${RESET}"
    echo -e "  bytebabe spring generate ${CYBER_YELLOW}<type> [options]${RESET}"
    
    echo -e "\n${CYBER_BLUE}AVAILABLE TYPES:${RESET}"
    echo -e "  ${CYBER_GREEN}controller${RESET}     REST controller with basic CRUD operations"
    echo -e "  ${CYBER_GREEN}service${RESET}        Service layer with business logic"
    echo -e "  ${CYBER_GREEN}repository${RESET}     JPA repository interface"
    echo -e "  ${CYBER_GREEN}entity${RESET}         JPA entity with basic fields"
    echo -e "  ${CYBER_GREEN}dto${RESET}            Data Transfer Object"
    echo -e "  ${CYBER_GREEN}crud${RESET}           Complete CRUD (all above components)"
    echo -e "  ${CYBER_GREEN}mapper${RESET}         MapStruct mapper"
    echo -e "  ${CYBER_GREEN}exception-handler${RESET} Global exception handler"
    echo -e "  ${CYBER_GREEN}security${RESET}       Security configuration"
    
    echo -e "\n${CYBER_BLUE}OPTIONS:${RESET}"
    echo -e "  ${CYBER_YELLOW}-n, --name${RESET}        Component name (required)"
    echo -e "  ${CYBER_YELLOW}-p, --package${RESET}     Package name (required)"
    echo -e "  ${CYBER_YELLOW}--rest${RESET}            Generate REST controller (default: true)"
    echo -e "  ${CYBER_YELLOW}--jpa${RESET}             Add JPA support (default: true)"
    
    echo -e "\n${CYBER_BLUE}EXAMPLES:${RESET}"
    echo -e "  ${CYBER_CYAN}# Generate complete CRUD${RESET}"
    echo -e "  bytebabe spring g crud -n User -p com.example.api.user"
    
    echo -e "\n  ${CYBER_CYAN}# Generate controller only${RESET}"
    echo -e "  bytebabe spring g controller -n ProductController -p com.example.api.controller"
    
    echo -e "\n  ${CYBER_CYAN}# Generate entity with package${RESET}"
    echo -e "  bytebabe spring g entity -n Customer -p com.example.api.model"
}

# Adiciona help específico para config
show_spring_config_help() {
    show_spring_header
    
    echo -e "\n${CYBER_BLUE}CONFIG COMMAND USAGE:${RESET}"
    echo -e "  bytebabe spring config ${CYBER_YELLOW}<action> [options]${RESET}\n"
    
    echo -e "${CYBER_BLUE}Actions:${RESET}"
    echo -e "  ${CYBER_GREEN}init${RESET}                    Initialize Spring configuration"
    echo -e "  ${CYBER_GREEN}set-base${RESET} <package>      Set base package"
    echo -e "  ${CYBER_GREEN}set-default${RESET} <type> <pkg> Set default package for component type"
    echo -e "  ${CYBER_GREEN}show${RESET}                    Show current configuration\n"
    
    echo -e "${CYBER_BLUE}Examples:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring config init${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring config set-base com.example.api${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring config set-default controller web${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring config show${RESET}"
}

show_security_help() {
    show_spring_header
    
    echo -e "\n${CYBER_BLUE}SECURITY COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}audit${RESET}    Run security audits and fixes"
    echo -e "  ${CYBER_GREEN}scan${RESET}     Scan for vulnerabilities"
    echo -e "  ${CYBER_GREEN}setup${RESET}    Configure security features"
    
    echo -e "\n${CYBER_BLUE}EXAMPLES:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring security audit run${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring security scan deps${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring security setup oauth${RESET}"
}

show_monitor_help() {
    show_spring_header
    
    echo -e "\n${CYBER_BLUE}MONITORING COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}setup${RESET}    Configure monitoring tools"
    echo -e "  ${CYBER_GREEN}metrics${RESET}  Manage application metrics"
    echo -e "  ${CYBER_GREEN}logs${RESET}     Configure log management"
    echo -e "  ${CYBER_GREEN}alerts${RESET}   Manage monitoring alerts"
    
    echo -e "\n${CYBER_BLUE}EXAMPLES:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring monitor setup prometheus${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring monitor metrics enable${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring monitor alerts setup${RESET}"
}

show_deploy_help() {
    show_spring_header
    
    echo -e "\n${CYBER_BLUE}DEPLOYMENT COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}k8s${RESET}      Kubernetes deployment options"
    echo -e "  ${CYBER_GREEN}cloud${RESET}    Cloud provider deployments"
    
    echo -e "\n${CYBER_BLUE}EXAMPLES:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring deploy k8s setup${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe spring deploy cloud aws${RESET}"
}

show_spring_new_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}NEW PROJECT USAGE:${RESET}"
    echo -e "  bytebabe spring new ${CYBER_YELLOW}[-n nome] [-p pacote] [-d deps]${RESET}"
}

show_spring_template_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}TEMPLATE COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}list${RESET}   Lista templates disponíveis"
    echo -e "  ${CYBER_GREEN}add${RESET}    Adiciona um template"
}

show_spring_dependency_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}DEPENDENCY COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}list${RESET}    Lista dependências"
    echo -e "  ${CYBER_GREEN}add${RESET}     Adiciona uma dependência"
    echo -e "  ${CYBER_GREEN}remove${RESET}  Remove uma dependência"
}

show_spring_profile_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}PROFILE COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}list${RESET}         Lista profiles"
    echo -e "  ${CYBER_GREEN}create${RESET}       Cria um profile"
    echo -e "  ${CYBER_GREEN}set-active${RESET}   Define o profile ativo"
}

show_spring_run_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}RUN USAGE:${RESET}"
    echo -e "  bytebabe spring run ${CYBER_YELLOW}[argumentos do Maven]${RESET}"
}

show_spring_build_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}BUILD USAGE:${RESET}"
    echo -e "  bytebabe spring build ${CYBER_YELLOW}[argumentos do Maven]${RESET}"
}

show_spring_test_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}TEST COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}service${RESET}      Gera testes de service"
    echo -e "  ${CYBER_GREEN}controller${RESET}   Gera testes de controller"
    echo -e "  ${CYBER_GREEN}run${RESET}          Executa mvn test"
}

show_spring_clean_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}CLEAN USAGE:${RESET}"
    echo -e "  bytebabe spring clean ${CYBER_YELLOW}[argumentos do Maven]${RESET}"
}

show_spring_docs_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}DOCS COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}setup${RESET}   Configura Swagger/OpenAPI"
}

show_spring_docker_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}DOCKER COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}setup${RESET}   Gera Dockerfile e docker-compose"
    echo -e "  ${CYBER_GREEN}build${RESET}   Executa docker-compose build"
    echo -e "  ${CYBER_GREEN}up${RESET}      Sobe os containers"
    echo -e "  ${CYBER_GREEN}down${RESET}    Derruba os containers"
}

show_security_audit_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}SECURITY AUDIT COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}run${RESET}      Executa auditoria"
    echo -e "  ${CYBER_GREEN}fix${RESET}      Aplica correções"
    echo -e "  ${CYBER_GREEN}report${RESET}   Gera relatório"
}

show_security_scan_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}SECURITY SCAN COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}deps${RESET}     Escaneia dependências"
    echo -e "  ${CYBER_GREEN}code${RESET}     Escaneia código"
    echo -e "  ${CYBER_GREEN}docker${RESET}   Escaneia Dockerfile"
}

show_security_setup_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}SECURITY SETUP COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}oauth${RESET}     Configura OAuth2"
    echo -e "  ${CYBER_GREEN}jwt${RESET}       Configura JWT"
    echo -e "  ${CYBER_GREEN}keycloak${RESET}  Configura Keycloak"
}

show_monitor_setup_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}MONITOR SETUP COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}prometheus${RESET}   Configura Prometheus"
    echo -e "  ${CYBER_GREEN}grafana${RESET}      Configura Grafana"
    echo -e "  ${CYBER_GREEN}elk${RESET}          Configura ELK"
}

show_metrics_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}METRICS COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}enable${RESET}   Habilita métricas"
    echo -e "  ${CYBER_GREEN}custom${RESET}   Adiciona métrica customizada"
    echo -e "  ${CYBER_GREEN}export${RESET}   Exporta métricas"
}

show_logs_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}LOG COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}setup${RESET}     Configura agregação"
    echo -e "  ${CYBER_GREEN}analyze${RESET}   Analisa padrões"
    echo -e "  ${CYBER_GREEN}export${RESET}    Exporta logs"
}

show_alerts_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}ALERT COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}setup${RESET}   Configura regras"
    echo -e "  ${CYBER_GREEN}add${RESET}     Adiciona alerta"
    echo -e "  ${CYBER_GREEN}list${RESET}    Lista alertas"
}

show_k8s_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}KUBERNETES COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}setup${RESET}      Gera manifestos"
    echo -e "  ${CYBER_GREEN}apply${RESET}      Aplica manifestos"
    echo -e "  ${CYBER_GREEN}rollback${RESET}   Reverte deployment"
}

show_cloud_deploy_help() {
    show_spring_header
    echo -e "\n${CYBER_BLUE}CLOUD DEPLOY COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}aws${RESET}     Deploy na AWS"
    echo -e "  ${CYBER_GREEN}gcp${RESET}     Deploy na GCP"
    echo -e "  ${CYBER_GREEN}azure${RESET}   Deploy na Azure"
}
