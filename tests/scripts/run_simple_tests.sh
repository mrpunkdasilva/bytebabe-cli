#!/bin/bash

# ByteBabe CLI - Runner de Testes Simples
# Descrição: Executa testes sem dependência do BATS

set -euo pipefail

# Cores
readonly CYBER_RED='\033[0;31m'
readonly CYBER_GREEN='\033[0;32m'
readonly CYBER_BLUE='\033[0;34m'
readonly RESET='\033[0m'

# Diretórios
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TESTS_DIR="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_ROOT="$(dirname "$TESTS_DIR")"
readonly BYTEBABE_BIN="$PROJECT_ROOT/bin/bytebabe"

# Contadores
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

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
    local expected_output="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando: $test_name... "
    
    if output=$(eval "$test_command" 2>&1); then
        if [[ "$output" == *"$expected_output"* ]]; then
            echo -e "${CYBER_GREEN}PASS${RESET}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            return 0
        else
            echo -e "${CYBER_RED}FAIL${RESET}"
            echo "  Esperado: $expected_output"
            echo "  Obtido: $output"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            return 1
        fi
    else
        echo -e "${CYBER_RED}FAIL${RESET}"
        echo "  Erro: $output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Testes básicos
run_basic_tests() {
    log "INFO" "Executando testes básicos..."
    
    # Teste 1: Comando hello sem argumentos
    run_test "hello sem argumentos" \
        "$BYTEBABE_BIN hello" \
        "Hello"
    
    # Teste 2: Comando hello com argumento
    run_test "hello com argumento" \
        "$BYTEBABE_BIN hello TestUser" \
        "Hello"
    
    # Teste 3: Comando help
    run_test "comando help" \
        "$BYTEBABE_BIN --help" \
        "bytebabe"
    
    # Teste 4: Verificar se é executável
    if [ -x "$BYTEBABE_BIN" ]; then
        echo -e "Testando: executável... ${CYBER_GREEN}PASS${RESET}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "Testando: executável... ${CYBER_RED}FAIL${RESET}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

# Mostrar resumo
show_summary() {
    echo
    log "INFO" "=== Resumo dos Testes ==="
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "Todos os testes passaram!"
        exit 0
    else
        log "ERROR" "Alguns testes falharam"
        exit 1
    fi
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando testes simples do ByteBabe CLI..."
    
    if [ ! -f "$BYTEBABE_BIN" ]; then
        log "ERROR" "ByteBabe CLI não encontrado: $BYTEBABE_BIN"
        exit 1
    fi
    
    run_basic_tests
    show_summary
}

main "$@"
