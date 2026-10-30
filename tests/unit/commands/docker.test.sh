#!/bin/bash

# Teste unitário para o comando docker do ByteBabe CLI
# Descrição: Testa a estrutura e funcionalidades do comando docker

set -euo pipefail

# Configuração do ambiente de teste
readonly BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
readonly TEST_TEMP_DIR="$(mktemp -d)"
readonly HOME="$TEST_TEMP_DIR"

# Contadores
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Cores
readonly CYBER_RED='\033[0;31m'
readonly CYBER_GREEN='\033[0;32m'
readonly CYBER_BLUE='\033[0;34m'
readonly RESET='\033[0m'

# Função para log
log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "INFO") echo -e "${CYBER_BLUE}ℹ $message${RESET}" ;;
        "SUCCESS") echo -e "${CYBER_GREEN}✔ $message${RESET}" ;;
        "ERROR") echo -e "${CYBER_RED}✗ $message${RESET}" ;;
        *) echo "$message" ;;
    esac
}

# Função para executar teste
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando: $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${CYBER_GREEN}PASS${RESET}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${CYBER_RED}FAIL${RESET}"
        echo "  Esperado: $expected_result"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Setup do teste
setup() {
    # Cria diretório .bytebabe para testes
    mkdir -p "$HOME/.bytebabe"
    log "INFO" "Setup do teste docker concluído"
}

# Cleanup do teste
cleanup() {
    # Limpeza após cada teste
    rm -rf "$TEST_TEMP_DIR"
    log "INFO" "Cleanup do teste docker concluído"
}

# Testes do comando docker
test_docker_structure() {
    log "INFO" "Executando testes de estrutura do comando docker..."
    
    local docker_file="$BASE_DIR/commands/docker/main.sh"
    
    # Teste 1: Arquivo existe
    run_test "docker command exists" \
        "test -f '$docker_file'" \
        "arquivo docker.sh existe"
    
    # Teste 2: Arquivo é executável
    run_test "docker command is executable" \
        "test -x '$docker_file'" \
        "arquivo docker.sh é executável"
    
    # Teste 3: Contém função main
    run_test "docker has main function" \
        "grep -q 'main()' '$docker_file'" \
        "função main encontrada"
    
    # Teste 4: Contém case statement para comandos
    set +u
    run_test "docker has case statement for commands" \
        "grep -F 'case "$command"' '$docker_file'" \
        "case statement para comandos encontrado"
    set -u
    
    # Teste 5: Importa módulos necessários
    run_test "docker imports required modules" \
        "grep -q 'source.*colors.sh' '$docker_file'" \
        "módulo colors.sh importado"
    
    # Teste 6: Contém estilo cyberpunk
    run_test "docker has cyberpunk styling" \
        "grep -q 'CYBER_' '$docker_file'" \
        "estilo cyberpunk encontrado"
    
    # Teste 7: Contém funcionalidades de docker
    run_test "docker has docker functionality" \
        "grep -q 'docker\|container\|compose' '$docker_file'" \
        "funcionalidades de docker encontradas"
    
    # Teste 8: Contém gerenciamento de containers
    run_test "docker has container management" \
        "grep -q 'container_commander' '$docker_file'" \
        "gerenciamento de containers encontrado"
    
    # Teste 9: Contém ferramentas de build
    run_test "docker has build tools" \
        "grep -q 'build\|image' '$docker_file'" \
        "ferramentas de build encontradas"
    
    # Teste 10: Contém ajuda integrada
    run_test "docker has integrated help" \
        "grep -q 'show_docker_help' '$docker_file'" \
        "ajuda integrada encontrada"
}

# Função para mostrar resumo
show_summary() {
    echo
    log "INFO" "=== Resumo dos Testes do Comando Docker ==="
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "Todos os testes do comando docker passaram!"
        exit 0
    else
        log "ERROR" "Alguns testes do comando docker falharam"
        exit 1
    fi
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando testes unitários do comando docker..."
    
    setup
    test_docker_structure
    cleanup
    show_summary
}

# Executa se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi 