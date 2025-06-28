#!/bin/bash

# Import modules
source "$BASE_DIR/lib/pkg/firewall/profiles.sh"
source "$BASE_DIR/lib/pkg/firewall/ui.sh"
source "$BASE_DIR/lib/pkg/firewall/advanced.sh"

# Universal firewall detection and installation
detect_and_install_firewall() {
    echo -e "\n${CYBER_BLUE}▓▒░ Detecting Firewall System ░▒▓${RESET}"
    
    # Detect OS
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    echo -e "${CYBER_YELLOW}Detected OS: $OS $VER${RESET}"
    
    # Check for existing firewalls
    local firewall_installed=false
    local firewall_type=""
    
    # Check UFW
    if command -v ufw &> /dev/null; then
        firewall_installed=true
        firewall_type="ufw"
        echo -e "${CYBER_GREEN}✓ UFW firewall detected${RESET}"
    # Check firewalld (Fedora/RHEL/CentOS)
    elif command -v firewall-cmd &> /dev/null; then
        firewall_installed=true
        firewall_type="firewalld"
        echo -e "${CYBER_GREEN}✓ firewalld detected${RESET}"
    # Check iptables
    elif command -v iptables &> /dev/null; then
        firewall_installed=true
        firewall_type="iptables"
        echo -e "${CYBER_GREEN}✓ iptables detected${RESET}"
    # Check nftables
    elif command -v nft &> /dev/null; then
        firewall_installed=true
        firewall_type="nftables"
        echo -e "${CYBER_GREEN}✓ nftables detected${RESET}"
    fi
    
    if [[ "$firewall_installed" == false ]]; then
        echo -e "${CYBER_RED}✖ No firewall detected${RESET}"
        echo -e "${CYBER_YELLOW}Installing appropriate firewall...${RESET}"
        
        # Install firewall based on OS
        case $OS in
            *"Fedora"*|*"Red Hat"*|*"CentOS"*|*"Rocky"*|*"AlmaLinux"*)
                install_firewalld
                firewall_type="firewalld"
                ;;
            *"Ubuntu"*|*"Debian"*|*"Linux Mint"*)
                install_ufw
                firewall_type="ufw"
                ;;
            *"Arch"*|*"Manjaro"*)
                install_ufw
                firewall_type="ufw"
                ;;
            *"openSUSE"*|*"SUSE"*)
                install_firewalld
                firewall_type="firewalld"
                ;;
            *)
                # Default to UFW for unknown distributions
                install_ufw
                firewall_type="ufw"
                ;;
        esac
    fi
    
    # Export firewall type for other functions
    export FIREWALL_TYPE=$firewall_type
    echo -e "${CYBER_GREEN}✓ Using firewall: $firewall_type${RESET}"
}

install_ufw() {
    echo -e "\n${CYBER_BLUE}▓▒░ Installing UFW Firewall ░▒▓${RESET}"
    
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y ufw
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y ufw
    elif command -v yum &> /dev/null; then
        sudo yum install -y ufw
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm ufw
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y ufw
    else
        echo -e "${CYBER_RED}✖ Could not install UFW - no supported package manager found${RESET}"
        return 1
    fi
    
    if command -v ufw &> /dev/null; then
        echo -e "${CYBER_GREEN}✓ UFW installed successfully${RESET}"
        sudo ufw --force enable
        echo -e "${CYBER_GREEN}✓ UFW enabled${RESET}"
    else
        echo -e "${CYBER_RED}✖ Failed to install UFW${RESET}"
        return 1
    fi
}

install_firewalld() {
    echo -e "\n${CYBER_BLUE}▓▒░ Installing firewalld ░▒▓${RESET}"
    
    if command -v dnf &> /dev/null; then
        sudo dnf install -y firewalld
    elif command -v yum &> /dev/null; then
        sudo yum install -y firewalld
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y firewalld
    else
        echo -e "${CYBER_RED}✖ Could not install firewalld - no supported package manager found${RESET}"
        return 1
    fi
    
    if command -v firewall-cmd &> /dev/null; then
        echo -e "${CYBER_GREEN}✓ firewalld installed successfully${RESET}"
        sudo systemctl enable firewalld
        sudo systemctl start firewalld
        echo -e "${CYBER_GREEN}✓ firewalld enabled and started${RESET}"
    else
        echo -e "${CYBER_RED}✖ Failed to install firewalld${RESET}"
        return 1
    fi
}

