#!/bin/bash

# Teste unitário para o comando hello do ByteBabe CLI
# Descrição: Testa a estrutura e funcionalidades do comando hello

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
    log "INFO" "Setup do teste hello concluído"
}

# Cleanup do teste
cleanup() {
    # Limpeza após cada teste
    rm -rf "$TEST_TEMP_DIR"
    log "INFO" "Cleanup do teste hello concluído"
}

# Testes do comando hello
test_hello_structure() {
    log "INFO" "Executando testes de estrutura do comando hello..."
    
    local hello_file="$BASE_DIR/commands/hello/main.sh"
    
    # Teste 1: Arquivo existe
    run_test "hello command exists" \
        "test -f '$hello_file'" \
        "arquivo hello.sh existe"
    
    # Teste 2: Arquivo é executável
    run_test "hello command is executable" \
        "test -x '$hello_file'" \
        "arquivo hello.sh é executável"
    
    # Teste 3: Contém array de frases
    run_test "hello has quotes array" \
        "grep -q 'CYBER_QUOTES=' '$hello_file'" \
        "array CYBER_QUOTES encontrado"
    
    # Teste 4: Contém função de header
    run_test "hello has header function" \
        "grep -q 'show_hello_header()' '$hello_file'" \
        "função show_hello_header encontrada"
    
    # Teste 5: Contém função de frase aleatória
    run_test "hello has random quote function" \
        "grep -q 'show_random_quote()' '$hello_file'" \
        "função show_random_quote encontrada"
    
    # Teste 6: Contém função main
    run_test "hello has main function" \
        "grep -q 'main()' '$hello_file'" \
        "função main encontrada"
    
    # Teste 7: Contém estilo cyberpunk
    run_test "hello has cyberpunk styling" \
        "grep -q 'CYBER_' '$hello_file'" \
        "estilo cyberpunk encontrado"
    
    # Teste 8: Contém emojis
    run_test "hello has emojis" \
        "grep -q '🌆\|⚡\|🌍\|💻' '$hello_file'" \
        "emojis encontrados"
    
    # Teste 9: Contém frases cyberpunk
    run_test "hello has cyberpunk quotes" \
        "grep -q 'Wake up, samurai' '$hello_file'" \
        "frases cyberpunk encontradas"
    
    # Teste 10: Contém header personalizado
    run_test "hello has custom header" \
        "grep -q 'BYTEBABE SAYS HI' '$hello_file'" \
        "header personalizado encontrado"
}

# Função para mostrar resumo
show_summary() {
    echo
    log "INFO" "=== Resumo dos Testes do Comando Hello ==="
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "Todos os testes do comando hello passaram!"
        exit 0
    else
        log "ERROR" "Alguns testes do comando hello falharam"
        exit 1
    fi
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando testes unitários do comando hello..."
    
    setup
    test_hello_structure
    cleanup
    show_summary
}

# Executa se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi 