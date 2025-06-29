#!/bin/bash

# ByteBabe CLI - Executor de Testes Unitários
# Descrição: Executa todos os testes unitários dos comandos

set -euo pipefail

# Cores
readonly CYBER_RED='\033[0;31m'
readonly CYBER_GREEN='\033[0;32m'
readonly CYBER_YELLOW='\033[1;33m'
readonly CYBER_BLUE='\033[0;34m'
readonly CYBER_PURPLE='\033[0;35m'
readonly CYBER_CYAN='\033[0;36m'
readonly RESET='\033[0m'

# Diretórios
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TESTS_DIR="$(dirname "$SCRIPT_DIR")"
readonly UNIT_TESTS_DIR="$TESTS_DIR/unit/commands"

# Contadores globais
TOTAL_TESTS=0
TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_FILES=0
FAILED_FILES=()

# Função para log
log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "INFO") echo -e "${CYBER_BLUE}ℹ $message${RESET}" ;;
        "SUCCESS") echo -e "${CYBER_GREEN}✔ $message${RESET}" ;;
        "WARNING") echo -e "${CYBER_YELLOW}⚠ $message${RESET}" ;;
        "ERROR") echo -e "${CYBER_RED}✗ $message${RESET}" ;;
        *) echo "$message" ;;
    esac
}

# Função para mostrar ajuda
show_help() {
    cat << EOF
ByteBabe CLI - Executor de Testes Unitários

Uso: $0 [OPÇÕES]

Opções:
  -h, --help              Mostrar esta ajuda
  -v, --verbose           Modo verboso (mostra saída dos testes)
  -q, --quiet             Modo silencioso (apenas resumo)
  --list                  Listar todos os testes disponíveis
  --test <comando>        Executar teste específico (ex: hello, init, backend)

Exemplos:
  $0                      # Executar todos os testes
  $0 --verbose            # Executar com output detalhado
  $0 --test hello         # Executar apenas teste do comando hello
  $0 --list               # Listar todos os testes disponíveis

EOF
}

# Função para listar testes disponíveis
list_tests() {
    log "INFO" "Testes unitários disponíveis:"
    
    if [ ! -d "$UNIT_TESTS_DIR" ]; then
        log "ERROR" "Diretório de testes unitários não encontrado: $UNIT_TESTS_DIR"
        return 1
    fi
    
    local test_files=($(find "$UNIT_TESTS_DIR" -name "*.test.sh" -type f | sort))
    
    if [ ${#test_files[@]} -eq 0 ]; then
        log "WARNING" "Nenhum teste encontrado em: $UNIT_TESTS_DIR"
        return 1
    fi
    
    for test_file in "${test_files[@]}"; do
        local test_name=$(basename "$test_file" .test.sh)
        echo "  - $test_name"
    done
    
    echo
    log "INFO" "Total: ${#test_files[@]} testes encontrados"
}

# Função para executar teste individual
run_single_test() {
    local test_file="$1"
    local verbose="$2"
    
    if [ ! -f "$test_file" ]; then
        log "ERROR" "Arquivo de teste não encontrado: $test_file"
        return 1
    fi
    
    if [ ! -x "$test_file" ]; then
        log "WARNING" "Arquivo de teste não é executável, ajustando permissões..."
        chmod +x "$test_file"
    fi
    
    local test_name=$(basename "$test_file" .test.sh)
    log "INFO" "Executando teste: $test_name"
    
    if [ "$verbose" = true ]; then
        # Modo verboso: mostra toda a saída
        if bash "$test_file"; then
            log "SUCCESS" "Teste $test_name passou"
            return 0
        else
            log "ERROR" "Teste $test_name falhou"
            return 1
        fi
    else
        # Modo normal: captura saída e mostra apenas resultado
        local output
        if output=$(bash "$test_file" 2>&1); then
            # Extrair contadores do output
            local passed=$(echo "$output" | grep -o "Passou: [0-9]*" | grep -o "[0-9]*" | tail -1)
            local failed=$(echo "$output" | grep -o "Falhou: [0-9]*" | grep -o "[0-9]*" | tail -1)
            local total=$(echo "$output" | grep -o "Total: [0-9]*" | grep -o "[0-9]*" | tail -1)
            
            if [ -n "$passed" ] && [ -n "$failed" ] && [ -n "$total" ]; then
                TOTAL_TESTS=$((TOTAL_TESTS + total))
                TOTAL_PASSED=$((TOTAL_PASSED + passed))
                TOTAL_FAILED=$((TOTAL_FAILED + failed))
                
                if [ "$failed" -eq 0 ]; then
                    log "SUCCESS" "Teste $test_name: $passed/$total passaram"
                else
                    log "ERROR" "Teste $test_name: $failed/$total falharam"
                    FAILED_FILES+=("$test_name")
                fi
            else
                log "SUCCESS" "Teste $test_name passou"
            fi
            return 0
        else
            log "ERROR" "Teste $test_name falhou"
            FAILED_FILES+=("$test_name")
            return 1
        fi
    fi
}

# Função para executar todos os testes
run_all_tests() {
    local verbose="$1"
    
    log "INFO" "🚀 Iniciando execução de todos os testes unitários..."
    
    if [ ! -d "$UNIT_TESTS_DIR" ]; then
        log "ERROR" "Diretório de testes unitários não encontrado: $UNIT_TESTS_DIR"
        exit 1
    fi
    
    local test_files=($(find "$UNIT_TESTS_DIR" -name "*.test.sh" -type f | sort))
    
    if [ ${#test_files[@]} -eq 0 ]; then
        log "WARNING" "Nenhum teste encontrado em: $UNIT_TESTS_DIR"
        exit 1
    fi
    
    log "INFO" "Encontrados ${#test_files[@]} testes para executar"
    echo
    
    for test_file in "${test_files[@]}"; do
        TOTAL_FILES=$((TOTAL_FILES + 1))
        run_single_test "$test_file" "$verbose"
        echo
    done
}

# Função para mostrar resumo final
show_summary() {
    echo
    log "INFO" "=== Resumo Final dos Testes ==="
    echo "Arquivos de teste: $TOTAL_FILES"
    echo "Total de testes: $TOTAL_TESTS"
    echo "Passaram: $TOTAL_PASSED"
    echo "Falharam: $TOTAL_FAILED"
    
    if [ ${#FAILED_FILES[@]} -gt 0 ]; then
        echo
        log "ERROR" "Arquivos com falhas:"
        for file in "${FAILED_FILES[@]}"; do
            echo "  - $file"
        done
    fi
    
    echo
    if [ $TOTAL_FAILED -eq 0 ]; then
        log "SUCCESS" "🎉 Todos os testes passaram!"
        exit 0
    else
        log "ERROR" "❌ Alguns testes falharam"
        exit 1
    fi
}

# Parse argumentos
VERBOSE=false
QUIET=false
LIST_TESTS=false
SPECIFIC_TEST=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -q|--quiet)
            QUIET=true
            shift
            ;;
        --list)
            LIST_TESTS=true
            shift
            ;;
        --test)
            if [ -z "$2" ]; then
                log "ERROR" "Opção --test requer um argumento"
                exit 1
            fi
            SPECIFIC_TEST="$2"
            shift 2
            ;;
        *)
            log "ERROR" "Opção desconhecida: $1"
            show_help
            exit 1
            ;;
    esac
done

# Executar comando solicitado
if [ "$LIST_TESTS" = true ]; then
    list_tests
    exit 0
fi

if [ -n "$SPECIFIC_TEST" ]; then
    test_file="$UNIT_TESTS_DIR/${SPECIFIC_TEST}.test.sh"
    if [ ! -f "$test_file" ]; then
        log "ERROR" "Teste não encontrado: $SPECIFIC_TEST"
        log "INFO" "Use --list para ver testes disponíveis"
        exit 1
    fi
    run_single_test "$test_file" "$VERBOSE"
    exit $?
fi

# Executar todos os testes
run_all_tests "$VERBOSE"
show_summary 