#!/bin/bash

# Teste unitário para o comando frontend do ByteBabe CLI
# Descrição: Testa a estrutura e funcionalidades do comando frontend

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
    log "INFO" "Setup do teste frontend concluído"
}

# Cleanup do teste
cleanup() {
    # Limpeza após cada teste
    rm -rf "$TEST_TEMP_DIR"
    log "INFO" "Cleanup do teste frontend concluído"
}

# Testes do comando frontend
test_frontend_structure() {
    log "INFO" "Executando testes de estrutura do comando frontend..."
    
    local frontend_file="$BASE_DIR/commands/frontend.sh"
    
    # Teste 1: Arquivo existe
    run_test "frontend command exists" \
        "test -f '$frontend_file'" \
        "arquivo frontend.sh existe"
    
    # Teste 2: Arquivo é executável
    run_test "frontend command is executable" \
        "test -x '$frontend_file'" \
        "arquivo frontend.sh é executável"
    
    # Teste 3: Contém função main
    run_test "frontend has main function" \
        "grep -q 'main()' '$frontend_file'" \
        "função main encontrada"
    
    # Teste 4: Importa módulos necessários
    run_test "frontend imports required modules" \
        "grep -q 'source.*colors.sh' '$frontend_file'" \
        "módulo colors.sh importado"
    
    # Teste 5: Contém estilo cyberpunk
    run_test "frontend has cyberpunk styling" \
        "grep -q 'CYBER_' '$frontend_file'" \
        "estilo cyberpunk encontrado"
    
    # Teste 6: Contém funcionalidades de frontend
    run_test "frontend has frontend functionality" \
        "grep -q 'frontend\|react\|vue\|angular' '$frontend_file'" \
        "funcionalidades de frontend encontradas"
    
    # Teste 7: Contém configurações de projeto
    run_test "frontend has project configuration" \
        "grep -q 'setup\|config\|install' '$frontend_file'" \
        "configurações de projeto encontradas"
    
    # Teste 8: Contém ferramentas de desenvolvimento
    run_test "frontend has development tools" \
        "grep -q 'dev\|build\|serve' '$frontend_file'" \
        "ferramentas de desenvolvimento encontradas"
    
    # Teste 9: Contém gerenciamento de dependências
    run_test "frontend has dependency management" \
        "grep -q 'npm\|yarn\|package' '$frontend_file'" \
        "gerenciamento de dependências encontrado"
    
    # Teste 10: Contém geração de componentes
    run_test "frontend has component generation" \
        "grep -q 'generate\|component' '$frontend_file'" \
        "geração de componentes encontrada"
}

# Função para mostrar resumo
show_summary() {
    echo
    log "INFO" "=== Resumo dos Testes do Comando Frontend ==="
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "Todos os testes do comando frontend passaram!"
        exit 0
    else
        log "ERROR" "Alguns testes do comando frontend falharam"
        exit 1
    fi
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando testes unitários do comando frontend..."
    
    setup
    test_frontend_structure
    cleanup
    show_summary
}

# Executa se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi 