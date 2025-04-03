#!/bin/bash

# Developer Profile Utils
setup_developer_profile() {
    echo -e "\n${CYBER_BLUE}▓▒░ Setting up Developer Profile ░▒▓${RESET}"
    
    # Reset and basic setup
    _setup_base_config
    
    # Development Environment
    _setup_dev_ports
    _setup_db_ports
    _setup_api_ports
    _setup_git_services
    
    echo -e "${CYBER_GREEN}✓ Developer profile configured successfully${RESET}"
}

_setup_dev_ports() {
    # Web Development
    sudo ufw allow 80/tcp    # HTTP
    sudo ufw allow 443/tcp   # HTTPS
    sudo ufw allow 3000:3999/tcp  # React, Node, etc
    sudo ufw allow 8000:8999/tcp  # Django, Spring, etc
    sudo ufw allow 4200/tcp  # Angular
    sudo ufw allow 5173/tcp  # Vite
}

_setup_db_ports() {
    # Databases
    sudo ufw allow 5432/tcp  # PostgreSQL
    sudo ufw allow 3306/tcp  # MySQL
    sudo ufw allow 27017/tcp # MongoDB
    sudo ufw allow 6379/tcp  # Redis
    sudo ufw allow 11211/tcp # Memcached
}

_setup_api_ports() {
    # API Development
    sudo ufw allow 9000:9999/tcp  # Common API ports
    sudo ufw allow 4000:4999/tcp  # GraphQL and other services
}

_setup_git_services() {
    # Git Services
    sudo ufw allow 22/tcp    # SSH
    sudo ufw allow 9418/tcp  # Git Protocol
}

# DevOps Profile Utils
setup_devops_profile() {
    echo -e "\n${CYBER_BLUE}▓▒░ Setting up DevOps Profile ░▒▓${RESET}"
    
    # Reset and basic setup
    _setup_base_config
    
    # DevOps Environment
    _setup_container_ports
    _setup_orchestration_ports
    _setup_ci_cd_ports
    _setup_monitoring_ports
    
    echo -e "${CYBER_GREEN}✓ DevOps profile configured successfully${RESET}"
}

_setup_container_ports() {
    # Docker
    sudo ufw allow 2375/tcp  # Docker
    sudo ufw allow 2376/tcp  # Docker TLS
    sudo ufw allow 2377/tcp  # Docker Swarm
    sudo ufw allow 5000/tcp  # Docker Registry
    sudo ufw allow 5001/tcp  # Docker Registry UI
}

_setup_orchestration_ports() {
    # Kubernetes
    sudo ufw allow 6443/tcp      # Kubernetes API
    sudo ufw allow 10250:10252/tcp # Kubelet
    sudo ufw allow 8443/tcp      # Kubernetes Dashboard
    
    # Service Mesh
    sudo ufw allow 15000:15004/tcp # Istio
    sudo ufw allow 9080/tcp      # Service Mesh
}

_setup_ci_cd_ports() {
    # CI/CD Tools
    sudo ufw allow 8080/tcp  # Jenkins
    sudo ufw allow 8081/tcp  # Nexus
    sudo ufw allow 9000/tcp  # SonarQube
    sudo ufw allow 8200/tcp  # Vault
}

_setup_monitoring_ports() {
    # Monitoring Stack
    sudo ufw allow 9090/tcp  # Prometheus
    sudo ufw allow 9093/tcp  # Alertmanager
    sudo ufw allow 9100/tcp  # Node Exporter
    sudo ufw allow 3000/tcp  # Grafana
    sudo ufw allow 5601/tcp  # Kibana
    sudo ufw allow 9200/tcp  # Elasticsearch
}

# Security Profile Utils
setup_security_profile() {
    echo -e "\n${CYBER_BLUE}▓▒░ Setting up Security Profile ░▒▓${RESET}"
    
    # Reset and enhanced security setup
    _setup_enhanced_security
    
    # Security Environment
    _setup_security_tools_ports
    _setup_monitoring_security
    _setup_vpn_ports
    
    echo -e "${CYBER_GREEN}✓ Security profile configured successfully${RESET}"
}

_setup_enhanced_security() {
    # Reset with enhanced logging
    sudo ufw --force reset
    sudo ufw logging full
    
    # Strict defaults
    sudo ufw default deny incoming
    sudo ufw default deny outgoing
    
    # Essential outbound
    sudo ufw allow out 53/udp   # DNS
    sudo ufw allow out 80/tcp   # HTTP
    sudo ufw allow out 443/tcp  # HTTPS
    
    # SSH with strict limits
    sudo ufw limit ssh
    sudo ufw limit 22/tcp
}

_setup_security_tools_ports() {
    # Security Tools
    sudo ufw allow 8834/tcp  # Nessus
    sudo ufw allow 9392/tcp  # OpenVAS
    sudo ufw allow 1514/tcp  # OSSEC
    sudo ufw allow 1515/tcp  # OSSEC Auth
    sudo ufw allow 8000/tcp  # Burp Suite
    sudo ufw allow 8080/tcp  # OWASP ZAP
}

_setup_monitoring_security() {
    # Security Monitoring
    sudo ufw allow 514/tcp   # Syslog
    sudo ufw allow 514/udp   # Syslog
    sudo ufw allow 5044/tcp  # Logstash
    sudo ufw allow 5140/tcp  # Logstash
    sudo ufw allow 9200/tcp  # Elasticsearch
    sudo ufw allow 5601/tcp  # Kibana
}

_setup_vpn_ports() {
    # VPN Services
    sudo ufw allow 1194/udp  # OpenVPN
    sudo ufw allow 500/udp   # IKEv2
    sudo ufw allow 4500/udp  # IKEv2 NAT
}

# Common Utils
_setup_base_config() {
    # Reset existing rules
    sudo ufw --force reset
    
    # Enable firewall
    sudo ufw enable
    
    # Basic security
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    # SSH
    sudo ufw allow ssh
}