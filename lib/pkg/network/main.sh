run_network() {
    while true; do
        echo -e "\n${CYBER_PURPLE}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
        echo -e "${CYBER_CYAN}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ NETWORK COMMANDS ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
        echo -e "${CYBER_PURPLE}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${RESET}"
        echo

        options=(
            "🌐 Network Interfaces"
            "📶 Connection Test"
            "🚦 Port Scanner"
            "📡 DNS Diagnostics"
            "📊 Bandwidth Monitor"
            "🔒 VPN Status"
            "⬅ Back to Main Menu"
        )

        PS3=$'\n\033[38;5;45m»»\033[0m '
        select opt in "${options[@]}"; do
            case $opt in
                "🌐 Network Interfaces")
                    show_network_interfaces
                    break
                    ;;
                "📶 Connection Test")
                    run_connection_test
                    break
                    ;;
                "🚦 Port Scanner")
                    run_port_scan
                    break
                    ;;
                "📡 DNS Diagnostics")
                    run_dns_diagnostics
                    break
                    ;;
                "📊 Bandwidth Monitor")
                    run_bandwidth_monitor
                    break
                    ;;
                "🔒 VPN Status")
                    check_vpn_status
                    break
                    ;;
                "⬅ Back to Main Menu")
                    return 0
                    ;;
                *)
                    echo -e "${CYBER_RED}✖ Invalid option${RESET}"
                    break
                    ;;
            esac
        done
    done
}

show_network_interfaces() {
    # Cores atualizadas para melhor contraste
    CYBER_GREEN='\033[1;92m'
    CYBER_RED='\033[1;91m'
    CYBER_YELLOW='\033[1;93m'
    CYBER_BLUE='\033[1;94m'
    CYBER_CYAN='\033[1;96m'
    RESET='\033[0m'

    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║ ${CYBER_GREEN}»»»»»»»»»»»»»»»»»» NETWORK INTERFACES ««««««««««««««««««${CYBER_BLUE} ║${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"

    # Obter interfaces de rede com tratamento robusto
    interfaces=$(ip -o link show 2>/dev/null | awk -F': ' '!/^[0-9]+: (lo|virbr|docker|br-|veth)/ {print $2}' | sort)

    # Adicionar interfaces especiais que queremos mostrar
    special_interfaces="lo docker0"
    for intf in $special_interfaces; do
        if ip -o link show dev $intf &>/dev/null; then
            interfaces="$intf $interfaces"
        fi
    done

    for intf in $interfaces; do
        # Pular interfaces que não existem mais
        [ ! -e "/sys/class/net/$intf" ] && continue

        # Obter status com tratamento de erro
        state=$(cat "/sys/class/net/$intf/operstate" 2>/dev/null || echo "unknown")
        case $state in
            "up") status="▲ UP" ;;
            "down") status="▼ DOWN" ;;
            *) status="? UNKNOWN" ;;
        esac

        # Obter endereço IP formatado
        ip_addr=$(ip -o -4 addr show dev $intf 2>/dev/null | awk '{print $4}')
        [ -z "$ip_addr" ] && ip_addr="${CYBER_RED}No IP${RESET}"

        # Obter MAC address com fallback
        mac=$(cat "/sys/class/net/$intf/address" 2>/dev/null || echo "00:00:00:00:00:00")

        # Truncar nomes longos (>15 chars)
        display_name=${intf:0:15}
        [ ${#intf} -gt 15 ] && display_name="${display_name:0:12}..."

        # Formatar linha com padding fixo
        printf "${CYBER_BLUE}║ ${CYBER_CYAN}%-15s ${RESET}%-10s %-21s ${CYBER_YELLOW}%-17s${CYBER_BLUE} ║${RESET}\n" \
               "$display_name" "$status" "$ip_addr" "$mac"
    done

    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    read -n 1 -s -r -p $'\n\033[38;5;45m»»\033[0m Press any key to continue...'
}


run_connection_test() {
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE} ${CYBER_GREEN}»»»»»»»»»»»»»»»»»» CONNECTION TEST ««««««««««««««««««${CYBER_BLUE} ${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"

    # Testar conectividade com vários serviços
    services=(
        "Google DNS:8.8.8.8"
        "Cloudflare:1.1.1.1"
        "Local Gateway:$(ip route | grep default | awk '{print $3}')"
    )

    for service in "${services[@]}"; do
        name=${service%:*}
        target=${service#*:}

        printf "${CYBER_BLUE} ${CYBER_CYAN}%-15s ${RESET}" "$name"

        if ping -c 1 -W 1 $target &> /dev/null; then
            printf "${CYBER_GREEN}%-20s ${CYBER_YELLOW}%-15s${CYBER_BLUE} ${RESET}\n" "✓ Reachable" "$target"
        else
            printf "${CYBER_RED}%-20s ${CYBER_YELLOW}%-15s${CYBER_BLUE} ${RESET}\n" "✖ Unreachable" "$target"
        fi
    done

    # Testar conexão à Internet
    printf "${CYBER_BLUE} ${CYBER_CYAN}%-15s ${RESET}" "Internet"
    if curl -Is https://google.com | head -n 1 | grep -q "200"; then
        printf "${CYBER_GREEN}%-20s ${CYBER_YELLOW}%-15s${CYBER_BLUE} ${RESET}\n" "✓ Connected" "https://google.com"
    else
        printf "${CYBER_RED}%-20s ${CYBER_YELLOW}%-15s${CYBER_BLUE} ${RESET}\n" "✖ No Connection" "https://google.com"
    fi

    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    read -n 1 -s -r -p $'\n\033[38;5;45m»»\033[0m Press any key to continue...'
}

run_port_scan() {
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE} ${CYBER_GREEN}»»»»»»»»»»»»»»»»»» PORT SCANNER ««««««««««««««««««${CYBER_BLUE} ${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"

    read -p $'\033[38;5;45m»»\033[0m Enter target IP or hostname: ' target
    read -p $'\033[38;5;45m»»\033[0m Enter port range (e.g., 1-100): ' port_range

    echo -e "\n${CYBER_YELLOW}» Scanning ports ${port_range} on ${target}...${RESET}"

    # Simulação de scan (substituir por nmap real se disponível)
    start_port=${port_range%-*}
    end_port=${port_range#*-}

    for ((port=start_port; port<=end_port; port++)); do
        (echo >/dev/tcp/$target/$port) &>/dev/null
        if [ $? -eq 0 ]; then
            printf "${CYBER_BLUE} ${CYBER_GREEN}Port %-5s ${CYBER_PURPLE}%-30s${CYBER_BLUE} ${RESET}\n" "$port" "✓ Open"
        fi
    done

    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    read -n 1 -s -r -p $'\n\033[38;5;45m»»\033[0m Press any key to continue...'
}

run_dns_diagnostics() {
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE} ${CYBER_GREEN}»»»»»»»»»»»»»»»»»» DNS DIAGNOSTICS ««««««««««««««««««${CYBER_BLUE} ${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"

    # Obter servidores DNS
    echo -e "${CYBER_BLUE} ${CYBER_CYAN}» Current DNS Servers:${RESET}"
    grep nameserver /etc/resolv.conf | awk '{print "║   " $2}' | while read dns; do
        echo -e "${CYBER_BLUE} ${CYBER_YELLOW}  ▪ $dns${RESET}"
    done

    # Testar resolução DNS
    domains=("google.com" "github.com" "example.com")
    for domain in "${domains[@]}"; do
        printf "${CYBER_BLUE} ${CYBER_CYAN}%-15s ${RESET}" "$domain"
        if host $domain &> /dev/null; then
            printf "${CYBER_GREEN}%-20s${CYBER_BLUE} ${RESET}\n" "✓ Resolved"
        else
            printf "${CYBER_RED}%-20s${CYBER_BLUE} ${RESET}\n" "✖ Failed"
        fi
    done

    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    read -n 1 -s -r -p $'\n\033[38;5;45m»»\033[0m Press any key to continue...'
}

run_bandwidth_monitor() {
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE} ${CYBER_GREEN}»»»»»»»»»»»»»»»»»» BANDWIDTH MONITOR ««««««««««««««««««${CYBER_BLUE} ${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"

    if ! command -v iftop &> /dev/null; then
        echo -e "${CYBER_BLUE} ${CYBER_RED}iftop not installed. Installing...${RESET}"
        if command -v apt &>/dev/null; then
            sudo apt install -y iftop
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y iftop
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm iftop
        else
            echo -e "${CYBER_BLUE} ${CYBER_RED}Cannot install iftop automatically${RESET}"
            echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
            return 1
        fi
    fi

    echo -e "${CYBER_BLUE} ${CYBER_YELLOW}» Starting bandwidth monitor (Ctrl+C to stop)${RESET}"
    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"

    sudo iftop -nNP
    read -n 1 -s -r -p $'\n\033[38;5;45m»»\033[0m Press any key to continue...'
}

check_vpn_status() {
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE} ${CYBER_GREEN}»»»»»»»»»»»»»»»»»» VPN STATUS ««««««««««««««««««${CYBER_BLUE} ${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"

    if ip tuntap show &> /dev/null; then
        echo -e "${CYBER_BLUE} ${CYBER_GREEN}✓ VPN tunnel interface detected${RESET}"

        # Obter IP público
        public_ip=$(curl -s https://api.ipify.org)
        echo -e "${CYBER_BLUE} ${CYBER_CYAN}» Public IP: ${CYBER_YELLOW}$public_ip${RESET}"

        # Verificar vazamento DNS
        dns_leak=$(dig +short myip.opendns.com @resolver1.opendns.com)
        if [[ "$public_ip" != "$dns_leak" ]]; then
            echo -e "${CYBER_BLUE} ${CYBER_RED}✖ DNS Leak detected!${RESET}"
            echo -e "${CYBER_BLUE} ${CYBER_YELLOW}» DNS IP: $dns_leak${RESET}"
        else
            echo -e "${CYBER_BLUE} ${CYBER_GREEN}✓ No DNS leaks detected${RESET}"
        fi
    else
        echo -e "${CYBER_BLUE} ${CYBER_RED}✖ No active VPN tunnel detected${RESET}"
    fi

    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    read -n 1 -s -r -p $'\n\033[38;5;45m»»\033[0m Press any key to continue...'
}