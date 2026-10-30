#!/bin/bash

# Teste unitário para o comando backend do ByteBabe CLI
# Descrição: Testa a estrutura e funcionalidades do comando backend

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
    log "INFO" "Setup do teste backend concluído"
}

# Cleanup do teste
cleanup() {
    # Limpeza após cada teste
    rm -rf "$TEST_TEMP_DIR"
    log "INFO" "Cleanup do teste backend concluído"
}

# Testes do comando backend
test_backend_structure() {
    log "INFO" "Executando testes de estrutura do comando backend..."
    
    local backend_file="$BASE_DIR/commands/backend/main.sh"
    
    # Teste 1: Arquivo existe
    run_test "backend command exists" \
        "test -f '$backend_file'" \
        "arquivo backend.sh existe"
    
    # Teste 2: Arquivo é executável
    run_test "backend command is executable" \
        "test -x '$backend_file'" \
        "arquivo backend.sh é executável"
    
    # Teste 3: Contém função main
    run_test "backend has main function" \
        "grep -q 'main()' '$backend_file'" \
        "função main encontrada"
    
    # Teste 4: Importa módulos necessários
    run_test "backend imports required modules" \
        "grep -q 'source.*colors.sh' '$backend_file'" \
        "módulo colors.sh importado"
    
    # Teste 5: Contém estilo cyberpunk
    run_test "backend has cyberpunk styling" \
        "grep -q 'CYBER_' '$backend_file'" \
        "estilo cyberpunk encontrado"
    
    # Teste 6: Contém funcionalidades de backend
    run_test "backend has backend functionality" \
        "grep -q 'backend\|spring\|node\|java' '$backend_file'" \
        "funcionalidades de backend encontradas"
    
    # Teste 7: Contém configurações de projeto
    run_test "backend has project configuration" \
        "grep -q 'setup\|config\|install' '$backend_file'" \
        "configurações de projeto encontradas"
    
    # Teste 8: Contém ferramentas de desenvolvimento
    run_test "backend has development tools" \
        "grep -q 'dev\|build\|run' '$backend_file'" \
        "ferramentas de desenvolvimento encontradas"
    
    # Teste 9: Contém gerenciamento de dependências
    run_test "backend has dependency management" \
        "grep -q 'npm\|maven\|gradle' '$backend_file'" \
        "gerenciamento de dependências encontrado"

    local spring_file="$BASE_DIR/commands/backend/spring/main.sh"
    local spring_dir="$BASE_DIR/lib/backend/spring"

    # Teste 10: Carregador canônico de generators existe
    run_test "spring has canonical generators loader" \
        "test -f '$spring_dir/generators/main.sh'" \
        "carregador canônico de generators existe"

    # Teste 11: Generator de mapper existe
    run_test "spring has mapper generator" \
        "test -f '$spring_dir/generators/mapper.sh'" \
        "generator mapper existe"

    # Teste 12: Entry point usa o carregador canônico
    run_test "spring command uses canonical generator loader" \
        "grep -q 'generators/main.sh' '$spring_file'" \
        "entry point carrega generators/main.sh"

    # Teste 13: Duplicatas foram arquivadas
    run_test "spring duplicate generators are archived" \
        "test -f '$BASE_DIR/archive/legacy/spring/generators/controller_generator.sh'" \
        "duplicatas de generators arquivadas"

    # Teste 14: Entry point não encerra o processo
    run_test "spring command has no exit" \
        "! grep -qE '^[[:space:]]*exit\\b' '$spring_file'" \
        "entry point Spring não usa exit"
}

# Função para mostrar resumo
show_summary() {
    echo
    log "INFO" "=== Resumo dos Testes do Comando Backend ==="
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "Todos os testes do comando backend passaram!"
        exit 0
    else
        log "ERROR" "Alguns testes do comando backend falharam"
        exit 1
    fi
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando testes unitários do comando backend..."
    
    setup
    test_backend_structure
    cleanup
    show_summary
}

# Executa se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi 