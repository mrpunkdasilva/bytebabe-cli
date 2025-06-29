#!/bin/bash

# Teste unitário para o comando init do ByteBabe CLI
# Descrição: Testa a estrutura e funcionalidades do comando init

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
    log "INFO" "Setup do teste init concluído"
}

# Cleanup do teste
cleanup() {
    # Limpeza após cada teste
    rm -rf "$TEST_TEMP_DIR"
    log "INFO" "Cleanup do teste init concluído"
}

# Testes do comando init
test_init_structure() {
    log "INFO" "Executando testes de estrutura do comando init..."
    
    local init_file="$BASE_DIR/commands/init.sh"
    
    # Teste 1: Arquivo existe
    run_test "init command exists" \
        "test -f '$init_file'" \
        "arquivo init.sh existe"
    
    # Teste 2: Arquivo é executável
    run_test "init command is executable" \
        "test -x '$init_file'" \
        "arquivo init.sh é executável"
    
    # Teste 3: Contém função main
    run_test "init has main function" \
        "grep -q 'main()' '$init_file'" \
        "função main() encontrada"
    
    # Teste 4: Contém proteção de execução
    run_test "init has execution guard" \
        "grep -q 'BASH_SOURCE' '$init_file'" \
        "proteção de execução encontrada"
    
    # Teste 5: Importa módulos necessários
    run_test "init imports required modules" \
        "grep -q 'source.*colors.sh' '$init_file'" \
        "módulo colors.sh importado"
    
    # Teste 6: Contém estilo cyberpunk
    run_test "init has cyberpunk styling" \
        "grep -q 'CYBER_' '$init_file'" \
        "estilo cyberpunk encontrado"
    
    # Teste 7: Verifica dependências
    run_test "init checks dependencies" \
        "grep -q 'check_dependencies' '$init_file'" \
        "verificação de dependências encontrada"
    
    # Teste 8: Mensagem de conclusão
    run_test "init has completion message" \
        "grep -q 'CONFIGURAÇÃO INICIAL COMPLETA' '$init_file'" \
        "mensagem de conclusão encontrada"
}

# Função para mostrar resumo
show_summary() {
    echo
    log "INFO" "=== Resumo dos Testes do Comando Init ==="
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "Todos os testes do comando init passaram!"
        exit 0
    else
        log "ERROR" "Alguns testes do comando init falharam"
        exit 1
    fi
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando testes unitários do comando init..."
    
    setup
    test_init_structure
    cleanup
    show_summary
}

# Executa se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi 