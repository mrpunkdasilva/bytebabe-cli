#!/bin/bash

# ByteBabe CLI - Executor de Testes Completo
# Descrição: Executa todos os tipos de testes do ByteBabe CLI

set -euo pipefail

# Cores para output
readonly CYBER_RED='\033[0;31m'
readonly CYBER_GREEN='\033[0;32m'
readonly CYBER_YELLOW='\033[1;33m'
readonly CYBER_BLUE='\033[0;34m'
readonly CYBER_PURPLE='\033[0;35m'
readonly CYBER_CYAN='\033[0;36m'
readonly RESET='\033[0m'

# Diretórios base
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TESTS_DIR="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_ROOT="$(dirname "$TESTS_DIR")"

# Configurações
readonly TEST_CONFIG_FILE="$TESTS_DIR/config/test.env"
readonly TEST_REPORTS_DIR="$TESTS_DIR/reports"
readonly TEST_LOG_FILE="$TEST_REPORTS_DIR/test.log"

# Variáveis de controle
VERBOSE=false
GENERATE_REPORTS=false
SKIP_UNIT=false
SKIP_INTEGRATION=false
SKIP_E2E=false
PARALLEL=false

# Função para log
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "INFO") echo -e "${CYBER_BLUE}[$timestamp] ℹ $message${RESET}" ;;
        "SUCCESS") echo -e "${CYBER_GREEN}[$timestamp] ✔ $message${RESET}" ;;
        "WARNING") echo -e "${CYBER_YELLOW}[$timestamp] ⚠ $message${RESET}" ;;
        "ERROR") echo -e "${CYBER_RED}[$timestamp] ✗ $message${RESET}" ;;
        *) echo "[$timestamp] $message" ;;
    esac
    
    # Log para arquivo
    echo "[$timestamp] [$level] $message" >> "$TEST_LOG_FILE"
}

# Mostrar ajuda
show_help() {
    cat << EOF
ByteBabe CLI - Executor de Testes

Uso: $0 [OPÇÕES]

Opções:
  -h, --help              Mostrar esta ajuda
  -v, --verbose           Modo verboso
  -r, --reports           Gerar relatórios detalhados
  --skip-unit             Pular testes unitários
  --skip-integration      Pular testes de integração
  --skip-e2e              Pular testes end-to-end
  -p, --parallel          Executar testes em paralelo
  --coverage              Gerar relatório de cobertura
  --lint                  Executar linting (ShellCheck)
  --clean                 Limpar relatórios anteriores

Exemplos:
  $0                      # Executar todos os testes
  $0 --verbose            # Executar com output detalhado
  $0 --reports --coverage # Executar com relatórios completos
  $0 --skip-e2e           # Executar apenas unit e integration
  $0 --lint               # Apenas linting

EOF
}

# Parse argumentos
parse_args() {
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
            -r|--reports)
                GENERATE_REPORTS=true
                shift
                ;;
            --skip-unit)
                SKIP_UNIT=true
                shift
                ;;
            --skip-integration)
                SKIP_INTEGRATION=true
                shift
                ;;
            --skip-e2e)
                SKIP_E2E=true
                shift
                ;;
            -p|--parallel)
                PARALLEL=true
                shift
                ;;
            --coverage)
                GENERATE_REPORTS=true
                shift
                ;;
            --lint)
                run_linting
                exit 0
                ;;
            --clean)
                clean_reports
                exit 0
                ;;
            *)
                log "ERROR" "Opção desconhecida: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Carregar configuração
load_config() {
    if [ -f "$TEST_CONFIG_FILE" ]; then
        log "INFO" "Carregando configuração de testes..."
        set -a
        source "$TEST_CONFIG_FILE"
        set +a
    else
        log "WARNING" "Arquivo de configuração não encontrado: $TEST_CONFIG_FILE"
        log "INFO" "Executando setup inicial..."
        "$SCRIPT_DIR/setup.sh"
    fi
}

# Verificar ambiente
check_environment() {
    log "INFO" "Verificando ambiente de testes..."
    
    # Verificar se o bytebabe existe
    if [ ! -f "$PROJECT_ROOT/bin/bytebabe" ]; then
        log "ERROR" "ByteBabe CLI não encontrado: $PROJECT_ROOT/bin/bytebabe"
        exit 1
    fi
    
    # Verificar se é executável
    if [ ! -x "$PROJECT_ROOT/bin/bytebabe" ]; then
        log "WARNING" "ByteBabe CLI não é executável, ajustando permissões..."
        chmod +x "$PROJECT_ROOT/bin/bytebabe"
    fi
    
    # Verificar dependências
    local missing_deps=()
    
    if ! command -v bats &> /dev/null; then
        missing_deps+=("bats")
    fi
    
    if ! command -v shellcheck &> /dev/null; then
        missing_deps+=("shellcheck")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log "ERROR" "Dependências faltando: ${missing_deps[*]}"
        log "INFO" "Execute: ./tests/scripts/setup.sh"
        exit 1
    fi
    
    log "SUCCESS" "Ambiente verificado"
}

# Limpar relatórios anteriores
clean_reports() {
    log "INFO" "Limpando relatórios anteriores..."
    
    if [ -d "$TEST_REPORTS_DIR" ]; then
        rm -rf "$TEST_REPORTS_DIR"/*
        log "SUCCESS" "Relatórios limpos"
    else
        log "INFO" "Nenhum relatório para limpar"
    fi
}

# Executar linting
run_linting() {
    log "INFO" "🔍 Executando linting com ShellCheck..."
    
    local lint_errors=0
    local files_checked=0
    
    # Verificar scripts principais
    local main_scripts=(
        "$PROJECT_ROOT/bin/bytebabe"
        "$PROJECT_ROOT/commands"/*.sh
        "$PROJECT_ROOT/lib"/*/*.sh
        "$PROJECT_ROOT/scripts"/*.sh
    )
    
    for pattern in "${main_scripts[@]}"; do
        for file in $pattern; do
            if [ -f "$file" ]; then
                files_checked=$((files_checked + 1))
                if ! shellcheck "$file"; then
                    lint_errors=$((lint_errors + 1))
                fi
            fi
        done
    done
    
    # Verificar scripts de teste
    for file in "$TESTS_DIR"/**/*.sh; do
        if [ -f "$file" ]; then
            files_checked=$((files_checked + 1))
            if ! shellcheck "$file"; then
                lint_errors=$((lint_errors + 1))
            fi
        fi
    done
    
    if [ $lint_errors -eq 0 ]; then
        log "SUCCESS" "Linting concluído: $files_checked arquivos verificados, 0 erros"
    else
        log "ERROR" "Linting falhou: $files_checked arquivos verificados, $lint_errors erros"
        exit 1
    fi
}

# Executar testes unitários
run_unit_tests() {
    if [ "$SKIP_UNIT" = true ]; then
        log "INFO" "⏭️ Testes unitários pulados"
        return 0
    fi
    
    log "INFO" "🧪 Executando testes unitários..."
    
    local unit_tests_dir="$TESTS_DIR/unit"
    local unit_report="$TEST_REPORTS_DIR/junit/unit-tests.xml"
    
    mkdir -p "$(dirname "$unit_report")"
    
    local bats_args=()
    if [ "$VERBOSE" = true ]; then
        bats_args+=("--verbose-run")
    fi
    
    if [ "$GENERATE_REPORTS" = true ]; then
        bats_args+=("--report-formatter" "junit" "--output" "$unit_report")
    fi
    
    if [ "$PARALLEL" = true ]; then
        bats_args+=("--jobs" "4")
    fi
    
    local exit_code=0
    if ! bats "${bats_args[@]}" "$unit_tests_dir"; then
        exit_code=1
        log "ERROR" "Testes unitários falharam"
    else
        log "SUCCESS" "Testes unitários concluídos"
    fi
    
    return $exit_code
}

# Executar testes de integração
run_integration_tests() {
    if [ "$SKIP_INTEGRATION" = true ]; then
        log "INFO" "⏭️ Testes de integração pulados"
        return 0
    fi
    
    log "INFO" "🔗 Executando testes de integração..."
    
    local integration_tests_dir="$TESTS_DIR/integration"
    local integration_report="$TEST_REPORTS_DIR/junit/integration-tests.xml"
    
    mkdir -p "$(dirname "$integration_report")"
    
    local bats_args=()
    if [ "$VERBOSE" = true ]; then
        bats_args+=("--verbose-run")
    fi
    
    if [ "$GENERATE_REPORTS" = true ]; then
        bats_args+=("--report-formatter" "junit" "--output" "$integration_report")
    fi
    
    if [ "$PARALLEL" = true ]; then
        bats_args+=("--jobs" "2")  # Menos jobs para integração
    fi
    
    local exit_code=0
    if ! bats "${bats_args[@]}" "$integration_tests_dir"; then
        exit_code=1
        log "ERROR" "Testes de integração falharam"
    else
        log "SUCCESS" "Testes de integração concluídos"
    fi
    
    return $exit_code
}

# Executar testes E2E
run_e2e_tests() {
    if [ "$SKIP_E2E" = true ]; then
        log "INFO" "⏭️ Testes E2E pulados"
        return 0
    fi
    
    log "INFO" "🌐 Executando testes end-to-end..."
    
    local e2e_tests_dir="$TESTS_DIR/e2e"
    local e2e_report="$TEST_REPORTS_DIR/junit/e2e-tests.xml"
    
    mkdir -p "$(dirname "$e2e_report")"
    
    local bats_args=()
    if [ "$VERBOSE" = true ]; then
        bats_args+=("--verbose-run")
    fi
    
    if [ "$GENERATE_REPORTS" = true ]; then
        bats_args+=("--report-formatter" "junit" "--output" "$e2e_report")
    fi
    
    # E2E não deve ser paralelo
    local exit_code=0
    if ! bats "${bats_args[@]}" "$e2e_tests_dir"; then
        exit_code=1
        log "ERROR" "Testes E2E falharam"
    else
        log "SUCCESS" "Testes E2E concluídos"
    fi
    
    return $exit_code
}

# Gerar relatórios
generate_reports() {
    if [ "$GENERATE_REPORTS" != true ]; then
        return 0
    fi
    
    log "INFO" "📊 Gerando relatórios..."
    
    # Criar diretório de relatórios
    mkdir -p "$TEST_REPORTS_DIR/html"
    
    # Gerar relatório HTML simples
    cat > "$TEST_REPORTS_DIR/html/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ByteBabe CLI - Relatório de Testes</title>
    <style>
        body { font-family: 'Courier New', monospace; margin: 20px; background: #0a0a0a; color: #00ff00; }
        .header { text-align: center; margin-bottom: 30px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #00ff00; }
        .success { color: #00ff00; }
        .error { color: #ff0000; }
        .warning { color: #ffff00; }
        .info { color: #00ffff; }
        pre { background: #1a1a1a; padding: 10px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🧪 ByteBabe CLI - Relatório de Testes</h1>
        <p>Gerado em: <span id="timestamp"></span></p>
    </div>
    
    <div class="section">
        <h2>📋 Resumo</h2>
        <div id="summary"></div>
    </div>
    
    <div class="section">
        <h2>📁 Logs</h2>
        <pre id="logs"></pre>
    </div>
    
    <script>
        document.getElementById('timestamp').textContent = new Date().toLocaleString('pt-BR');
        
        // Carregar logs
        fetch('../test.log')
            .then(response => response.text())
            .then(data => {
                document.getElementById('logs').textContent = data;
            })
            .catch(error => {
                document.getElementById('logs').textContent = 'Erro ao carregar logs: ' + error;
            });
    </script>
</body>
</html>
EOF

    log "SUCCESS" "Relatórios gerados em: $TEST_REPORTS_DIR/html/"
}

# Função principal
main() {
    # Parse argumentos
    parse_args "$@"
    
    # Inicializar log
    mkdir -p "$(dirname "$TEST_LOG_FILE")"
    echo "=== ByteBabe CLI Test Run - $(date) ===" > "$TEST_LOG_FILE"
    
    log "INFO" "🚀 Iniciando execução de testes ByteBabe CLI..."
    
    # Carregar configuração
    load_config
    
    # Verificar ambiente
    check_environment
    
    # Executar testes
    local total_exit_code=0
    
    # Linting primeiro
    run_linting
    
    # Testes unitários
    if ! run_unit_tests; then
        total_exit_code=1
    fi
    
    # Testes de integração
    if ! run_integration_tests; then
        total_exit_code=1
    fi
    
    # Testes E2E
    if ! run_e2e_tests; then
        total_exit_code=1
    fi
    
    # Gerar relatórios
    generate_reports
    
    # Resumo final
    log "INFO" "📋 Resumo da execução:"
    log "INFO" "  📁 Logs: $TEST_LOG_FILE"
    log "INFO" "  📊 Relatórios: $TEST_REPORTS_DIR"
    
    if [ $total_exit_code -eq 0 ]; then
        log "SUCCESS" "✅ Todos os testes passaram!"
    else
        log "ERROR" "❌ Alguns testes falharam"
    fi
    
    exit $total_exit_code
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 