# Universal firewall status check
check_firewall_status() {
    echo -e "\n${CYBER_BLUE}▓▒░ Firewall Status ░▒▓${RESET}"
    
    # Detect firewall if not already done
    if [[ -z "$FIREWALL_TYPE" ]]; then
        detect_and_install_firewall
    fi
    
    case $FIREWALL_TYPE in
        "ufw")
            echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
            echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                    UFW FIREWALL STATUS                    ${CYBER_PURPLE}║${RESET}"
            echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
            
            if sudo ufw status verbose; then
                echo -e "\n${CYBER_GREEN}▓▒░ ✓ UFW Status: ACTIVE ░▒▓${RESET}"
            else
                echo -e "\n${CYBER_RED}▓▒░ ✖ UFW Status: INACTIVE ░▒▓${RESET}"
            fi
            ;;
        "firewalld")
            echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
            echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                  FIREWALLD STATUS PANEL                  ${CYBER_PURPLE}║${RESET}"
            echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
            
            if sudo firewall-cmd --state; then
                echo -e "\n${CYBER_GREEN}▓▒░ ✓ FIREWALLD: RUNNING ░▒▓${RESET}"
                
                # Get active zone info
                local active_zone=$(sudo firewall-cmd --get-active-zones | head -n1 | cut -d' ' -f1)
                echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════╗${RESET}"
                echo -e "${CYBER_BLUE}║${CYBER_CYAN}                    ACTIVE ZONE: $active_zone${CYBER_BLUE}                    ║${RESET}"
                echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════╝${RESET}"
                
                # Display services
                echo -e "\n${CYBER_YELLOW}▓▒░ ACTIVE SERVICES ░▒▓${RESET}"
                sudo firewall-cmd --list-services | tr ' ' '\n' | while read service; do
                    if [[ -n "$service" ]]; then
                        echo -e "  ${CYBER_GREEN}►${RESET} $service"
                    fi
                done
                
                # Display ports
                echo -e "\n${CYBER_YELLOW}▓▒░ OPEN PORTS ░▒▓${RESET}"
                sudo firewall-cmd --list-ports | tr ' ' '\n' | while read port; do
                    if [[ -n "$port" ]]; then
                        echo -e "  ${CYBER_BLUE}►${RESET} $port"
                    fi
                done
                
                # Display interfaces
                echo -e "\n${CYBER_YELLOW}▓▒░ NETWORK INTERFACES ░▒▓${RESET}"
                sudo firewall-cmd --list-interfaces | tr ' ' '\n' | while read interface; do
                    if [[ -n "$interface" ]]; then
                        echo -e "  ${CYBER_MAGENTA}►${RESET} $interface"
                    fi
                done
                
                echo -e "\n${CYBER_GREEN}▓▒░ ✓ FIREWALLD OPERATIONAL ░▒▓${RESET}"
            else
                echo -e "\n${CYBER_RED}▓▒░ ✖ FIREWALLD: STOPPED ░▒▓${RESET}"
            fi
            ;;
        "iptables")
            echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
            echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                   IPTABLES STATUS PANEL                   ${CYBER_PURPLE}║${RESET}"
            echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
            
            if sudo iptables -L -v -n; then
                echo -e "\n${CYBER_GREEN}▓▒░ ✓ IPTABLES: ACTIVE ░▒▓${RESET}"
            else
                echo -e "\n${CYBER_RED}▓▒░ ✖ IPTABLES: INACTIVE ░▒▓${RESET}"
            fi
            ;;
        "nftables")
            echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
            echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                   NFTABLES STATUS PANEL                   ${CYBER_PURPLE}║${RESET}"
            echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
            
            if sudo nft list ruleset; then
                echo -e "\n${CYBER_GREEN}▓▒░ ✓ NFTABLES: ACTIVE ░▒▓${RESET}"
            else
                echo -e "\n${CYBER_RED}▓▒░ ✖ NFTABLES: INACTIVE ░▒▓${RESET}"
            fi
            ;;
        *)
            echo -e "\n${CYBER_RED}▓▒░ ✖ UNKNOWN FIREWALL TYPE: $FIREWALL_TYPE ░▒▓${RESET}"
            ;;
    esac
    
    echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                    SECURITY STATUS COMPLETE                    ${CYBER_PURPLE}║${RESET}"
    echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
}

enable_firewall() {
    echo -e "\n${CYBER_BLUE}▓▒░ Enabling Firewall ░▒▓${RESET}"
    
    # Detect firewall if not already done
    if [[ -z "$FIREWALL_TYPE" ]]; then
        detect_and_install_firewall
    fi
    
    case $FIREWALL_TYPE in
        "ufw")
            if sudo ufw --force enable; then
                echo -e "${CYBER_GREEN}✓ UFW firewall enabled successfully${RESET}"
            else
                echo -e "${CYBER_RED}✖ Failed to enable UFW firewall${RESET}"
            fi
            ;;
        "firewalld")
            if sudo systemctl start firewalld && sudo systemctl enable firewalld; then
                echo -e "${CYBER_GREEN}✓ firewalld enabled and started successfully${RESET}"
            else
                echo -e "${CYBER_RED}✖ Failed to enable firewalld${RESET}"
            fi
            ;;
        "iptables")
            echo -e "${CYBER_YELLOW}⚠ iptables requires manual configuration${RESET}"
            echo -e "${CYBER_YELLOW}Consider using UFW or firewalld for easier management${RESET}"
            ;;
        "nftables")
            echo -e "${CYBER_YELLOW}⚠ nftables requires manual configuration${RESET}"
            echo -e "${CYBER_YELLOW}Consider using UFW or firewalld for easier management${RESET}"
            ;;
        *)
            echo -e "${CYBER_RED}✖ Unknown firewall type: $FIREWALL_TYPE${RESET}"
            ;;
    esac
}

disable_firewall() {
    echo -e "\n${CYBER_BLUE}▓▒░ Disabling Firewall ░▒▓${RESET}"
    
    # Detect firewall if not already done
    if [[ -z "$FIREWALL_TYPE" ]]; then
        detect_and_install_firewall
    fi
    
    case $FIREWALL_TYPE in
        "ufw")
            if sudo ufw disable; then
                echo -e "${CYBER_GREEN}✓ UFW firewall disabled successfully${RESET}"
            else
                echo -e "${CYBER_RED}✖ Failed to disable UFW firewall${RESET}"
            fi
            ;;
        "firewalld")
            if sudo systemctl stop firewalld && sudo systemctl disable firewalld; then
                echo -e "${CYBER_GREEN}✓ firewalld disabled and stopped successfully${RESET}"
            else
                echo -e "${CYBER_RED}✖ Failed to disable firewalld${RESET}"
            fi
            ;;
        "iptables")
            echo -e "${CYBER_YELLOW}⚠ iptables requires manual configuration${RESET}"
            echo -e "${CYBER_YELLOW}Use 'sudo iptables -F' to flush rules${RESET}"
            ;;
        "nftables")
            echo -e "${CYBER_YELLOW}⚠ nftables requires manual configuration${RESET}"
            echo -e "${CYBER_YELLOW}Use 'sudo nft flush ruleset' to flush rules${RESET}"
            ;;
        *)
            echo -e "${CYBER_RED}✖ Unknown firewall type: $FIREWALL_TYPE${RESET}"
            ;;
    esac
}

list_firewall_rules() {
    echo -e "\n${CYBER_BLUE}▓▒░ Active Firewall Rules ░▒▓${RESET}"
    
    # Detect firewall if not already done
    if [[ -z "$FIREWALL_TYPE" ]]; then
        detect_and_install_firewall
    fi
    
    case $FIREWALL_TYPE in
        "ufw")
            if sudo ufw status numbered; then
                echo -e "${CYBER_GREEN}✓ UFW rules listed successfully${RESET}"
            else
                echo -e "${CYBER_RED}✖ Failed to list UFW rules${RESET}"
            fi
            ;;
        "firewalld")
            echo -e "${CYBER_YELLOW}Firewalld Zones:${RESET}"
            sudo firewall-cmd --list-all-zones
            echo -e "\n${CYBER_YELLOW}Active Zone:${RESET}"
            sudo firewall-cmd --list-all
            ;;
        "iptables")
            echo -e "${CYBER_YELLOW}iptables Rules:${RESET}"
            sudo iptables -L -v -n --line-numbers
            ;;
        "nftables")
            echo -e "${CYBER_YELLOW}nftables Rules:${RESET}"
            sudo nft list ruleset
            ;;
        *)
            echo -e "${CYBER_RED}✖ Unknown firewall type: $FIREWALL_TYPE${RESET}"
            ;;
    esac
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
            1) detect_and_install_firewall ;;
            2) check_firewall_status ;;
            3) enable_firewall ;;
            4) disable_firewall ;;
            5) list_firewall_rules ;;
            6) add_firewall_rule ;;
            7) remove_firewall_rule ;;
            8) reset_firewall_rules ;;
            9) setup_firewall_profile ;;
            10) show_advanced_options ;;
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
        install) detect_and_install_firewall ;;
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
    echo -e "  ${CYBER_GREEN}install${RESET}  Detecta e instala firewall apropriado para o sistema"
    echo -e "  ${CYBER_GREEN}status${RESET}   Exibe o status atual do firewall"
    echo -e "  ${CYBER_GREEN}enable${RESET}   Ativa o firewall com configurações padrão"
    echo -e "  ${CYBER_GREEN}disable${RESET}  Desativa o firewall (use com cautela)"
    echo -e "  ${CYBER_GREEN}list${RESET}     Lista todas as regras ativas"
    echo -e "  ${CYBER_GREEN}add${RESET}      Adiciona uma nova regra ao firewall"
    echo -e "  ${CYBER_GREEN}remove${RESET}   Remove uma regra existente"
    echo -e "  ${CYBER_GREEN}reset${RESET}    Reseta todas as regras para padrão"
    echo -e "  ${CYBER_GREEN}setup${RESET}    Configura perfis predefinidos"
    echo
    echo -e "${CYBER_BLUE}SUPPORTED FIREWALLS:${RESET}"
    echo -e "  ${CYBER_CYAN}• UFW${RESET}        - Ubuntu, Debian, Arch Linux"
    echo -e "  ${CYBER_CYAN}• firewalld${RESET}  - Fedora, RHEL, CentOS, openSUSE"
    echo -e "  ${CYBER_CYAN}• iptables${RESET}   - Sistemas legados"
    echo -e "  ${CYBER_CYAN}• nftables${RESET}   - Sistemas modernos"
    echo
    echo -e "${CYBER_BLUE}PROFILES:${RESET}"
    echo -e "  ${CYBER_CYAN}Developer${RESET}  - Portas comuns para desenvolvimento (80, 3000-3999, 8000-8999)"
    echo -e "  ${CYBER_CYAN}DevOps${RESET}     - Configuração para ambientes DevOps (SSH, Docker, K8s)"
    echo -e "  ${CYBER_CYAN}Security${RESET}   - Perfil restritivo com regras de segurança avançadas"
    echo
    echo -e "${CYBER_BLUE}EXAMPLES:${RESET}"
    echo -e "  ${CYBER_YELLOW}# Instalar firewall automaticamente${RESET}"
    echo -e "  bytebabe firewall install"
    echo
    echo -e "  ${CYBER_YELLOW}# Verificar status${RESET}"
    echo -e "  bytebabe firewall status"
    echo
    echo -e "  ${CYBER_YELLOW}# Ativar firewall${RESET}"
    echo -e "  bytebabe firewall enable"
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
