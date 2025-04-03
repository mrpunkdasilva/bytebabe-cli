#!/bin/bash

# Import modules
source "$BASE_DIR/lib/pkg/firewall/profiles.sh"
source "$BASE_DIR/lib/pkg/firewall/ui.sh"
source "$BASE_DIR/lib/pkg/firewall/advanced.sh"

# Basic firewall operations
check_firewall_status() {
    echo -e "\n${CYBER_BLUE}▓▒░ Firewall Status ░▒▓${RESET}"
    
    if sudo ufw status verbose; then
        echo -e "${CYBER_GREEN}✓ Status retrieved successfully${RESET}"
    else
        echo -e "${CYBER_RED}✖ Failed to get firewall status${RESET}"
    fi
}

enable_firewall() {
    echo -e "\n${CYBER_BLUE}▓▒░ Enabling Firewall ░▒▓${RESET}"
    
    if sudo ufw --force enable; then
        echo -e "${CYBER_GREEN}✓ Firewall enabled successfully${RESET}"
    else
        echo -e "${CYBER_RED}✖ Failed to enable firewall${RESET}"
    fi
}

disable_firewall() {
    echo -e "\n${CYBER_BLUE}▓▒░ Disabling Firewall ░▒▓${RESET}"
    
    if sudo ufw disable; then
        echo -e "${CYBER_GREEN}✓ Firewall disabled successfully${RESET}"
    else
        echo -e "${CYBER_RED}✖ Failed to disable firewall${RESET}"
    fi
}

list_firewall_rules() {
    echo -e "\n${CYBER_BLUE}▓▒░ Active Firewall Rules ░▒▓${RESET}"
    
    if sudo ufw status numbered; then
        echo -e "${CYBER_GREEN}✓ Rules listed successfully${RESET}"
    else
        echo -e "${CYBER_RED}✖ Failed to list rules${RESET}"
    fi
}

add_firewall_rule() {
    echo -e "\n${CYBER_BLUE}▓▒░ Adding New Rule ░▒▓${RESET}"
    
    read -p "Enter port number: " port
    read -p "Enter protocol (tcp/udp): " proto
    read -p "Enter action (allow/deny): " action
    
    if sudo ufw $action $port/$proto; then
        echo -e "${CYBER_GREEN}✓ Rule added successfully${RESET}"
    else
        echo -e "${CYBER_RED}✖ Failed to add rule${RESET}"
    fi
}

remove_firewall_rule() {
    echo -e "\n${CYBER_BLUE}▓▒░ Removing Rule ░▒▓${RESET}"
    
    sudo ufw status numbered
    read -p "Enter rule number to delete: " rule_num
    
    if sudo ufw --force delete $rule_num; then
        echo -e "${CYBER_GREEN}✓ Rule removed successfully${RESET}"
    else
        echo -e "${CYBER_RED}✖ Failed to remove rule${RESET}"
    fi
}

reset_firewall_rules() {
    echo -e "\n${CYBER_BLUE}▓▒░ Resetting Firewall Rules ░▒▓${RESET}"
    echo -e "${CYBER_RED}Warning: This will remove all existing rules!${RESET}"
    read -p "Are you sure? (y/N): " confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        if sudo ufw --force reset; then
            echo -e "${CYBER_GREEN}✓ Firewall rules reset successfully${RESET}"
        else
            echo -e "${CYBER_RED}✖ Failed to reset rules${RESET}"
        fi
    else
        echo -e "${CYBER_YELLOW}Operation cancelled${RESET}"
    fi
}

setup_firewall_profile() {
    clear
    show_setup_profiles
    read -p $'\e[1;35m  ⌘ Select profile: \e[0m' profile

    case $profile in
        1) setup_developer_profile ;;
        2) setup_devops_profile ;;
        3) setup_security_profile ;;
        0) return ;;
        *)
            echo -e "${CYBER_RED}✖ Invalid profile!${RESET}"
            sleep 1
            ;;
    esac
}

run_firewall() {
    if [[ $# -gt 0 ]]; then
        process_firewall_command "$@"
        return
    fi

    while true; do
        clear
        show_firewall_menu
        read -p $'\e[1;35m  ⌘ Select an option: \e[0m' choice

        case $choice in
            1) check_firewall_status ;;
            2) enable_firewall ;;
            3) disable_firewall ;;
            4) list_firewall_rules ;;
            5) add_firewall_rule ;;
            6) remove_firewall_rule ;;
            7) reset_firewall_rules ;;
            8) setup_firewall_profile ;;
            9) show_advanced_options ;;
            0) break ;;
            *)
                echo -e "${CYBER_RED}✖ Invalid option!${RESET}"
                sleep 1
                ;;
        esac

        if [[ $choice != "0" ]]; then
            read -p $'\e[1;36m  Press ENTER to continue...\e[0m'
        fi
    done
}

