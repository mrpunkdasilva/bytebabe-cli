#!/bin/bash

configure_rate_limiting() {
    echo -e "\n${CYBER_BLUE}▓▒░ Rate Limiting Configuration ░▒▓${RESET}"
    
    read -p "Enter port number: " port
    read -p "Enter protocol (tcp/udp): " proto
    read -p "Enter max connections per IP: " conn_limit
    
    if sudo ufw limit $port/$proto comment "Rate limited to $conn_limit connections"; then
        echo -e "${CYBER_GREEN}✓ Rate limit configured successfully${RESET}"
    else
        echo -e "${CYBER_RED}✖ Failed to configure rate limit${RESET}"
    fi
}

setup_port_forwarding() {
    echo -e "\n${CYBER_BLUE}▓▒░ Port Forwarding Setup ░▒▓${RESET}"
    
    read -p "Enter source port: " src_port
    read -p "Enter destination IP: " dest_ip
    read -p "Enter destination port: " dest_port
    read -p "Enter protocol (tcp/udp): " proto
    
    if sudo ufw route allow proto $proto from any to $dest_ip port $dest_port; then
        echo -e "${CYBER_GREEN}✓ Port forwarding configured successfully${RESET}"
    else
        echo -e "${CYBER_RED}✖ Failed to configure port forwarding${RESET}"
    fi
}

manage_logging_levels() {
    echo -e "\n${CYBER_BLUE}▓▒░ UFW Logging Configuration ░▒▓${RESET}"
    
    echo -e "1) Off"
    echo -e "2) Low"
    echo -e "3) Medium"
    echo -e "4) High"
    echo -e "5) Full"
    
    read -p "Select logging level: " level
    
    case $level in
        1) sudo ufw logging off ;;
        2) sudo ufw logging low ;;
        3) sudo ufw logging medium ;;
        4) sudo ufw logging high ;;
        5) sudo ufw logging full ;;
        *) echo -e "${CYBER_RED}✖ Invalid option${RESET}"; return 1 ;;
    esac
    
    echo -e "${CYBER_GREEN}✓ Logging level updated${RESET}"
}

block_ip_ranges() {
    echo -e "\n${CYBER_BLUE}▓▒░ IP Range Blocking ░▒▓${RESET}"
    
    read -p "Enter IP range (CIDR notation, e.g. 192.168.1.0/24): " ip_range
    
    if sudo ufw deny from $ip_range; then
        echo -e "${CYBER_GREEN}✓ IP range blocked successfully${RESET}"
    else
        echo -e "${CYBER_RED}✖ Failed to block IP range${RESET}"
    fi
}

backup_restore_rules() {
    echo -e "\n${CYBER_BLUE}▓▒░ Backup/Restore Rules ░▒▓${RESET}"
    
    echo -e "1) Backup current rules"
    echo -e "2) Restore from backup"
    read -p "Select option: " option
    
    case $option in
        1)
            backup_file="/tmp/ufw-backup-$(date +%Y%m%d-%H%M%S).rules"
            if sudo ufw status numbered > "$backup_file"; then
                echo -e "${CYBER_GREEN}✓ Rules backed up to $backup_file${RESET}"
            else
                echo -e "${CYBER_RED}✖ Backup failed${RESET}"
            fi
            ;;
        2)
            read -p "Enter backup file path: " restore_file
            if [ -f "$restore_file" ]; then
                sudo ufw --force reset
                while IFS= read -r rule; do
                    sudo ufw $rule
                done < "$restore_file"
                echo -e "${CYBER_GREEN}✓ Rules restored successfully${RESET}"
            else
                echo -e "${CYBER_RED}✖ Backup file not found${RESET}"
            fi
            ;;
        *)
            echo -e "${CYBER_RED}✖ Invalid option${RESET}"
            ;;
    esac
}

view_active_connections() {
    echo -e "\n${CYBER_BLUE}▓▒░ Active Connections ░▒▓${RESET}"
    
    echo -e "\n${CYBER_YELLOW}TCP Connections:${RESET}"
    sudo netstat -tnp
    
    echo -e "\n${CYBER_YELLOW}UDP Connections:${RESET}"
    sudo netstat -unp
}