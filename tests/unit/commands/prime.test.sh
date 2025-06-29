#!/bin/bash

# Teste unitário para o comando prime do ByteBabe CLI
# Descrição: Testa a estrutura e funcionalidades do comando prime

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
    mkdir -p "$HOME/.bytebabe"
    log "INFO" "Setup do teste prime concluído"
}

# Cleanup do teste
cleanup() {
    rm -rf "$TEST_TEMP_DIR"
    log "INFO" "Cleanup do teste prime concluído"
}

# Testes do comando prime
test_prime_structure() {
    log "INFO" "Executando testes de estrutura do comando prime..."
    
    local prime_file="$BASE_DIR/commands/prime.sh"
    
    # Teste 1: Arquivo prime.sh existe
    run_test "prime.sh exists" \
        "test -f '$prime_file'" \
        "arquivo prime.sh existe"
    
    # Teste 2: Arquivo prime.sh é executável
    run_test "prime.sh is executable" \
        "test -x '$prime_file'" \
        "arquivo prime.sh é executável"
    
    # Teste 3: Contém dispatcher principal
    run_test "prime has main dispatcher" \
        "grep -q 'case \$1 in' '$prime_file'" \
        "dispatcher principal encontrado"
    
    # Teste 4: Importa módulos necessários
    run_test "prime imports required modules" \
        "grep -q 'source.*colors.sh' '$prime_file'" \
        "módulo colors.sh importado"
    
    # Teste 5: Contém estilo cyberpunk
    run_test "prime has cyberpunk styling" \
        "grep -q 'CYBER_' '$prime_file'" \
        "estilo cyberpunk encontrado"
    
    # Teste 6: Contém funcionalidades de package management
    run_test "prime has package management" \
        "grep -q 'upgrade\|install\|remove' '$prime_file'" \
        "gerenciamento de pacotes encontrado"
    
    # Teste 7: Contém funcionalidades de segurança
    run_test "prime has security features" \
        "grep -q 'scan\|firewall\|quarantine' '$prime_file'" \
        "funcionalidades de segurança encontradas"
    
    # Teste 8: Contém utilitários do sistema
    run_test "prime has system utilities" \
        "grep -q 'clean\|backup\|network' '$prime_file'" \
        "utilitários do sistema encontrados"
    
    # Teste 9: Contém controle de serviços
    run_test "prime has service control" \
        "grep -q 'service\|log' '$prime_file'" \
        "controle de serviços encontrado"
    
    # Teste 10: Contém informações do sistema
    run_test "prime has system info" \
        "grep -q 'list\|info\|stats' '$prime_file'" \
        "informações do sistema encontradas"
    
    # Teste 11: Contém sistema de ajuda
    run_test "prime has help system" \
        "grep -q 'help\|--help' '$prime_file'" \
        "sistema de ajuda encontrado"
    
    # Teste 12: Contém easter egg
    run_test "prime has easter egg" \
        "grep -q 'neo' '$prime_file'" \
        "easter egg encontrado"
}

# Função para mostrar resumo
show_summary() {
    echo
    log "INFO" "=== Resumo dos Testes do Comando Prime ==="
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "Todos os testes do comando prime passaram!"
        exit 0
    else
        log "ERROR" "Alguns testes do comando prime falharam"
        exit 1
    fi
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando testes unitários do comando prime..."
    
    setup
    test_prime_structure
    cleanup
    show_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi 