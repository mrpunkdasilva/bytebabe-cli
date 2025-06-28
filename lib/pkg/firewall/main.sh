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
    
    echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                    SYSTEM ANALYSIS                    ${CYBER_PURPLE}║${RESET}"
    echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo -e "${CYBER_YELLOW}▓▒░ OS: $OS $VER ░▒▓${RESET}"
    
    # Check for existing firewalls
    local firewall_installed=false
    local firewall_type=""
    
    echo -e "\n${CYBER_BLUE}▓▒░ SCANNING FOR FIREWALL SYSTEMS ░▒▓${RESET}"
    
    # Check UFW
    if command -v ufw &> /dev/null; then
        firewall_installed=true
        firewall_type="ufw"
        echo -e "  ${CYBER_GREEN}► UFW FIREWALL DETECTED${RESET}"
    # Check firewalld (Fedora/RHEL/CentOS)
    elif command -v firewall-cmd &> /dev/null; then
        firewall_installed=true
        firewall_type="firewalld"
        echo -e "  ${CYBER_GREEN}► FIREWALLD DETECTED${RESET}"
    # Check iptables
    elif command -v iptables &> /dev/null; then
        firewall_installed=true
        firewall_type="iptables"
        echo -e "  ${CYBER_GREEN}► IPTABLES DETECTED${RESET}"
    # Check nftables
    elif command -v nft &> /dev/null; then
        firewall_installed=true
        firewall_type="nftables"
        echo -e "  ${CYBER_GREEN}► NFTABLES DETECTED${RESET}"
    fi
    
    if [[ "$firewall_installed" == false ]]; then
        echo -e "  ${CYBER_RED}► NO FIREWALL DETECTED${RESET}"
        echo -e "\n${CYBER_YELLOW}▓▒░ INSTALLING APPROPRIATE FIREWALL ░▒▓${RESET}"
        
        # Install firewall based on OS
        case $OS in
            *"Fedora"*|*"Red Hat"*|*"CentOS"*|*"Rocky"*|*"AlmaLinux"*)
                echo -e "  ${CYBER_BLUE}► SELECTING FIREWALLD FOR RHEL/FEDORA${RESET}"
                install_firewalld
                firewall_type="firewalld"
                ;;
            *"Ubuntu"*|*"Debian"*|*"Linux Mint"*)
                echo -e "  ${CYBER_BLUE}► SELECTING UFW FOR DEBIAN/UBUNTU${RESET}"
                install_ufw
                firewall_type="ufw"
                ;;
            *"Arch"*|*"Manjaro"*)
                echo -e "  ${CYBER_BLUE}► SELECTING UFW FOR ARCH${RESET}"
                install_ufw
                firewall_type="ufw"
                ;;
            *"openSUSE"*|*"SUSE"*)
                echo -e "  ${CYBER_BLUE}► SELECTING FIREWALLD FOR SUSE${RESET}"
                install_firewalld
                firewall_type="firewalld"
                ;;
            *)
                # Default to UFW for unknown distributions
                echo -e "  ${CYBER_BLUE}► SELECTING UFW AS DEFAULT${RESET}"
                install_ufw
                firewall_type="ufw"
                ;;
        esac
    fi
    
    # Export firewall type for other functions
    export FIREWALL_TYPE=$firewall_type
    
    echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                    FIREWALL SELECTED                    ${CYBER_PURPLE}║${RESET}"
    echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
    echo -e "${CYBER_GREEN}▓▒░ ✓ ACTIVE FIREWALL: $firewall_type ░▒▓${RESET}"
}

install_ufw() {
    echo -e "\n${CYBER_BLUE}▓▒░ Installing UFW Firewall ░▒▓${RESET}"
    
    echo -e "\n${CYBER_YELLOW}▓▒░ DETECTING PACKAGE MANAGER ░▒▓${RESET}"
    
    if command -v apt &> /dev/null; then
        echo -e "  ${CYBER_BLUE}► USING APT PACKAGE MANAGER${RESET}"
        sudo apt update && sudo apt install -y ufw
    elif command -v dnf &> /dev/null; then
        echo -e "  ${CYBER_BLUE}► USING DNF PACKAGE MANAGER${RESET}"
        sudo dnf install -y ufw
    elif command -v yum &> /dev/null; then
        echo -e "  ${CYBER_BLUE}► USING YUM PACKAGE MANAGER${RESET}"
        sudo yum install -y ufw
    elif command -v pacman &> /dev/null; then
        echo -e "  ${CYBER_BLUE}► USING PACMAN PACKAGE MANAGER${RESET}"
        sudo pacman -S --noconfirm ufw
    elif command -v zypper &> /dev/null; then
        echo -e "  ${CYBER_BLUE}► USING ZYPPER PACKAGE MANAGER${RESET}"
        sudo zypper install -y ufw
    else
        echo -e "  ${CYBER_RED}► NO SUPPORTED PACKAGE MANAGER FOUND${RESET}"
        return 1
    fi
    
    if command -v ufw &> /dev/null; then
        echo -e "\n${CYBER_GREEN}▓▒░ ✓ UFW INSTALLED SUCCESSFULLY ░▒▓${RESET}"
        echo -e "\n${CYBER_YELLOW}▓▒░ ENABLING UFW FIREWALL ░▒▓${RESET}"
        sudo ufw --force enable
        echo -e "${CYBER_GREEN}▓▒░ ✓ UFW ENABLED ░▒▓${RESET}"
    else
        echo -e "\n${CYBER_RED}▓▒░ ✖ FAILED TO INSTALL UFW ░▒▓${RESET}"
        return 1
    fi
}

install_firewalld() {
    echo -e "\n${CYBER_BLUE}▓▒░ Installing firewalld ░▒▓${RESET}"
    
    echo -e "\n${CYBER_YELLOW}▓▒░ DETECTING PACKAGE MANAGER ░▒▓${RESET}"
    
    if command -v dnf &> /dev/null; then
        echo -e "  ${CYBER_BLUE}► USING DNF PACKAGE MANAGER${RESET}"
        sudo dnf install -y firewalld
    elif command -v yum &> /dev/null; then
        echo -e "  ${CYBER_BLUE}► USING YUM PACKAGE MANAGER${RESET}"
        sudo yum install -y firewalld
    elif command -v zypper &> /dev/null; then
        echo -e "  ${CYBER_BLUE}► USING ZYPPER PACKAGE MANAGER${RESET}"
        sudo zypper install -y firewalld
    else
        echo -e "  ${CYBER_RED}► NO SUPPORTED PACKAGE MANAGER FOUND${RESET}"
        return 1
    fi
    
    if command -v firewall-cmd &> /dev/null; then
        echo -e "\n${CYBER_GREEN}▓▒░ ✓ FIREWALLD INSTALLED SUCCESSFULLY ░▒▓${RESET}"
        echo -e "\n${CYBER_YELLOW}▓▒░ ENABLING FIREWALLD SERVICE ░▒▓${RESET}"
        sudo systemctl enable firewalld
        sudo systemctl start firewalld
        echo -e "${CYBER_GREEN}▓▒░ ✓ FIREWALLD ENABLED AND STARTED ░▒▓${RESET}"
    else
        echo -e "\n${CYBER_RED}▓▒░ ✖ FAILED TO INSTALL FIREWALLD ░▒▓${RESET}"
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
                
                # Display services with descriptions
                echo -e "\n${CYBER_YELLOW}▓▒░ ENABLED SERVICES ░▒▓${RESET}"
                local services=$(sudo firewall-cmd --list-services)
                local services_shown=false
                if [[ -n "$services" ]]; then
                    echo "$services" | tr ' ' '\n' | while read service; do
                        if [[ -n "$service" ]]; then
                            services_shown=true
                            case $service in
                                "ssh") echo -e "  ${CYBER_GREEN}► SSH${RESET} - Secure Shell access" ;;
                                "dhcpv6-client") echo -e "  ${CYBER_BLUE}► DHCPv6${RESET} - IPv6 address assignment" ;;
                                "mdns") echo -e "  ${CYBER_MAGENTA}► mDNS${RESET} - Multicast DNS discovery" ;;
                                "samba-client") echo -e "  ${CYBER_CYAN}► Samba${RESET} - Windows file sharing" ;;
                                "http") echo -e "  ${CYBER_YELLOW}► HTTP${RESET} - Web server (port 80)" ;;
                                "https") echo -e "  ${CYBER_YELLOW}► HTTPS${RESET} - Secure web server (port 443)" ;;
                                "ftp") echo -e "  ${CYBER_BLUE}► FTP${RESET} - File transfer protocol" ;;
                                "dns") echo -e "  ${CYBER_MAGENTA}► DNS${RESET} - Domain name resolution" ;;
                                *) echo -e "  ${CYBER_WHITE}► $service${RESET}" ;;
                            esac
                        fi
                    done
                fi
                if [[ -z "$services" ]]; then
                    echo -e "  ${CYBER_RED}► NO SERVICES ENABLED${RESET}"
                fi
                
                # Display ports with descriptions
                echo -e "\n${CYBER_YELLOW}▓▒░ OPEN PORTS ░▒▓${RESET}"
                local ports=$(sudo firewall-cmd --list-ports)
                if [[ -n "$ports" ]]; then
                    echo "$ports" | tr ' ' '\n' | while read port; do
                        if [[ -n "$port" ]]; then
                            case $port in
                                "22/tcp") echo -e "  ${CYBER_GREEN}► Port 22/tcp${RESET} - SSH access" ;;
                                "80/tcp") echo -e "  ${CYBER_YELLOW}► Port 80/tcp${RESET} - HTTP web server" ;;
                                "443/tcp") echo -e "  ${CYBER_YELLOW}► Port 443/tcp${RESET} - HTTPS secure web" ;;
                                "3000/tcp") echo -e "  ${CYBER_CYAN}► Port 3000/tcp${RESET} - React/Node.js dev server" ;;
                                "8000/tcp") echo -e "  ${CYBER_CYAN}► Port 8000/tcp${RESET} - Django/Flask dev server" ;;
                                "8080/tcp") echo -e "  ${CYBER_CYAN}► Port 8080/tcp${RESET} - Alternative web server" ;;
                                "3306/tcp") echo -e "  ${CYBER_MAGENTA}► Port 3306/tcp${RESET} - MySQL database" ;;
                                "5432/tcp") echo -e "  ${CYBER_MAGENTA}► Port 5432/tcp${RESET} - PostgreSQL database" ;;
                                "27017/tcp") echo -e "  ${CYBER_MAGENTA}► Port 27017/tcp${RESET} - MongoDB database" ;;
                                "6379/tcp") echo -e "  ${CYBER_MAGENTA}► Port 6379/tcp${RESET} - Redis cache" ;;
                                *) echo -e "  ${CYBER_WHITE}► Port $port${RESET}" ;;
                            esac
                        fi
                    done
                else
                    echo -e "  ${CYBER_RED}► NO PORTS OPEN${RESET}"
                fi
                
                # Display interfaces
                echo -e "\n${CYBER_YELLOW}▓▒░ NETWORK INTERFACES ░▒▓${RESET}"
                local interfaces=$(sudo firewall-cmd --list-interfaces)
                if [[ -n "$interfaces" ]]; then
                    echo "$interfaces" | tr ' ' '\n' | while read interface; do
                        if [[ -n "$interface" ]]; then
                            case $interface in
                                "wlo1") echo -e "  ${CYBER_BLUE}► $interface${RESET} - Wireless network interface" ;;
                                "eno1"|"eth0") echo -e "  ${CYBER_GREEN}► $interface${RESET} - Wired network interface" ;;
                                "lo") echo -e "  ${CYBER_MAGENTA}► $interface${RESET} - Loopback interface" ;;
                                "docker0") echo -e "  ${CYBER_CYAN}► $interface${RESET} - Docker bridge network" ;;
                                *) echo -e "  ${CYBER_WHITE}► $interface${RESET}" ;;
                            esac
                        fi
                    done
                else
                    echo -e "  ${CYBER_RED}► NO INTERFACES CONFIGURED${RESET}"
                fi
                
                # Security summary
                echo -e "\n${CYBER_YELLOW}▓▒░ SECURITY SUMMARY ░▒▓${RESET}"
                local service_count=$(echo "$services" | wc -w)
                local port_count=$(echo "$ports" | wc -w)
                local interface_count=$(echo "$interfaces" | wc -w)
                
                echo -e "  ${CYBER_BLUE}► SERVICES: $service_count${RESET}"
                echo -e "  ${CYBER_BLUE}► PORTS: $port_count${RESET}"
                echo -e "  ${CYBER_BLUE}► INTERFACES: $interface_count${RESET}"
                
                # Security recommendations
                echo -e "\n${CYBER_YELLOW}▓▒░ SECURITY RECOMMENDATIONS ░▒▓${RESET}"
                if [[ $port_count -gt 10 ]]; then
                    echo -e "  ${CYBER_RED}⚠ MANY PORTS OPEN - Consider closing unnecessary ports${RESET}"
                fi
                if [[ $service_count -eq 0 ]]; then
                    echo -e "  ${CYBER_YELLOW}⚠ NO SERVICES ENABLED - Consider enabling essential services${RESET}"
                fi
                if echo "$services" | grep -q "ssh"; then
                    echo -e "  ${CYBER_GREEN}✓ SSH access enabled${RESET}"
                else
                    echo -e "  ${CYBER_RED}⚠ SSH not enabled - You may lose remote access${RESET}"
                fi

                # SSH Details block
                echo -e "\n${CYBER_PURPLE}▓▒░ SSH DETAILS ░▒▓${RESET}"
                # SSH Port(s)
                local ssh_ports=$(sudo firewall-cmd --zone=$active_zone --list-ports | tr ' ' '\n' | grep -E '22/(tcp|udp)')
                if [[ -n "$ssh_ports" ]]; then
                    echo -e "  ${CYBER_GREEN}► SSH Port(s): $ssh_ports${RESET}"
                else
                    # Check if SSH is enabled as a service (default port 22)
                    if echo "$services" | grep -q "ssh"; then
                        echo -e "  ${CYBER_GREEN}► SSH Port(s): 22/tcp (default)${RESET}"
                    else
                        echo -e "  ${CYBER_RED}► SSH Port(s): Not detected${RESET}"
                    fi
                fi
                # Allowed IPs (sources)
                local ssh_sources=$(sudo firewall-cmd --zone=$active_zone --list-sources)
                if [[ -n "$ssh_sources" ]]; then
                    echo -e "  ${CYBER_BLUE}► Allowed IPs: $ssh_sources${RESET}"
                else
                    echo -e "  ${CYBER_YELLOW}► Allowed IPs: All (no restriction)${RESET}"
                fi
                # Rate limiting (not natively in firewalld, but check for rich rules)
                local ssh_rich=$(sudo firewall-cmd --zone=$active_zone --list-rich-rules | grep -i ssh)
                if echo "$ssh_rich" | grep -qi 'limit'; then
                    echo -e "  ${CYBER_MAGENTA}► Rate Limiting: Enabled${RESET}"
                else
                    echo -e "  ${CYBER_YELLOW}► Rate Limiting: Not detected${RESET}"
                fi
                # Logging (check if logging is enabled for SSH)
                local ssh_log=$(sudo firewall-cmd --zone=$active_zone --list-rich-rules | grep -i ssh | grep -i log)
                if [[ -n "$ssh_log" ]]; then
                    echo -e "  ${CYBER_CYAN}► Logging: Enabled for SSH${RESET}"
                else
                    echo -e "  ${CYBER_YELLOW}► Logging: Not detected for SSH${RESET}"
                fi

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
            echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
            echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                    UFW FIREWALL RULES                    ${CYBER_PURPLE}║${RESET}"
            echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
            
            if sudo ufw status numbered; then
                echo -e "\n${CYBER_GREEN}▓▒░ ✓ UFW RULES DISPLAYED ░▒▓${RESET}"
                
                # Parse and display rules in a more organized way
                echo -e "\n${CYBER_YELLOW}▓▒░ RULE SUMMARY ░▒▓${RESET}"
                local total_rules=$(sudo ufw status numbered | grep -c "^\[")
                local allowed_rules=$(sudo ufw status numbered | grep -c "ALLOW")
                local denied_rules=$(sudo ufw status numbered | grep -c "DENY")
                
                echo -e "  ${CYBER_BLUE}► TOTAL RULES: $total_rules${RESET}"
                echo -e "  ${CYBER_GREEN}► ALLOWED: $allowed_rules${RESET}"
                echo -e "  ${CYBER_RED}► DENIED: $denied_rules${RESET}"
            else
                echo -e "\n${CYBER_RED}▓▒░ ✖ FAILED TO LIST UFW RULES ░▒▓${RESET}"
            fi
            ;;
        "firewalld")
            echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
            echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                  FIREWALLD RULES PANEL                  ${CYBER_PURPLE}║${RESET}"
            echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
            
            # Get active zone
            local active_zone=$(sudo firewall-cmd --get-active-zones | head -n1 | cut -d' ' -f1)
            echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════╗${RESET}"
            echo -e "${CYBER_BLUE}║${CYBER_CYAN}                    ACTIVE ZONE: $active_zone${CYBER_BLUE}                    ║${RESET}"
            echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════╝${RESET}"
            
            # Display services with descriptions
            echo -e "\n${CYBER_YELLOW}▓▒░ ENABLED SERVICES ░▒▓${RESET}"
            local services=$(sudo firewall-cmd --list-services)
            local services_shown=false
            if [[ -n "$services" ]]; then
                echo "$services" | tr ' ' '\n' | while read service; do
                    if [[ -n "$service" ]]; then
                        services_shown=true
                        case $service in
                            "ssh") echo -e "  ${CYBER_GREEN}► SSH${RESET} - Secure Shell access" ;;
                            "dhcpv6-client") echo -e "  ${CYBER_BLUE}► DHCPv6${RESET} - IPv6 address assignment" ;;
                            "mdns") echo -e "  ${CYBER_MAGENTA}► mDNS${RESET} - Multicast DNS discovery" ;;
                            "samba-client") echo -e "  ${CYBER_CYAN}► Samba${RESET} - Windows file sharing" ;;
                            "http") echo -e "  ${CYBER_YELLOW}► HTTP${RESET} - Web server (port 80)" ;;
                            "https") echo -e "  ${CYBER_YELLOW}► HTTPS${RESET} - Secure web server (port 443)" ;;
                            "ftp") echo -e "  ${CYBER_BLUE}► FTP${RESET} - File transfer protocol" ;;
                            "dns") echo -e "  ${CYBER_MAGENTA}► DNS${RESET} - Domain name resolution" ;;
                            *) echo -e "  ${CYBER_WHITE}► $service${RESET}" ;;
                        esac
                    fi
                done
            fi
            if [[ -z "$services" ]]; then
                echo -e "  ${CYBER_RED}► NO SERVICES ENABLED${RESET}"
            fi
            
            # Display ports with descriptions
            echo -e "\n${CYBER_YELLOW}▓▒░ OPEN PORTS ░▒▓${RESET}"
            local ports=$(sudo firewall-cmd --list-ports)
            if [[ -n "$ports" ]]; then
                echo "$ports" | tr ' ' '\n' | while read port; do
                    if [[ -n "$port" ]]; then
                        case $port in
                            "22/tcp") echo -e "  ${CYBER_GREEN}► Port 22/tcp${RESET} - SSH access" ;;
                            "80/tcp") echo -e "  ${CYBER_YELLOW}► Port 80/tcp${RESET} - HTTP web server" ;;
                            "443/tcp") echo -e "  ${CYBER_YELLOW}► Port 443/tcp${RESET} - HTTPS secure web" ;;
                            "3000/tcp") echo -e "  ${CYBER_CYAN}► Port 3000/tcp${RESET} - React/Node.js dev server" ;;
                            "8000/tcp") echo -e "  ${CYBER_CYAN}► Port 8000/tcp${RESET} - Django/Flask dev server" ;;
                            "8080/tcp") echo -e "  ${CYBER_CYAN}► Port 8080/tcp${RESET} - Alternative web server" ;;
                            "3306/tcp") echo -e "  ${CYBER_MAGENTA}► Port 3306/tcp${RESET} - MySQL database" ;;
                            "5432/tcp") echo -e "  ${CYBER_MAGENTA}► Port 5432/tcp${RESET} - PostgreSQL database" ;;
                            "27017/tcp") echo -e "  ${CYBER_MAGENTA}► Port 27017/tcp${RESET} - MongoDB database" ;;
                            "6379/tcp") echo -e "  ${CYBER_MAGENTA}► Port 6379/tcp${RESET} - Redis cache" ;;
                            *) echo -e "  ${CYBER_WHITE}► Port $port${RESET}" ;;
                        esac
                    fi
                done
            else
                echo -e "  ${CYBER_RED}► NO PORTS OPEN${RESET}"
            fi
            
            # Display interfaces
            echo -e "\n${CYBER_YELLOW}▓▒░ NETWORK INTERFACES ░▒▓${RESET}"
            local interfaces=$(sudo firewall-cmd --list-interfaces)
            if [[ -n "$interfaces" ]]; then
                echo "$interfaces" | tr ' ' '\n' | while read interface; do
                    if [[ -n "$interface" ]]; then
                        case $interface in
                            "wlo1") echo -e "  ${CYBER_BLUE}► $interface${RESET} - Wireless network interface" ;;
                            "eno1"|"eth0") echo -e "  ${CYBER_GREEN}► $interface${RESET} - Wired network interface" ;;
                            "lo") echo -e "  ${CYBER_MAGENTA}► $interface${RESET} - Loopback interface" ;;
                            "docker0") echo -e "  ${CYBER_CYAN}► $interface${RESET} - Docker bridge network" ;;
                            *) echo -e "  ${CYBER_WHITE}► $interface${RESET}" ;;
                        esac
                    fi
                done
            else
                echo -e "  ${CYBER_RED}► NO INTERFACES CONFIGURED${RESET}"
            fi
            
            # Security summary
            echo -e "\n${CYBER_YELLOW}▓▒░ SECURITY SUMMARY ░▒▓${RESET}"
            local service_count=$(echo "$services" | wc -w)
            local port_count=$(echo "$ports" | wc -w)
            local interface_count=$(echo "$interfaces" | wc -w)
            
            echo -e "  ${CYBER_BLUE}► SERVICES: $service_count${RESET}"
            echo -e "  ${CYBER_BLUE}► PORTS: $port_count${RESET}"
            echo -e "  ${CYBER_BLUE}► INTERFACES: $interface_count${RESET}"
            
            # Security recommendations
            echo -e "\n${CYBER_YELLOW}▓▒░ SECURITY RECOMMENDATIONS ░▒▓${RESET}"
            if [[ $port_count -gt 10 ]]; then
                echo -e "  ${CYBER_RED}⚠ MANY PORTS OPEN - Consider closing unnecessary ports${RESET}"
            fi
            if [[ $service_count -eq 0 ]]; then
                echo -e "  ${CYBER_YELLOW}⚠ NO SERVICES ENABLED - Consider enabling essential services${RESET}"
            fi
            if echo "$services" | grep -q "ssh"; then
                echo -e "  ${CYBER_GREEN}✓ SSH access enabled${RESET}"
            else
                echo -e "  ${CYBER_RED}⚠ SSH not enabled - You may lose remote access${RESET}"
            fi

            # SSH Details block
            echo -e "\n${CYBER_PURPLE}▓▒░ SSH DETAILS ░▒▓${RESET}"
            # SSH Port(s)
            local ssh_ports=$(sudo firewall-cmd --zone=$active_zone --list-ports | tr ' ' '\n' | grep -E '22/(tcp|udp)')
            if [[ -n "$ssh_ports" ]]; then
                echo -e "  ${CYBER_GREEN}► SSH Port(s): $ssh_ports${RESET}"
            else
                # Check if SSH is enabled as a service (default port 22)
                if echo "$services" | grep -q "ssh"; then
                    echo -e "  ${CYBER_GREEN}► SSH Port(s): 22/tcp (default)${RESET}"
                else
                    echo -e "  ${CYBER_RED}► SSH Port(s): Not detected${RESET}"
                fi
            fi
            # Allowed IPs (sources)
            local ssh_sources=$(sudo firewall-cmd --zone=$active_zone --list-sources)
            if [[ -n "$ssh_sources" ]]; then
                echo -e "  ${CYBER_BLUE}► Allowed IPs: $ssh_sources${RESET}"
            else
                echo -e "  ${CYBER_YELLOW}► Allowed IPs: All (no restriction)${RESET}"
            fi
            # Rate limiting (not natively in firewalld, but check for rich rules)
            local ssh_rich=$(sudo firewall-cmd --zone=$active_zone --list-rich-rules | grep -i ssh)
            if echo "$ssh_rich" | grep -qi 'limit'; then
                echo -e "  ${CYBER_MAGENTA}► Rate Limiting: Enabled${RESET}"
            else
                echo -e "  ${CYBER_YELLOW}► Rate Limiting: Not detected${RESET}"
            fi
            # Logging (check if logging is enabled for SSH)
            local ssh_log=$(sudo firewall-cmd --zone=$active_zone --list-rich-rules | grep -i ssh | grep -i log)
            if [[ -n "$ssh_log" ]]; then
                echo -e "  ${CYBER_CYAN}► Logging: Enabled for SSH${RESET}"
            else
                echo -e "  ${CYBER_YELLOW}► Logging: Not detected for SSH${RESET}"
            fi

            echo -e "\n${CYBER_GREEN}▓▒░ ✓ FIREWALLD RULES DISPLAYED ░▒▓${RESET}"
            ;;
        "iptables")
            echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
            echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                   IPTABLES RULES PANEL                   ${CYBER_PURPLE}║${RESET}"
            echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
            
            echo -e "\n${CYBER_YELLOW}▓▒░ IPTABLES RULES (DETAILED) ░▒▓${RESET}"
            if sudo iptables -L -v -n --line-numbers; then
                echo -e "\n${CYBER_GREEN}▓▒░ ✓ IPTABLES RULES DISPLAYED ░▒▓${RESET}"
            else
                echo -e "\n${CYBER_RED}▓▒░ ✖ FAILED TO LIST IPTABLES RULES ░▒▓${RESET}"
            fi
            ;;
        "nftables")
            echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
            echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                   NFTABLES RULES PANEL                   ${CYBER_PURPLE}║${RESET}"
            echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
            
            echo -e "\n${CYBER_YELLOW}▓▒░ NFTABLES RULES (DETAILED) ░▒▓${RESET}"
            if sudo nft list ruleset; then
                echo -e "\n${CYBER_GREEN}▓▒░ ✓ NFTABLES RULES DISPLAYED ░▒▓${RESET}"
            else
                echo -e "\n${CYBER_RED}▓▒░ ✖ FAILED TO LIST NFTABLES RULES ░▒▓${RESET}"
            fi
            ;;
        *)
            echo -e "\n${CYBER_RED}▓▒░ ✖ UNKNOWN FIREWALL TYPE: $FIREWALL_TYPE ░▒▓${RESET}"
            ;;
    esac
    
    echo -e "\n${CYBER_PURPLE}╔══════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_PURPLE}║${CYBER_CYAN}                    RULES ANALYSIS COMPLETE                    ${CYBER_PURPLE}║${RESET}"
    echo -e "${CYBER_PURPLE}╚══════════════════════════════════════════════════════════════╝${RESET}"
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