show_advanced_options() {
    while true; do
        clear
        show_advanced_menu
        read -p $'\e[1;35m  ⌘ Select an option: \e[0m' choice

        case $choice in
            1) configure_rate_limiting ;;
            2) setup_port_forwarding ;;
            3) manage_logging_levels ;;
            4) block_ip_ranges ;;
            5) backup_restore_rules ;;
            6) view_active_connections ;;
            0) break ;;
            *)
                echo -e "${CYBER_RED}✖ Invalid option!${RESET}"
                sleep 1
                ;;
        esac

        if [[ $choice != "0" ]]; then
            read -p $'\e[1;36m  Press ENTER to continue...\e[0m'
        fi
    done
}

process_firewall_command() {
    case $1 in
        status) check_firewall_status ;;
        enable) enable_firewall ;;
        disable) disable_firewall ;;
        list) list_firewall_rules ;;
        add) shift; add_firewall_rule "$@" ;;
        remove) shift; remove_firewall_rule "$@" ;;
        reset) reset_firewall_rules ;;
        setup) setup_firewall_profile ;;
        help|--help|-h) show_firewall_help ;;
        "") show_firewall_help ;;
        *) 
            echo -e "${CYBER_RED}✖ Invalid command: $1${RESET}"
            echo -e "${CYBER_YELLOW}Use 'bytebabe firewall help' for usage information${RESET}"
            ;;
    esac
}

show_firewall_help() {
    echo -e "${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                     FIREWALL COMMANDER                      ${CYBER_PURPLE}║${RESET}"
    echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYBER_BLUE}USAGE:${RESET}"
    echo -e "  bytebabe firewall ${CYBER_YELLOW}[command] [options]${RESET}"
    echo
    echo -e "${CYBER_BLUE}COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}status${RESET}    Exibe o status atual do firewall"
    echo -e "  ${CYBER_GREEN}enable${RESET}    Ativa o firewall com configurações padrão"
    echo -e "  ${CYBER_GREEN}disable${RESET}   Desativa o firewall (use com cautela)"
    echo -e "  ${CYBER_GREEN}list${RESET}      Lista todas as regras ativas"
    echo -e "  ${CYBER_GREEN}add${RESET}       Adiciona uma nova regra ao firewall"
    echo -e "  ${CYBER_GREEN}remove${RESET}    Remove uma regra existente"
    echo -e "  ${CYBER_GREEN}reset${RESET}     Reseta todas as regras para padrão"
    echo -e "  ${CYBER_GREEN}setup${RESET}     Configura perfis predefinidos"
    echo
    echo -e "${CYBER_BLUE}PROFILES:${RESET}"
    echo -e "  ${CYBER_CYAN}Developer${RESET}  - Portas comuns para desenvolvimento (80, 3000-3999, 8000-8999)"
    echo -e "  ${CYBER_CYAN}DevOps${RESET}     - Configuração para ambientes DevOps (SSH, Docker, K8s)"
    echo -e "  ${CYBER_CYAN}Security${RESET}   - Perfil restritivo com regras de segurança avançadas"
    echo
    echo -e "${CYBER_BLUE}EXAMPLES:${RESET}"
    echo -e "  ${CYBER_YELLOW}# Ativar firewall${RESET}"
    echo -e "  bytebabe firewall enable"
    echo
    echo -e "  ${CYBER_YELLOW}# Adicionar regra para SSH${RESET}"
    echo -e "  bytebabe firewall add"
    echo -e "  > Enter port number: 22"
    echo -e "  > Enter protocol: tcp"
    echo -e "  > Enter action: allow"
    echo
    echo -e "  ${CYBER_YELLOW}# Configurar perfil de desenvolvedor${RESET}"
    echo -e "  bytebabe firewall setup"
    echo -e "  > Select profile: 1"
    echo
    echo -e "${CYBER_BLUE}ADVANCED OPTIONS:${RESET}"
    echo -e "  ${CYBER_MAGENTA}• Rate Limiting${RESET}         - Controle de taxa de conexões"
    echo -e "  ${CYBER_MAGENTA}• Port Forwarding${RESET}      - Redirecionamento de portas"
    echo -e "  ${CYBER_MAGENTA}• Logging Levels${RESET}       - Configuração de logs"
    echo -e "  ${CYBER_MAGENTA}• IP Range Blocking${RESET}    - Bloqueio de ranges de IP"
    echo -e "  ${CYBER_MAGENTA}• Backup/Restore${RESET}       - Backup e restauração de regras"
    echo -e "  ${CYBER_MAGENTA}• Connection Monitor${RESET}   - Monitoramento de conexões ativas"
    echo
    echo -e "${CYBER_RED}SECURITY NOTE:${RESET}"
    echo -e "  Algumas operações requerem privilégios sudo."
    echo -e "  Use com cautela, especialmente em ambientes de produção."
    echo
    echo -e "${CYBER_PURPLE}╭─────────────────────────────────────────────────────────────╮${RESET}"
    echo -e "${CYBER_PURPLE}│${RESET} Para mais informações, visite:                              ${CYBER_PURPLE}│${RESET}"
    echo -e "${CYBER_PURPLE}│${RESET} ${CYBER_CYAN}https://github.com/mrpunkdasilva/bytebabe/wiki/firewall${RESET}    ${CYBER_PURPLE}│${RESET}"
    echo -e "${CYBER_PURPLE}╰─────────────────────────────────────────────────────────────╯${RESET}"
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_firewall "$@"
fi
