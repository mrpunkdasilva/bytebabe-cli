#!/bin/bash

show_generator_help() {
    local generator_type="$1"

    show_spring_header
    
    case "$generator_type" in
        "controller")
            echo -e "\n${CYBER_BLUE}Controller Generator Usage:${RESET}"
            echo -e "  bytebabe spring g controller ${CYBER_YELLOW}[options]${RESET}\n"
            
            echo -e "${CYBER_BLUE}Options:${RESET}"
            echo -e "  ${CYBER_GREEN}-n, --name${RESET}     Controller name (required)"
            echo -e "  ${CYBER_GREEN}-p, --package${RESET}  Package name (required)"
            echo -e "  ${CYBER_GREEN}--no-rest${RESET}      Generate a regular @Controller instead of @RestController\n"
            
            echo -e "${CYBER_BLUE}Examples:${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g controller -n UserController -p com.example.api.controller${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g controller -n ProductController -p com.example.api.product --no-rest${RESET}"
            ;;
            
        "service")
            echo -e "\n${CYBER_BLUE}Service Generator Usage:${RESET}"
            echo -e "  bytebabe spring g service ${CYBER_YELLOW}[options]${RESET}\n"
            
            echo -e "${CYBER_BLUE}Options:${RESET}"
            echo -e "  ${CYBER_GREEN}-n, --name${RESET}     Service name (required)"
            echo -e "  ${CYBER_GREEN}-p, --package${RESET}  Package name (required)\n"
            
            echo -e "${CYBER_BLUE}Examples:${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g service -n UserService -p com.example.api.service${RESET}"
            ;;
            
        "repository")
            echo -e "\n${CYBER_BLUE}Repository Generator Usage:${RESET}"
            echo -e "  bytebabe spring g repository ${CYBER_YELLOW}[options]${RESET}\n"
            
            echo -e "${CYBER_BLUE}Options:${RESET}"
            echo -e "  ${CYBER_GREEN}-n, --name${RESET}     Repository name (required)"
            echo -e "  ${CYBER_GREEN}-p, --package${RESET}  Package name (required)"
            echo -e "  ${CYBER_GREEN}-e, --entity${RESET}   Entity name (optional)\n"
            
            echo -e "${CYBER_BLUE}Examples:${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g repository -n UserRepository -p com.example.api.repository${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g repository -n ProductRepo -p com.example.api.repo -e Product${RESET}"
            ;;
            
        "entity")
            echo -e "\n${CYBER_BLUE}Entity Generator Usage:${RESET}"
            echo -e "  bytebabe spring g entity ${CYBER_YELLOW}[options]${RESET}\n"
            
            echo -e "${CYBER_BLUE}Options:${RESET}"
            echo -e "  ${CYBER_GREEN}-n, --name${RESET}     Entity name (required)"
            echo -e "  ${CYBER_GREEN}-p, --package${RESET}  Package name (required)"
            echo -e "  ${CYBER_GREEN}-t, --table${RESET}    Table name (optional)\n"
            
            echo -e "${CYBER_BLUE}Examples:${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g entity -n User -p com.example.api.model${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g entity -n Product -p com.example.api.model -t tbl_products${RESET}"
            ;;
            
        "dto")
            echo -e "\n${CYBER_BLUE}DTO Generator Usage:${RESET}"
            echo -e "  bytebabe spring g dto ${CYBER_YELLOW}[options]${RESET}\n"
            
            echo -e "${CYBER_BLUE}Options:${RESET}"
            echo -e "  ${CYBER_GREEN}-n, --name${RESET}     DTO name (required)"
            echo -e "  ${CYBER_GREEN}-p, --package${RESET}  Package name (required)"
            echo -e "  ${CYBER_GREEN}-e, --entity${RESET}   Entity name for mapping (optional)\n"
            
            echo -e "${CYBER_BLUE}Examples:${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g dto -n UserDTO -p com.example.api.dto${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g dto -n ProductDTO -p com.example.api.dto -e Product${RESET}"
            ;;
            
        "crud")
            echo -e "\n${CYBER_BLUE}CRUD Generator Usage:${RESET}"
            echo -e "  bytebabe spring g crud ${CYBER_YELLOW}[options]${RESET}\n"
            
            echo -e "${CYBER_BLUE}Options:${RESET}"
            echo -e "  ${CYBER_GREEN}-n, --name${RESET}     Base name for all components (required)"
            echo -e "  ${CYBER_GREEN}-p, --package${RESET}  Base package name (required)"
            echo -e "  ${CYBER_GREEN}-t, --table${RESET}    Table name (optional)\n"
            
            echo -e "${CYBER_BLUE}Generated Structure:${RESET}"
            echo -e "  ${CYBER_CYAN}├─ model/Entity.java${RESET}"
            echo -e "  ${CYBER_CYAN}├─ dto/EntityDTO.java${RESET}"
            echo -e "  ${CYBER_CYAN}├─ repository/EntityRepository.java${RESET}"
            echo -e "  ${CYBER_CYAN}├─ service/EntityService.java${RESET}"
            echo -e "  ${CYBER_CYAN}└─ controller/EntityController.java${RESET}\n"
            
            echo -e "${CYBER_BLUE}Examples:${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g crud -n User -p com.example.api${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g crud -n Product -p com.example.api.product -t tbl_products${RESET}"
            ;;
            
        *)
            echo -e "\n${CYBER_BLUE}Spring Generator Help:${RESET}"
            echo -e "  bytebabe spring g ${CYBER_YELLOW}<type> [options]${RESET}\n"
            
            echo -e "${CYBER_BLUE}Available Types:${RESET}"
            echo -e "  ${CYBER_GREEN}controller${RESET}   Generate REST controller"
            echo -e "  ${CYBER_GREEN}service${RESET}      Generate service class"
            echo -e "  ${CYBER_GREEN}repository${RESET}   Generate JPA repository"
            echo -e "  ${CYBER_GREEN}entity${RESET}       Generate JPA entity"
            echo -e "  ${CYBER_GREEN}dto${RESET}          Generate DTO class"
            echo -e "  ${CYBER_GREEN}crud${RESET}         Generate complete CRUD\n"
            
            echo -e "${CYBER_BLUE}For detailed help on each type:${RESET}"
            echo -e "  ${CYBER_YELLOW}bytebabe spring g <type> --help${RESET}"
            ;;
    esac
}