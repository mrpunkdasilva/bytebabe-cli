#!/usr/bin/env bats

# ByteBabe CLI - Teste de Integração: Docker
# Descrição: Testa as funcionalidades Docker do ByteBabe CLI

setup() {
    # Configurar ambiente de teste
    export BYTEBABE_TEST_MODE=true
    
    # Diretórios base
    export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export TESTS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
    export PROJECT_ROOT="$(dirname "$TESTS_DIR")"
    
    # Caminho para o bytebabe
    export BYTEBABE_BIN="$PROJECT_ROOT/bin/bytebabe"
    
    # Verificar se o bytebabe existe
    if [ ! -f "$BYTEBABE_BIN" ]; then
        skip "ByteBabe CLI não encontrado: $BYTEBABE_BIN"
    fi
    
    # Verificar se Docker está disponível
    if ! command -v docker &> /dev/null; then
        skip "Docker não está disponível"
    fi
    
    # Verificar se Docker está rodando
    if ! docker info &> /dev/null; then
        skip "Docker não está rodando"
    fi
    
    # Criar rede de teste
    export TEST_NETWORK="bytebabe-test-network"
    docker network create "$TEST_NETWORK" 2>/dev/null || true
    
    # Criar diretório temporário para testes
    export TEST_TMP_DIR="$(mktemp -d)"
    export TEST_OUTPUT_FILE="$TEST_TMP_DIR/output.txt"
    export TEST_ERROR_FILE="$TEST_TMP_DIR/error.txt"
    
    # Limpar containers de teste anteriores
    docker ps -a --filter "name=bytebabe-test" --format "{{.ID}}" | xargs -r docker rm -f
}

teardown() {
    # Limpar containers de teste
    docker ps -a --filter "name=bytebabe-test" --format "{{.ID}}" | xargs -r docker rm -f
    
    # Remover rede de teste
    docker network rm "$TEST_NETWORK" 2>/dev/null || true
    
    # Limpar arquivos temporários
    if [ -d "$TEST_TMP_DIR" ]; then
        rm -rf "$TEST_TMP_DIR"
    fi
}

# Teste: Verificar se o comando docker existe
@test "docker command exists" {
    run "$BYTEBABE_BIN" --help
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"docker"* ]]
}

# Teste: Listar containers
@test "docker containers list" {
    run "$BYTEBABE_BIN" docker containers list
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"CONTAINER"* ]] || [[ "$output" == *"container"* ]]
}

# Teste: Listar containers com flag --all
@test "docker containers list --all" {
    run "$BYTEBABE_BIN" docker containers list --all
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"CONTAINER"* ]] || [[ "$output" == *"container"* ]]
}

# Teste: Listar imagens
@test "docker images list" {
    run "$BYTEBABE_BIN" docker images list
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"IMAGE"* ]] || [[ "$output" == *"image"* ]]
}

# Teste: Pull de imagem
@test "docker images pull" {
    # Usar uma imagem pequena para teste
    run "$BYTEBABE_BIN" docker images pull alpine:latest
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"alpine"* ]] || [[ "$output" == *"pulled"* ]]
}

# Teste: Executar container
@test "docker containers run" {
    # Executar container temporário
    run "$BYTEBABE_BIN" docker containers run --name bytebabe-test-alpine alpine:latest echo "test"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"test"* ]]
}

# Teste: Parar container
@test "docker containers stop" {
    # Primeiro, criar um container
    "$BYTEBABE_BIN" docker containers run --name bytebabe-test-stop alpine:latest sleep 100 &
    local container_pid=$!
    
    # Aguardar um pouco para o container iniciar
    sleep 2
    
    # Parar o container
    run "$BYTEBABE_BIN" docker containers stop bytebabe-test-stop
    
    # Limpar processo
    kill $container_pid 2>/dev/null || true
    
    [ "$status" -eq 0 ]
}

# Teste: Remover container
@test "docker containers remove" {
    # Criar container temporário
    "$BYTEBABE_BIN" docker containers run --name bytebabe-test-remove alpine:latest echo "test" > /dev/null
    
    # Remover container
    run "$BYTEBABE_BIN" docker containers remove bytebabe-test-remove
    
    [ "$status" -eq 0 ]
}

# Teste: Verificar status do container
@test "docker containers status" {
    # Criar container em background
    "$BYTEBABE_BIN" docker containers run --name bytebabe-test-status -d alpine:latest sleep 10
    
    # Verificar status
    run "$BYTEBABE_BIN" docker containers status bytebabe-test-status
    
    # Limpar
    "$BYTEBABE_BIN" docker containers stop bytebabe-test-status > /dev/null 2>&1
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"running"* ]] || [[ "$output" == *"Up"* ]]
}

# Teste: Listar volumes
@test "docker volumes list" {
    run "$BYTEBABE_BIN" docker volumes list
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"VOLUME"* ]] || [[ "$output" == *"volume"* ]]
}

# Teste: Criar volume
@test "docker volumes create" {
    local volume_name="bytebabe-test-volume"
    
    run "$BYTEBABE_BIN" docker volumes create "$volume_name"
    
    # Limpar
    docker volume rm "$volume_name" 2>/dev/null || true
    
    [ "$status" -eq 0 ]
}

# Teste: Remover volume
@test "docker volumes remove" {
    local volume_name="bytebabe-test-volume-remove"
    
    # Criar volume primeiro
    docker volume create "$volume_name" > /dev/null
    
    # Remover volume
    run "$BYTEBABE_BIN" docker volumes remove "$volume_name"
    
    [ "$status" -eq 0 ]
}

# Teste: Docker Compose up
@test "docker compose up" {
    # Criar docker-compose.yml temporário
    cat > "$TEST_TMP_DIR/docker-compose.yml" << 'EOF'
version: '3.8'
services:
  test-service:
    image: alpine:latest
    container_name: bytebabe-test-compose
    command: echo "compose test"
EOF

    # Executar compose
    run "$BYTEBABE_BIN" docker compose up -f "$TEST_TMP_DIR/docker-compose.yml"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"compose test"* ]]
}

# Teste: Docker Compose down
@test "docker compose down" {
    # Criar docker-compose.yml temporário
    cat > "$TEST_TMP_DIR/docker-compose.yml" << 'EOF'
version: '3.8'
services:
  test-service:
    image: alpine:latest
    container_name: bytebabe-test-compose-down
    command: sleep 100
EOF

    # Iniciar compose em background
    "$BYTEBABE_BIN" docker compose up -f "$TEST_TMP_DIR/docker-compose.yml" -d > /dev/null
    
    # Aguardar um pouco
    sleep 2
    
    # Parar compose
    run "$BYTEBABE_BIN" docker compose down -f "$TEST_TMP_DIR/docker-compose.yml"
    
    [ "$status" -eq 0 ]
}

# Teste: Verificar logs do container
@test "docker containers logs" {
    # Criar container que gera logs
    "$BYTEBABE_BIN" docker containers run --name bytebabe-test-logs alpine:latest echo "test log message" > /dev/null
    
    # Verificar logs
    run "$BYTEBABE_BIN" docker containers logs bytebabe-test-logs
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"test log message"* ]]
}

# Teste: Executar comando em container
@test "docker containers exec" {
    # Criar container em background
    "$BYTEBABE_BIN" docker containers run --name bytebabe-test-exec -d alpine:latest sleep 10
    
    # Executar comando no container
    run "$BYTEBABE_BIN" docker containers exec bytebabe-test-exec echo "exec test"
    
    # Limpar
    "$BYTEBABE_BIN" docker containers stop bytebabe-test-exec > /dev/null 2>&1
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"exec test"* ]]
}

# Teste: Verificar informações do sistema Docker
@test "docker system info" {
    run "$BYTEBABE_BIN" docker system info
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Docker"* ]] || [[ "$output" == *"docker"* ]]
}

# Teste: Limpar sistema Docker
@test "docker system prune" {
    run "$BYTEBABE_BIN" docker system prune --force
    
    [ "$status" -eq 0 ]
}

# Teste: Verificar uso de recursos
@test "docker system stats" {
    # Criar container para ter algo para monitorar
    "$BYTEBABE_BIN" docker containers run --name bytebabe-test-stats -d alpine:latest sleep 10
    
    # Verificar stats
    run "$BYTEBABE_BIN" docker system stats --no-stream
    
    # Limpar
    "$BYTEBABE_BIN" docker containers stop bytebabe-test-stats > /dev/null 2>&1
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"CONTAINER"* ]] || [[ "$output" == *"container"* ]]
}

# Teste: Verificar rede
@test "docker network list" {
    run "$BYTEBABE_BIN" docker network list
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"NETWORK"* ]] || [[ "$output" == *"network"* ]]
}

# Teste: Criar rede
@test "docker network create" {
    local network_name="bytebabe-test-network-create"
    
    run "$BYTEBABE_BIN" docker network create "$network_name"
    
    # Limpar
    docker network rm "$network_name" 2>/dev/null || true
    
    [ "$status" -eq 0 ]
}

# Teste: Remover rede
@test "docker network remove" {
    local network_name="bytebabe-test-network-remove"
    
    # Criar rede primeiro
    docker network create "$network_name" > /dev/null
    
    # Remover rede
    run "$BYTEBABE_BIN" docker network remove "$network_name"
    
    [ "$status" -eq 0 ]
}

# Teste: Verificar se comandos Docker funcionam com redirecionamento
@test "docker commands work with redirection" {
    run "$BYTEBABE_BIN" docker containers list > "$TEST_OUTPUT_FILE" 2> "$TEST_ERROR_FILE"
    
    [ "$status" -eq 0 ]
    [ -f "$TEST_OUTPUT_FILE" ]
    [ -s "$TEST_OUTPUT_FILE" ]
    
    local output_content
    output_content=$(cat "$TEST_OUTPUT_FILE")
    [[ "$output_content" == *"CONTAINER"* ]] || [[ "$output_content" == *"container"* ]]
}

# Teste: Verificar se comandos Docker não geram erros em stderr
@test "docker commands produce no stderr output" {
    run "$BYTEBABE_BIN" docker containers list 2> "$TEST_ERROR_FILE"
    
    [ "$status" -eq 0 ]
    [ -f "$TEST_ERROR_FILE" ]
    [ ! -s "$TEST_ERROR_FILE" ]
}

# Teste: Verificar performance dos comandos Docker
@test "docker commands performance" {
    local start_time
    local end_time
    local execution_time
    
    start_time=$(date +%s%N)
    run "$BYTEBABE_BIN" docker containers list
    end_time=$(date +%s%N)
    
    execution_time=$(( (end_time - start_time) / 1000000 ))
    
    [ "$status" -eq 0 ]
    # Comandos Docker devem executar em menos de 5 segundos
    [ "$execution_time" -lt 5000 ]
}

# Teste: Verificar se comandos Docker funcionam em diferentes diretórios
@test "docker commands work from different directories" {
    local original_dir
    local temp_dir
    
    original_dir=$(pwd)
    temp_dir=$(mktemp -d)
    
    cd "$temp_dir"
    run "$BYTEBABE_BIN" docker containers list
    cd "$original_dir"
    
    rm -rf "$temp_dir"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"CONTAINER"* ]] || [[ "$output" == *"container"* ]]
}

# Teste: Verificar se comandos Docker respeitam variáveis de ambiente
@test "docker commands respect environment variables" {
    export BYTEBABE_TEST_MODE=true
    export BYTEBABE_VERBOSE=true
    
    run "$BYTEBABE_BIN" docker containers list
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"CONTAINER"* ]] || [[ "$output" == *"container"* ]]
} 