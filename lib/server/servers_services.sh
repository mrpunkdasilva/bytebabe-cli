#!/bin/bash

# ======================
# DOCKER SERVER MANAGER - BYTEBABE EDITION
# ======================

# Cores Cyberpunk
CYBER_RED='\033[1;31m'
CYBER_GREEN='\033[1;32m'
CYBER_YELLOW='\033[1;33m'
CYBER_BLUE='\033[1;34m'
CYBER_PINK='\033[1;35m'
CYBER_CYAN='\033[1;36m'
CYBER_WHITE='\033[1;37m'
RESET='\033[0m'

# Configurações padrão
PROJECT_NAME="bytebabe_servers"
APACHE_PORT="8080"
NGINX_PORT="8081"
SSL_PORT="4430"
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
DOCKER_DIR="$BASE_DIR/docker"
COMPOSE_FILE="$BASE_DIR/docker-compose.yml"

# ======================
# FUNÇÕES UTILITÁRIAS
# ======================

# Esta função verifica se o Docker Compose está instalado e configurado corretamente.
# Caso contrário, ela exibe instruções de instalação.
check_docker_compose() {
    # Primeiro tenta docker compose (nova versão)
    if docker compose -v &> /dev/null; then
        COMPOSE_CMD="sudo docker compose"
    else
        echo -e "${CYBER_RED}✘ Docker Compose não está instalado!${RESET}"
        echo -e "${CYBER_YELLOW}▶ Instale o Docker Compose primeiro:${RESET}"
        echo -e "  Linux: sudo apt install docker-compose"
        echo -e "  Mac: brew install docker-compose"
        echo -e "  Ou consulte: https://docs.docker.com/compose/install/"
        exit 1
    fi
}

# Esta função cria um diretório, se ele ainda não existir.
create_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e "${CYBER_GREEN}✔ Diretório criado: ${CYBER_CYAN}$dir${RESET}"
    fi
}

# Esta função verifica se o Docker está instalado. Caso contrário, ela exibe uma mensagem de erro e sai.
check_docker_installed() {
    if ! command -v docker &> /dev/null; then
        echo -e "${CYBER_RED}✘ Docker não está instalado!${RESET}"
        echo -e "${CYBER_YELLOW}Execute o comando 'bytebabe install docker' primeiro.${RESET}"
        exit 1
    fi
    check_docker_compose
}

# ======================
# FUNÇÕES PRINCIPAIS
# ======================

# Esta função verifica se o arquivo 'docker-compose.yml' existe. Caso contrário, ela exibe uma mensagem de erro e sai.
check_compose_file() {
    if [ ! -f "$COMPOSE_FILE" ]; then
        echo -e "${CYBER_YELLOW}⚠ Arquivo docker-compose.yml não encontrado!${RESET}"
        echo -e "${CYBER_GREEN}Execute 'bytebabe servers setup' para configurar.${RESET}"
        exit 1
    fi
}

# Esta função exibe uma mensagem de sucesso quando um servidor é iniciado com êxito.
show_success_message() {
    local server_to_start="$1"
    echo -e "\n${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    echo -e "${CYBER_GREEN}           SERVIDOR '$server_to_start' INICIADO COM SUCESSO!"
    echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
}

# Esta função gera uma página HTML com um estilo ciberpunk para os servidores Apache e Nginx.
generate_cyberpunk_html() {
    local server_name="$1"
    local output_file="$2"

    cat > "$output_file" <<EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ByteBabe $server_name Server</title>
    <style>
        body {
            background-color: #0a0a0a;
            color: #00ff00;
            font-family: 'Courier New', monospace;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            overflow: hidden;
        }
        .container {
            text-align: center;
            animation: glitch 1s infinite;
        }
        h1 {
            font-size: 3em;
            text-shadow: 0 0 5px #00ff00, 0 0 10px #00ff00, 0 0 15px #00ff00;
        }
        @keyframes glitch {
            0% { transform: translate(0) }
            20% { transform: translate(-2px, 2px) }
            40% { transform: translate(-2px, -2px) }
            60% { transform: translate(2px, 2px) }
            80% { transform: translate(2px, -2px) }
            100% { transform: translate(0) }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>ByteBabe $server_name Server</h1>
        <p>Bem-vindo ao futuro da web!</p>
    </div>
</body>
</html>
EOF

    echo -e "${CYBER_GREEN}✔ Página HTML gerada para $server_name em ${CYBER_CYAN}$output_file${RESET}"
}

# Esta função gera a configuração padrão do Nginx.
generate_nginx_config() {
    local nginx_conf="$DOCKER_DIR/nginx/nginx.conf"
    mkdir -p "$(dirname "$nginx_conf")"

    cat > "$nginx_conf" <<EOF
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }
    }
}
EOF

    echo -e "${CYBER_GREEN}✔ Configuração do Nginx gerada em ${CYBER_CYAN}$nginx_conf${RESET}"
}

# Esta função gera o arquivo 'docker-compose.yml' com a configuração dos servidores Apache e Nginx.
generate_docker_compose() {
    echo -e "\n${CYBER_BLUE}▶ Gerando configuração Docker Compose...${RESET}"

    # Cria estrutura de diretórios
    create_directory "$DOCKER_DIR/apache"
    create_directory "$DOCKER_DIR/nginx"
    create_directory "$DOCKER_DIR/ssl"

    # Gera arquivos HTML
    generate_cyberpunk_html "Apache" "$DOCKER_DIR/apache/index.html"
    generate_cyberpunk_html "Nginx" "$DOCKER_DIR/nginx/index.html"

    # Gera configuração do Nginx
    generate_nginx_config

    # Gera docker-compose.yml moderno (sem version)
    cat > "$COMPOSE_FILE" <<EOF
services:
  apache:
    image: httpd:latest
    container_name: "${PROJECT_NAME}_apache"
    ports:
      - "${APACHE_PORT}:80"
    volumes:
      - "${DOCKER_DIR}/apache:/usr/local/apache2/htdocs"
      - "${DOCKER_DIR}/ssl:/ssl"
    networks:
      - bytebabe_net
    restart: unless-stopped

  nginx:
    image: nginx:latest
    container_name: "${PROJECT_NAME}_nginx"
    ports:
      - "${NGINX_PORT}:80"
      - "${SSL_PORT}:443"
    volumes:
      - "${DOCKER_DIR}/nginx:/usr/share/nginx/html"
      - "${DOCKER_DIR}/ssl:/ssl"
      - "${DOCKER_DIR}/nginx/nginx.conf:/etc/nginx/nginx.conf:ro"
    networks:
      - bytebabe_net
    restart: unless-stopped

networks:
  bytebabe_net:
    driver: bridge
EOF

    echo -e "${CYBER_GREEN}✔ Configuração gerada em ${CYBER_CYAN}$COMPOSE_FILE${RESET}"
}

# Esta função inicia um servidor Docker (Apache ou Nginx) usando o Docker Compose.
start_servers() {
    local server_to_start="$1"

    check_docker_installed
    check_compose_file

    echo -e "\n${CYBER_BLUE}▶ Iniciando servidor Docker '$server_to_start'...${RESET}"

    if $COMPOSE_CMD -f "$COMPOSE_FILE" up -d "$server_to_start"; then
        show_success_message "$server_to_start"
    else
        echo -e "\n${CYBER_RED}✘ Erro ao iniciar servidor '$server_to_start'!${RESET}"
        echo -e "${CYBER_YELLOW}▶ Verificando logs...${RESET}"
        $COMPOSE_CMD -f "$COMPOSE_FILE" logs "$server_to_start"
        exit 1
    fi
}

# Esta função para um servidor Docker (Apache ou Nginx) ou todos os servidores usando o Docker Compose.
stop_servers() {
    check_docker_installed

    local server_to_stop="$1"

    echo -e "\n${CYBER_BLUE}▶ Parando servidores...${RESET}"

    if [ ! -f "$COMPOSE_FILE" ]; then
        echo -e "${CYBER_YELLOW}⚠ Nenhum servidor está em execução (docker-compose.yml não encontrado)${RESET}"
        return
    fi

    if [ -n "$server_to_stop" ]; then
        if [ "$server_to_stop" = "apache" ] || [ "$server_to_stop" = "nginx" ]; then
            echo -e "${CYBER_BLUE}Parando servidor $server_to_stop...${RESET}"
            $COMPOSE_CMD -f "$COMPOSE_FILE" stop "$server_to_stop"
            $COMPOSE_CMD -f "$COMPOSE_FILE" rm -f "$server_to_stop"
            echo -e "${CYBER_GREEN}✔ Servidor $server_to_stop parado com sucesso!${RESET}"
        else
            echo -e "${CYBER_RED}✘ Servidor inválido. Use 'apache' ou 'nginx'.${RESET}"
            return 1
        fi
    else
        $COMPOSE_CMD -f "$COMPOSE_FILE" down
        echo -e "\n${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
        echo -e "${CYBER_GREEN}           TODOS OS SERVIDORES PARADOS COM SUCESSO!"
        echo -e "${CYBER_PINK}═════════════════════════════════════════════════${RESET}"
    fi
}

# Esta função exibe o status dos servidores Docker em execução.
server_status() {
    local server_to_check="$1"

    check_docker_installed

    echo -e "\n${CYBER_BLUE}▶ Status dos servidores:${RESET}"

    if [ ! -f "$COMPOSE_FILE" ]; then
        echo -e "${CYBER_YELLOW}⚠ Nenhum servidor configurado (docker-compose.yml não encontrado)${RESET}"
        echo -e "${CYBER_GREEN}Execute 'bytebabe servers setup' para configurar.${RESET}"
        return
    fi

    if [ -n "$server_to_check" ]; then
        local containers
        containers=$($COMPOSE_CMD -f "$COMPOSE_FILE" ps -a --filter "name=$server_to_check" --format "{{.ID}}" 2>/dev/null)

        if [ -z "$containers" ]; then
            echo -e "${CYBER_YELLOW}⚠ Nenhum container encontrado para o servidor '$server_to_check'${RESET}"
            echo -e "${CYBER_GREEN}Execute 'bytebabe servers up $server_to_check' para iniciá-lo.${RESET}"
            return
        fi

        echo -e "\n${CYBER_GREEN}CONTAINER ID   NOME             STATUS          PORTAS${RESET}"
        $COMPOSE_CMD -f "$COMPOSE_FILE" ps -a --filter "name=$server_to_check" | tail -n +2 | while read -r line; do
            if [ -n "$line" ]; then
                container_id=$(echo "$line" | awk '{print $1}')
                name=$(echo "$line" | awk '{print $2}')
                status=$(echo "$line" | awk '{print $3}')
                ports=$(echo "$line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//')

                printf "${CYBER_PINK}%-12s${RESET} ${CYBER_BLUE}%-16s${RESET} ${CYBER_GREEN}%-14s${RESET} ${CYBER_YELLOW}%s${RESET}\n" \
                       "${container_id:0:12}" "$name" "$status" "$ports"
            fi
        done
    else
        local containers
        containers=$($COMPOSE_CMD -f "$COMPOSE_FILE" ps -a --format "{{.ID}}" 2>/dev/null)

        if [ -z "$containers" ]; then
            echo -e "${CYBER_YELLOW}⚠ Nenhum container encontrado${RESET}"
            echo -e "${CYBER_GREEN}Execute 'bytebabe servers up' para iniciá-los.${RESET}"
            return
        fi

        echo -e "\n${CYBER_GREEN}CONTAINER ID   NOME             STATUS          PORTAS${RESET}"
        $COMPOSE_CMD -f "$COMPOSE_FILE" ps -a | tail -n +2 | while read -r line; do
            if [ -n "$line" ]; then
                container_id=$(echo "$line" | awk '{print $1}')
                name=$(echo "$line" | awk '{print $2}')
                status=$(echo "$line" | awk '{print $3}')
                ports=$(echo "$line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//')

                printf "${CYBER_PINK}%-12s${RESET} ${CYBER_BLUE}%-16s${RESET} ${CYBER_GREEN}%-14s${RESET} ${CYBER_YELLOW}%s${RESET}\n" \
                       "${container_id:0:12}" "$name" "$status" "$ports"
            fi
        done
    fi
}