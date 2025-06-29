#!/bin/bash

# Teste unitário para o comando byteedit do ByteBabe CLI
# Descrição: Testa a estrutura e funcionalidades do comando byteedit

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
    log "INFO" "Setup do teste byteedit concluído"
}

# Cleanup do teste
cleanup() {
    # Limpeza após cada teste
    rm -rf "$TEST_TEMP_DIR"
    log "INFO" "Cleanup do teste byteedit concluído"
}

# Testes do comando byteedit
test_byteedit_structure() {
    log "INFO" "Executando testes de estrutura do comando byteedit..."
    
    local byteedit_file="$BASE_DIR/commands/byteedit.sh"
    
    # Teste 1: Arquivo existe
    run_test "byteedit command exists" \
        "test -f '$byteedit_file'" \
        "arquivo byteedit.sh existe"
    
    # Teste 2: Arquivo é executável
    run_test "byteedit command is executable" \
        "test -x '$byteedit_file'" \
        "arquivo byteedit.sh é executável"
    
    # Teste 3: Contém função byte_edit
    run_test "byteedit has byte_edit function" \
        "grep -q 'byte_edit()' '$byteedit_file'" \
        "função byte_edit encontrada"
    
    # Teste 4: Contém função display_content
    run_test "byteedit has display_content function" \
        "grep -q 'display_content()' '$byteedit_file'" \
        "função display_content encontrada"
    
    # Teste 5: Contém cores para interface
    run_test "byteedit has color definitions" \
        "grep -q 'RED=' '$byteedit_file'" \
        "definições de cores encontradas"
    
    # Teste 6: Contém comandos do editor
    run_test "byteedit has editor commands" \
        "grep -q 'q\|w\|n\|d\|e' '$byteedit_file'" \
        "comandos do editor encontrados"
    
    # Teste 7: Contém navegação por linhas
    run_test "byteedit has line navigation" \
        "grep -q 'j\|k\|g' '$byteedit_file'" \
        "navegação por linhas encontrada"
    
    # Teste 8: Contém funcionalidade de salvar
    run_test "byteedit has save functionality" \
        "grep -q 'printf.*>.*\$file' '$byteedit_file'" \
        "funcionalidade de salvar encontrada"
    
    # Teste 9: Contém verificação de arquivo
    run_test "byteedit has file validation" \
        "grep -q 'if.*-f.*\$file' '$byteedit_file'" \
        "verificação de arquivo encontrada"
    
    # Teste 10: Contém interface de usuário
    run_test "byteedit has user interface" \
        "grep -q 'Comando:' '$byteedit_file'" \
        "interface de usuário encontrada"
}

# Função para mostrar resumo
show_summary() {
    echo
    log "INFO" "=== Resumo dos Testes do Comando ByteEdit ==="
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "Todos os testes do comando byteedit passaram!"
        exit 0
    else
        log "ERROR" "Alguns testes do comando byteedit falharam"
        exit 1
    fi
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando testes unitários do comando byteedit..."
    
    setup
    test_byteedit_structure
    cleanup
    show_summary
}

# Executa se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi 