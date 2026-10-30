#!/bin/bash

# Teste unitário para o comando db do ByteBabe CLI
# Descrição: Testa a estrutura e funcionalidades do comando db

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
    log "INFO" "Setup do teste db concluído"
}

# Cleanup do teste
cleanup() {
    # Limpeza após cada teste
    rm -rf "$TEST_TEMP_DIR"
    log "INFO" "Cleanup do teste db concluído"
}

# Testes do comando db
test_db_structure() {
    log "INFO" "Executando testes de estrutura do comando db..."
    
    local db_file="$BASE_DIR/commands/db/main.sh"
    
    # Teste 1: Arquivo existe
    run_test "db command exists" \
        "test -f '$db_file'" \
        "arquivo db.sh existe"
    
    # Teste 2: Arquivo é executável
    run_test "db command is executable" \
        "test -x '$db_file'" \
        "arquivo db.sh é executável"
    
    # Teste 3: Contém case statement para comandos
    run_test "db has case statement for commands" \
        "grep -q 'case.*\$1' '$db_file'" \
        "case statement para comandos encontrado"
    
    # Teste 4: Importa módulos necessários
    run_test "db imports required modules" \
        "grep -q 'source.*colors.sh' '$db_file'" \
        "módulo colors.sh importado"
    
    # Teste 5: Contém estilo cyberpunk
    run_test "db has cyberpunk styling" \
        "grep -q 'CYBER_' '$db_file'" \
        "estilo cyberpunk encontrado"
    
    # Teste 6: Contém funcionalidades de banco de dados
    run_test "db has database functionality" \
        "grep -q 'db\|database\|setup\|install' '$db_file'" \
        "funcionalidades de banco de dados encontradas"
    
    # Teste 7: Contém configurações de conexão
    run_test "db has connection configuration" \
        "grep -q 'setup\|config\|start\|stop' '$db_file'" \
        "configurações de conexão encontradas"
    
    # Teste 8: Contém ferramentas de gerenciamento
    run_test "db has management tools" \
        "grep -q 'start\|stop\|status\|log' '$db_file'" \
        "ferramentas de gerenciamento encontradas"
    
    # Teste 9: Contém funções de serviço
    run_test "db has service functions" \
        "grep -q 'db_setup\|db_install\|db_start' '$db_file'" \
        "funções de serviço encontradas"
    
    # Teste 10: Contém ajuda integrada
    run_test "db has integrated help" \
        "grep -q 'Uso:' '$db_file'" \
        "ajuda integrada encontrada"
}

# Função para mostrar resumo
show_summary() {
    echo
    log "INFO" "=== Resumo dos Testes do Comando DB ==="
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "Todos os testes do comando db passaram!"
        exit 0
    else
        log "ERROR" "Alguns testes do comando db falharam"
        exit 1
    fi
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando testes unitários do comando db..."
    
    setup
    test_db_structure
    cleanup
    show_summary
}

# Executa se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi 