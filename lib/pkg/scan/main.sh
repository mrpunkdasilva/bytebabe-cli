#!/bin/bash

# Importa cores e helpers
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"

# Configurações
SCAN_LOG_DIR="/var/log/bytebabe/scans"
SCAN_REPORT_DIR="/var/log/bytebabe/reports"
DEEP_SCAN=false
QUICK_SCAN=false
GENERATE_REPORT=false

# Verifica e cria diretórios necessários
setup_scan_environment() {
    sudo mkdir -p "$SCAN_LOG_DIR" "$SCAN_REPORT_DIR"
    sudo chmod 755 "$SCAN_LOG_DIR" "$SCAN_REPORT_DIR"
}

# Função para mostrar spinner durante processos
show_progress_spinner() {
    local pid=$1
    local message=$2
    local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
    local i=0
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) %8 ))
        printf "\r${CYBER_YELLOW}» %s... ${CYBER_BLUE}${spin:$i:1}${RESET}" "$message"
        sleep 0.1
    done
    printf "\r${CYBER_GREEN}✓ %s... Completed${RESET}\n" "$message"
}

# Função para gerar relatório
generate_scan_report() {
    local scan_type=$1
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local report_file="${SCAN_REPORT_DIR}/${scan_type}_scan_${timestamp}.report"
    
    {
        echo "═══════════════════════════════════════════"
        echo "ByteBabe Security Scan Report"
        echo "═══════════════════════════════════════════"
        echo "Scan Type: $scan_type"
        echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "System: $(uname -a)"
        echo "═══════════════════════════════════════════"
        echo
        cat "$SCAN_LOG_DIR/temp_${scan_type}.log"
    } > "$report_file"
    
    echo -e "\n${CYBER_GREEN}Report generated: $report_file${RESET}"
}

# Função para mostrar o menu de ajuda
show_scan_help() {
    show_header_custom "THREAT ASSESSMENT SCAN" "🔍" "${CYBER_YELLOW}"
    
    echo -e "${CYBER_BLUE}USAGE:${NC}"
    echo -e "  prime scan ${CYBER_YELLOW}<command>${NC} [options]"
    echo
    
    echo -e "${CYBER_BLUE}COMMANDS:${NC}"
    echo -e "  ${CYBER_GREEN}system${NC}     Complete system scan"
    echo -e "  ${CYBER_GREEN}security${NC}   Security analysis"
    echo -e "  ${CYBER_GREEN}ports${NC}      Port scanning"
    echo -e "  ${CYBER_GREEN}malware${NC}    Malware detection"
    echo -e "  ${CYBER_GREEN}updates${NC}    Check for updates"
    echo -e "  ${CYBER_GREEN}network${NC}    Network security scan"
    echo -e "  ${CYBER_GREEN}firewall${NC}   Firewall analysis"
    echo -e "  ${CYBER_GREEN}services${NC}   Running services check"
    echo
    
    echo -e "${CYBER_BLUE}OPTIONS:${NC}"
    echo -e "  ${CYBER_YELLOW}--deep${NC}       Perform deep scan"
    echo -e "  ${CYBER_YELLOW}--quick${NC}      Quick scan mode"
    echo -e "  ${CYBER_YELLOW}--report${NC}     Generate detailed report"
    echo -e "  ${CYBER_YELLOW}--monitor${NC}    Continuous monitoring"
    echo -e "  ${CYBER_YELLOW}--verbose${NC}    Show detailed output"
    echo
    
    echo -e "${CYBER_BLUE}EXAMPLES:${NC}"
    echo -e "  ${CYBER_YELLOW}prime scan system --deep --report${NC}"
    echo -e "  ${CYBER_YELLOW}prime scan security --monitor${NC}"
    echo -e "  ${CYBER_YELLOW}prime scan network --verbose${NC}"
}

# Função para scan do sistema
run_system_scan() {
    local log_file="$SCAN_LOG_DIR/temp_system.log"
    
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║ ${CYBER_GREEN}INITIATING SYSTEM SCAN ${CYBER_BLUE}                                           ║${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
    
    {
        # CPU Info
        echo -e "\n=== CPU Information ==="
        lscpu | grep -E "Model name|Architecture|CPU\(s\)|Thread|Core"
        
        # Memory Analysis
        echo -e "\n=== Memory Status ==="
        free -h
        vmstat 1 5
        
        # Disk Usage
        echo -e "\n=== Disk Usage ==="
        df -h | grep -v "tmpfs" | grep -v "udev"
        
        # I/O Stats
        echo -e "\n=== I/O Statistics ==="
        iostat -x 1 5
        
        # System Load
        echo -e "\n=== System Load ==="
        uptime
        
        if [ "$DEEP_SCAN" = true ]; then
            # SMART Status for all disks
            echo -e "\n=== SMART Disk Health ==="
            for disk in $(lsblk -d -o name | grep -v "name"); do
                echo "Checking /dev/$disk..."
                sudo smartctl -H "/dev/$disk" 2>/dev/null
            done
            
            # System Logs Analysis
            echo -e "\n=== System Logs Analysis ==="
            sudo journalctl --no-pager -p err..alert -n 50
        fi
        
    } | tee "$log_file"
    
    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    
    [ "$GENERATE_REPORT" = true ] && generate_scan_report "system"
}

# Função para scan de segurança
run_security_scan() {
    local log_file="$SCAN_LOG_DIR/temp_security.log"
    
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║ ${CYBER_RED}SECURITY ANALYSIS IN PROGRESS ${CYBER_BLUE}                                    ║${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
    
    {
        # Failed Login Attempts
        echo -e "\n=== Failed Login Attempts ==="
        sudo grep "Failed password" /var/log/auth.log | tail -n 10
        
        # Active SSH Sessions
        echo -e "\n=== Active SSH Sessions ==="
        who
        
        # List all SUID files
        echo -e "\n=== SUID Files ==="
        sudo find / -type f -perm -4000 2>/dev/null
        
        # Check for rootkits
        echo -e "\n=== Rootkit Check ==="
        if command -v rkhunter &> /dev/null; then
            sudo rkhunter --check --skip-keypress
        else
            echo "rkhunter not installed"
        fi
        
        # System Integrity Check
        if [ "$DEEP_SCAN" = true ]; then
            echo -e "\n=== System Integrity Check ==="
            if command -v aide &> /dev/null; then
                sudo aide --check
            else
                echo "AIDE not installed"
            fi
            
            # Comprehensive Security Audit
            if command -v lynis &> /dev/null; then
                echo -e "\n=== Security Audit ==="
                sudo lynis audit system
            fi
        fi
        
    } | tee "$log_file"
    
    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    
    [ "$GENERATE_REPORT" = true ] && generate_scan_report "security"
}

# Função para scan de portas
run_port_scan() {
    local log_file="$SCAN_LOG_DIR/temp_ports.log"
    
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║ ${CYBER_PURPLE}PORT SCANNING INITIATED ${CYBER_BLUE}                                        ║${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
    
    {
        # Local Open Ports
        echo -e "\n=== Local Open Ports ==="
        sudo netstat -tuln
        
        # Active Connections
        echo -e "\n=== Active Connections ==="
        sudo netstat -tupn
        
        if command -v nmap &> /dev/null; then
            read -p $'\033[38;5;227m»» Enter target (default: localhost): \033[0m' target
            target=${target:-localhost}
            
            echo -e "\n=== Nmap Scan Results ==="
            if [ "$DEEP_SCAN" = true ]; then
                sudo nmap -sS -sV -O -A "$target"
            else
                sudo nmap -sS -sV "$target"
            fi
        else
            echo "nmap not installed"
        fi
        
    } | tee "$log_file"
    
    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    
    [ "$GENERATE_REPORT" = true ] && generate_scan_report "ports"
}

# Função para detecção de malware
run_malware_scan() {
    local log_file="$SCAN_LOG_DIR/temp_malware.log"
    
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║ ${CYBER_RED}MALWARE DETECTION ACTIVE ${CYBER_BLUE}                                        ║${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
    
    {
        if command -v clamav &> /dev/null; then
            echo -e "\n=== Updating Virus Definitions ==="
            sudo freshclam
            
            echo -e "\n=== ClamAV Scan Results ==="
            if [ "$DEEP_SCAN" = true ]; then
                sudo clamscan --recursive --infected --detect-pua=yes /
            else
                sudo clamscan --recursive --infected /home
            fi
        else
            echo "ClamAV not installed"
        fi
        
        # Check for suspicious processes
        echo -e "\n=== Suspicious Processes ==="
        ps aux | grep -i "suspicious\|malware\|virus"
        
        # Check for unusual network connections
        echo -e "\n=== Unusual Network Connections ==="
        sudo netstat -tupn | grep ESTABLISHED
        
    } | tee "$log_file"
    
    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    
    [ "$GENERATE_REPORT" = true ] && generate_scan_report "malware"
}

# Função para verificar atualizações
run_updates_scan() {
    local log_file="$SCAN_LOG_DIR/temp_updates.log"
    
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║ ${CYBER_GREEN}UPDATE SCAN INITIATED ${CYBER_BLUE}                                          ║${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
    
    {
        # System Updates
        echo -e "\n=== Available System Updates ==="
        sudo apt update
        apt list --upgradable
        
        # Security Updates
        echo -e "\n=== Security Updates ==="
        sudo unattended-upgrade --dry-run
        
        if [ "$DEEP_SCAN" = true ]; then
            # Check Package Integrity
            echo -e "\n=== Package Integrity Check ==="
            sudo debsums -c
            
            # Check for deprecated packages
            echo -e "\n=== Deprecated Packages ==="
            apt list '~o'
        fi
        
    } | tee "$log_file"
    
    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    
    [ "$GENERATE_REPORT" = true ] && generate_scan_report "updates"
}

# Função para scan de rede
run_network_scan() {
    local log_file="$SCAN_LOG_DIR/temp_network.log"
    
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║ ${CYBER_PURPLE}NETWORK SCAN INITIATED ${CYBER_BLUE}                                        ║${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
    
    {
        # Network Interfaces
        echo -e "\n=== Network Interfaces ==="
        ip addr show
        
        # Routing Table
        echo -e "\n=== Routing Table ==="
        ip route
        
        # DNS Resolution
        echo -e "\n=== DNS Resolution ==="
        cat /etc/resolv.conf
        
        # Network Statistics
        echo -e "\n=== Network Statistics ==="
        netstat -s
        
        if [ "$DEEP_SCAN" = true ]; then
            # Detailed Interface Statistics
            echo -e "\n=== Interface Statistics ==="
            for interface in $(ip -o link show | awk -F': ' '{print $2}'); do
                echo "=== $interface ==="
                ethtool "$interface" 2>/dev/null
            done
            
            # Network Load
            echo -e "\n=== Network Load ==="
            iftop -t -s 5 2>/dev/null
        fi
        
    } | tee "$log_file"
    
    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    
    [ "$GENERATE_REPORT" = true ] && generate_scan_report "network"
}

# Função para análise de firewall
run_firewall_scan() {
    local log_file="$SCAN_LOG_DIR/temp_firewall.log"
    
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║ ${CYBER_RED}FIREWALL ANALYSIS ACTIVE ${CYBER_BLUE}                                        ║${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
    
    {
        # UFW Status
        echo -e "\n=== UFW Status ==="
        sudo ufw status verbose
        
        # IPTables Rules
        echo -e "\n=== IPTables Rules ==="
        sudo iptables -L -v -n
        
        if [ "$DEEP_SCAN" = true ]; then
            # NAT Rules
            echo -e "\n=== NAT Rules ==="
            sudo iptables -t nat -L -v -n
            
            # Custom Chains
            echo -e "\n=== Custom Chains ==="
            sudo iptables -L -v -n | grep "Chain" | grep -v "INPUT\|OUTPUT\|FORWARD"
        fi
        
    } | tee "$log_file"
    
    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    
    [ "$GENERATE_REPORT" = true ] && generate_scan_report "firewall"
}

# Função para verificar serviços
run_services_scan() {
    local log_file="$SCAN_LOG_DIR/temp_services.log"
    
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║ ${CYBER_GREEN}RUNNING SERVICES CHECK ${CYBER_BLUE}                                        ║${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
    
    {
        # List Running Services
        echo -e "\n=== Running Services ==="
        systemctl list-units --type=service --state=running
        
        # Check for unusual services
        echo -e "\n=== Unusual Services ==="
        systemctl list-units --type=service --state=running | grep -i "suspicious\|malware\|virus"
        
        if [ "$DEEP_SCAN" = true ]; then
            # Service File Analysis
            echo -e "\n=== Service File Analysis ==="
            for service in $(systemctl list-units --type=service --state=running | awk '{print $1}'); do
                echo "=== $service ==="
                cat "/etc/systemd/system/$service.service" 2>/dev/null || echo "No service file found"
            done
        fi
        
    } | tee "$log_file"
    
    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    
    [ "$GENERATE_REPORT" = true ] && generate_scan_report "services"
}

# Função principal
run_scan() {
    if [ $# -eq 0 ]; then
        show_scan_help
        return
    fi

    local scan_type="$1"
    shift

    case "$scan_type" in
        system)
            run_system_scan "$@"
            ;;
        security)
            run_security_scan "$@"
            ;;
        ports)
            run_port_scan "$@"
            ;;
        malware)
            run_malware_scan "$@"
            ;;
        updates)
            run_updates_scan "$@"
            ;;
        network)
            run_network_scan "$@"
            ;;
        firewall)
            run_firewall_scan "$@"
            ;;
        services)
            run_services_scan "$@"
            ;;
        --help|-h)
            show_scan_help
            ;;
        *)
            echo -e "${CYBER_RED}✖ Invalid scan type: $scan_type${RESET}"
            show_scan_help
            return 1
            ;;
    esac
}