#!/bin/bash

# ByteBabe CLI - Funções Auxiliares para Testes
# Descrição: Funções compartilhadas para todos os testes

set -euo pipefail

# Cores para output
readonly CYBER_RED='\033[0;31m'
readonly CYBER_GREEN='\033[0;32m'
readonly CYBER_YELLOW='\033[1;33m'
readonly CYBER_BLUE='\033[0;34m'
readonly CYBER_PURPLE='\033[0;35m'
readonly CYBER_CYAN='\033[0;36m'
readonly RESET='\033[0m'

# Diretórios base
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TESTS_DIR="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_ROOT="$(dirname "$TESTS_DIR")"

# Configurações
readonly TEST_CONFIG_FILE="$TESTS_DIR/config/test.env"
readonly TEST_REPORTS_DIR="$TESTS_DIR/reports"
readonly TEST_FIXTURES_DIR="$TESTS_DIR/fixtures"

# Função para log
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO") echo -e "${CYBER_BLUE}[$timestamp] ℹ $message${RESET}" ;;
        "SUCCESS") echo -e "${CYBER_GREEN}[$timestamp] ✔ $message${RESET}" ;;
        "WARNING") echo -e "${CYBER_YELLOW}[$timestamp] ⚠ $message${RESET}" ;;
        "ERROR") echo -e "${CYBER_RED}[$timestamp] ✗ $message${RESET}" ;;
        *) echo "[$timestamp] $message" ;;
    esac
}

# Função para verificar se o ByteBabe CLI está disponível
check_bytebabe_available() {
    local bytebabe_bin="$PROJECT_ROOT/bin/bytebabe"
    
    if [ ! -f "$bytebabe_bin" ]; then
        log "ERROR" "ByteBabe CLI não encontrado: $bytebabe_bin"
        return 1
    fi
    
    if [ ! -x "$bytebabe_bin" ]; then
        log "WARNING" "ByteBabe CLI não é executável, ajustando permissões..."
        chmod +x "$bytebabe_bin"
    fi
    
    return 0
}

# Função para executar comando ByteBabe e capturar saída
run_bytebabe() {
    local bytebabe_bin="$PROJECT_ROOT/bin/bytebabe"
    local output_file="$1"
    local error_file="$2"
    shift 2
    
    if ! check_bytebabe_available; then
        return 1
    fi
    
    "$bytebabe_bin" "$@" > "$output_file" 2> "$error_file"
    return $?
}

# Função para verificar se Docker está disponível
check_docker_available() {
    if ! command -v docker &> /dev/null; then
        log "WARNING" "Docker não está disponível"
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        log "WARNING" "Docker não está rodando"
        return 1
    fi
    
    return 0
}

# Função para criar container de teste
create_test_container() {
    local container_name="$1"
    local image="${2:-alpine:latest}"
    local command="${3:-sleep 100}"
    
    if ! check_docker_available; then
        return 1
    fi
    
    docker run -d --name "$container_name" "$image" $command > /dev/null 2>&1
    return $?
}

# Função para remover container de teste
remove_test_container() {
    local container_name="$1"
    
    if ! check_docker_available; then
        return 1
    fi
    
    docker rm -f "$container_name" > /dev/null 2>&1
    return $?
}

# Função para limpar containers de teste
cleanup_test_containers() {
    local prefix="${1:-bytebabe-test}"
    
    if ! check_docker_available; then
        return 1
    fi
    
    docker ps -a --filter "name=$prefix" --format "{{.ID}}" | xargs -r docker rm -f > /dev/null 2>&1
    return 0
}

# Função para verificar se arquivo JSON é válido
is_valid_json() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    if ! command -v jq &> /dev/null; then
        log "WARNING" "jq não está disponível, não é possível validar JSON"
        return 0
    fi
    
    jq . "$file" > /dev/null 2>&1
    return $?
}

# Função para carregar dados de teste
load_test_data() {
    local data_file="$TEST_FIXTURES_DIR/data/$1"
    
    if [ ! -f "$data_file" ]; then
        log "ERROR" "Arquivo de dados de teste não encontrado: $data_file"
        return 1
    fi
    
    if ! is_valid_json "$data_file"; then
        log "ERROR" "Arquivo de dados de teste não é JSON válido: $data_file"
        return 1
    fi
    
    cat "$data_file"
    return 0
}

# Função para carregar configuração de teste
load_test_config() {
    local config_name="$1"
    local config_file="$TEST_FIXTURES_DIR/configs/$config_name"
    
    if [ ! -f "$config_file" ]; then
        log "ERROR" "Arquivo de configuração de teste não encontrado: $config_file"
        return 1
    fi
    
    if ! is_valid_json "$config_file"; then
        log "ERROR" "Arquivo de configuração de teste não é JSON válido: $config_file"
        return 1
    fi
    
    cat "$config_file"
    return 0
}

# Função para criar diretório temporário
create_temp_dir() {
    local prefix="${1:-bytebabe-test}"
    local temp_dir
    
    temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/${prefix}.XXXXXXXXXX")
    echo "$temp_dir"
}

# Função para limpar diretório temporário
cleanup_temp_dir() {
    local temp_dir="$1"
    
    if [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
    fi
}

# Função para aguardar até que condição seja verdadeira
wait_for_condition() {
    local condition="$1"
    local timeout="${2:-30}"
    local interval="${3:-1}"
    local elapsed=0
    
    while [ $elapsed -lt $timeout ]; do
        if eval "$condition"; then
            return 0
        fi
        
        sleep $interval
        elapsed=$((elapsed + interval))
    done
    
    return 1
}

# Função para aguardar até que porta esteja disponível
wait_for_port() {
    local host="$1"
    local port="$2"
    local timeout="${3:-30}"
    
    wait_for_condition "nc -z $host $port" "$timeout"
    return $?
}

# Função para aguardar até que container esteja rodando
wait_for_container() {
    local container_name="$1"
    local timeout="${2:-30}"
    
    wait_for_condition "docker ps --filter name=$container_name --filter status=running --format '{{.Names}}' | grep -q $container_name" "$timeout"
    return $?
}

# Função para medir tempo de execução
measure_execution_time() {
    local command="$1"
    local start_time
    local end_time
    local execution_time
    
    start_time=$(date +%s%N)
    eval "$command"
    local exit_code=$?
    end_time=$(date +%s%N)
    
    execution_time=$(( (end_time - start_time) / 1000000 ))  # em milissegundos
    
    echo "$execution_time"
    return $exit_code
}

# Função para verificar se processo está rodando
is_process_running() {
    local process_name="$1"
    
    pgrep -f "$process_name" > /dev/null 2>&1
    return $?
}

# Função para contar processos
count_processes() {
    local process_name="$1"
    
    pgrep -c -f "$process_name" 2>/dev/null || echo "0"
}

# Função para verificar se arquivo contém texto
file_contains() {
    local file="$1"
    local text="$2"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    grep -q "$text" "$file"
    return $?
}

# Função para verificar se arquivo não está vazio
file_not_empty() {
    local file="$1"
    
    [ -f "$file" ] && [ -s "$file" ]
    return $?
}

# Função para verificar se arquivo está vazio
file_is_empty() {
    local file="$1"
    
    [ -f "$file" ] && [ ! -s "$file" ]
    return $?
}

# Função para verificar se diretório existe
directory_exists() {
    local dir="$1"
    
    [ -d "$dir" ]
    return $?
}

# Função para verificar se arquivo existe
file_exists() {
    local file="$1"
    
    [ -f "$file" ]
    return $?
}

# Função para verificar se arquivo é executável
file_is_executable() {
    local file="$1"
    
    [ -f "$file" ] && [ -x "$file" ]
    return $?
}

# Função para gerar dados aleatórios
generate_random_data() {
    local length="${1:-10}"
    local charset="${2:-a-zA-Z0-9}"
    
    tr -dc "$charset" < /dev/urandom | head -c "$length"
}

# Função para gerar nome único
generate_unique_name() {
    local prefix="${1:-test}"
    local suffix
    
    suffix=$(generate_random_data 8)
    echo "${prefix}-${suffix}"
}

# Função para verificar se comando existe
command_exists() {
    local command="$1"
    
    command -v "$command" > /dev/null 2>&1
    return $?
}

# Função para verificar se comando está no PATH
command_in_path() {
    local command="$1"
    
    which "$command" > /dev/null 2>&1
    return $?
}

# Função para verificar versão do comando
get_command_version() {
    local command="$1"
    
    if ! command_exists "$command"; then
        return 1
    fi
    
    "$command" --version 2>/dev/null || "$command" -v 2>/dev/null || echo "unknown"
}

# Função para verificar se sistema é Linux
is_linux() {
    [ "$(uname -s)" = "Linux" ]
    return $?
}

# Função para verificar se sistema é macOS
is_macos() {
    [ "$(uname -s)" = "Darwin" ]
    return $?
}

# Função para verificar se usuário é root
is_root() {
    [ "$(id -u)" -eq 0 ]
    return $?
}

# Função para verificar se usuário tem sudo
has_sudo() {
    sudo -n true 2>/dev/null
    return $?
}

# Função para obter informações do sistema
get_system_info() {
    cat << EOF
System: $(uname -s)
Architecture: $(uname -m)
Kernel: $(uname -r)
User: $(whoami)
Home: $HOME
PWD: $(pwd)
Shell: $SHELL
EOF
}

# Função para obter informações do ambiente
get_environment_info() {
    cat << EOF
PATH: $PATH
LANG: ${LANG:-not set}
LC_ALL: ${LC_ALL:-not set}
TZ: ${TZ:-not set}
USER: ${USER:-not set}
LOGNAME: ${LOGNAME:-not set}
HOSTNAME: ${HOSTNAME:-not set}
EOF
}

# Função para criar relatório de teste
create_test_report() {
    local test_name="$1"
    local test_result="$2"
    local test_duration="$3"
    local test_output="$4"
    local test_error="$5"
    local report_file="$TEST_REPORTS_DIR/test-report.json"
    
    local report_data
    report_data=$(cat << EOF
{
  "test_name": "$test_name",
  "result": "$test_result",
  "duration_ms": $test_duration,
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "output": $(jq -R . <<< "$test_output"),
  "error": $(jq -R . <<< "$test_error")
}
EOF
)
    
    mkdir -p "$(dirname "$report_file")"
    
    if [ -f "$report_file" ]; then
        # Adicionar ao array existente
        jq --argjson new "$report_data" '.tests += [$new]' "$report_file" > "${report_file}.tmp"
        mv "${report_file}.tmp" "$report_file"
    else
        # Criar novo arquivo
        echo "{\"tests\": [$report_data]}" > "$report_file"
    fi
}

# Função para gerar resumo de testes
generate_test_summary() {
    local report_file="$TEST_REPORTS_DIR/test-report.json"
    
    if [ ! -f "$report_file" ]; then
        log "WARNING" "Arquivo de relatório não encontrado: $report_file"
        return 1
    fi
    
    local total_tests
    local passed_tests
    local failed_tests
    
    total_tests=$(jq '.tests | length' "$report_file")
    passed_tests=$(jq '.tests | map(select(.result == "PASS")) | length' "$report_file")
    failed_tests=$(jq '.tests | map(select(.result == "FAIL")) | length' "$report_file")
    
    cat << EOF
=== Resumo de Testes ===
Total: $total_tests
Passou: $passed_tests
Falhou: $failed_tests
Taxa de Sucesso: $(( (passed_tests * 100) / total_tests ))%
EOF
}

# Função para limpar relatórios
cleanup_reports() {
    if [ -d "$TEST_REPORTS_DIR" ]; then
        rm -rf "$TEST_REPORTS_DIR"/*
        log "SUCCESS" "Relatórios limpos"
    else
        log "INFO" "Nenhum relatório para limpar"
    fi
}

# Função para verificar dependências de teste
check_test_dependencies() {
    local missing_deps=()
    
    # Verificar BATS
    if ! command_exists bats; then
        missing_deps+=("bats")
    fi
    
    # Verificar ShellCheck
    if ! command_exists shellcheck; then
        missing_deps+=("shellcheck")
    fi
    
    # Verificar jq
    if ! command_exists jq; then
        missing_deps+=("jq")
    fi
    
    # Verificar Docker (opcional)
    if ! check_docker_available; then
        log "WARNING" "Docker não disponível - alguns testes podem falhar"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log "ERROR" "Dependências faltando: ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

# Função para executar setup de teste
run_test_setup() {
    log "INFO" "Executando setup de teste..."
    
    if ! check_test_dependencies; then
        log "ERROR" "Dependências de teste não atendidas"
        return 1
    fi
    
    # Criar diretórios necessários
    mkdir -p "$TEST_REPORTS_DIR"
    mkdir -p "$TEST_FIXTURES_DIR"
    
    # Limpar relatórios anteriores
    cleanup_reports
    
    log "SUCCESS" "Setup de teste concluído"
    return 0
}

# Função para executar teardown de teste
run_test_teardown() {
    log "INFO" "Executando teardown de teste..."
    
    # Limpar containers de teste
    cleanup_test_containers
    
    # Gerar resumo se houver relatórios
    if [ -f "$TEST_REPORTS_DIR/test-report.json" ]; then
        generate_test_summary
    fi
    
    log "SUCCESS" "Teardown de teste concluído"
}

# Função para executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        "setup")
            run_test_setup
            ;;
        "teardown")
            run_test_teardown
            ;;
        "check-deps")
            check_test_dependencies
            ;;
        "cleanup")
            cleanup_reports
            cleanup_test_containers
            ;;
        *)
            echo "Uso: $0 {setup|teardown|check-deps|cleanup}"
            exit 1
            ;;
    esac
fi 