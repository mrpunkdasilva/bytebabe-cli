#!/bin/bash

# Teste unitário para o comando git do ByteBabe CLI
# Descrição: Testa a estrutura e funcionalidades do comando git

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
    log "INFO" "Setup do teste git concluído"
}

# Cleanup do teste
cleanup() {
    # Limpeza após cada teste
    rm -rf "$TEST_TEMP_DIR"
    log "INFO" "Cleanup do teste git concluído"
}

# Testes do comando git
test_git_structure() {
    log "INFO" "Executando testes de estrutura do comando git..."
    
    local git_dir="$BASE_DIR/commands/git"
    local git_main_file="$git_dir/main.sh"
    
    # Teste 1: Diretório git existe
    run_test "git directory exists" \
        "test -d '$git_dir'" \
        "diretório git existe"
    
    # Teste 2: Arquivo main.sh existe
    run_test "git main.sh exists" \
        "test -f '$git_main_file'" \
        "arquivo main.sh existe"
    
    # Teste 3: Arquivo main.sh é executável
    run_test "git main.sh is executable" \
        "test -x '$git_main_file'" \
        "arquivo main.sh é executável"
    
    # Teste 4: Contém função main_navigation
    run_test "git has main_navigation function" \
        "grep -q 'main_navigation()' '$git_main_file'" \
        "função main_navigation encontrada"
    
    # Teste 5: Importa módulos necessários
    run_test "git imports required modules" \
        "grep -q 'source.*ui.sh' '$git_main_file'" \
        "módulo ui.sh importado"
    
    # Teste 6: Contém estilo cyberpunk
    run_test "git has cyberpunk styling" \
        "grep -q 'CYBER_' '$git_main_file'" \
        "estilo cyberpunk encontrado"
    
    # Teste 7: Contém funcionalidades de git
    run_test "git has git functionality" \
        "grep -q 'git\|commit\|push\|pull' '$git_main_file'" \
        "funcionalidades de git encontradas"
    
    # Teste 8: Contém operações de branch
    run_test "git has branch operations" \
        "grep -q 'branch\|checkout\|merge' '$git_main_file'" \
        "operações de branch encontradas"
    
    # Teste 9: Contém operações de status
    run_test "git has status operations" \
        "grep -q 'status\|log\|diff' '$git_main_file'" \
        "operações de status encontradas"
    
    # Teste 10: Contém menu principal
    run_test "git has main menu" \
        "grep -q 'show_main_menu' '$git_main_file'" \
        "menu principal encontrado"
    
    # Teste 11: Contém setup de repositório
    run_test "git has repository setup" \
        "grep -q 'setup_repository' '$git_main_file'" \
        "setup de repositório encontrado"
    
    # Teste 12: Contém ações rápidas
    run_test "git has quick actions" \
        "grep -q 'show_quick_actions' '$git_main_file'" \
        "ações rápidas encontradas"
}

# Função para mostrar resumo
show_summary() {
    echo
    log "INFO" "=== Resumo dos Testes do Comando Git ==="
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "Todos os testes do comando git passaram!"
        exit 0
    else
        log "ERROR" "Alguns testes do comando git falharam"
        exit 1
    fi
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando testes unitários do comando git..."
    
    setup
    test_git_structure
    cleanup
    show_summary
}

# Executa se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi 