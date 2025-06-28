#!/bin/bash

# ByteBabe CLI - Setup de Ambiente de Testes
# Descrição: Configura o ambiente para execução de testes

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
readonly TEST_FIXTURES_DIR="$TESTS_DIR/fixtures"

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

# Verificar dependências
check_dependencies() {
    log "INFO" "Verificando dependências..."
    
    local missing_deps=()
    
    # Verificar BATS
    if ! command -v bats &> /dev/null; then
        missing_deps+=("bats")
    fi
    
    # Verificar ShellCheck
    if ! command -v shellcheck &> /dev/null; then
        missing_deps+=("shellcheck")
    fi
    
    # Verificar Docker (opcional)
    if ! command -v docker &> /dev/null; then
        log "WARNING" "Docker não encontrado - alguns testes de integração podem falhar"
    fi
    
    # Verificar jq
    if ! command -v jq &> /dev/null; then
        missing_deps+=("jq")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log "WARNING" "Dependências faltando: ${missing_deps[*]}"
        log "INFO" "Você pode instalar manualmente ou continuar sem elas"
        log "INFO" "Para instalar:"
        log "INFO" "  sudo dnf install -y bats-core shellcheck jq"
        log "INFO" "  ou"
        log "INFO" "  sudo apt-get install -y bats shellcheck jq"
        
        read -p "Deseja continuar sem essas dependências? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log "INFO" "Setup interrompido. Instale as dependências e tente novamente."
            exit 1
        fi
    else
        log "SUCCESS" "Todas as dependências estão instaladas"
    fi
}

# Criar estrutura de diretórios
create_directories() {
    log "INFO" "Criando estrutura de diretórios..."
    
    local dirs=(
        "$TEST_REPORTS_DIR/coverage"
        "$TEST_REPORTS_DIR/junit"
        "$TEST_REPORTS_DIR/html"
        "$TEST_FIXTURES_DIR/configs"
        "$TEST_FIXTURES_DIR/data"
        "$TEST_FIXTURES_DIR/responses"
        "$TESTS_DIR/unit/commands"
        "$TESTS_DIR/unit/lib"
        "$TESTS_DIR/unit/utils"
        "$TESTS_DIR/integration/docker"
        "$TESTS_DIR/integration/database"
        "$TESTS_DIR/integration/api"
        "$TESTS_DIR/e2e/workflows"
        "$TESTS_DIR/e2e/scenarios"
    )
    
    for dir in "${dirs[@]}"; do
        mkdir -p "$dir"
        log "SUCCESS" "Criado: $dir"
    done
}

# Criar arquivo de configuração
create_config_file() {
    log "INFO" "Criando arquivo de configuração..."
    
    cat > "$TEST_CONFIG_FILE" << 'EOF'
# ByteBabe CLI - Configuração de Testes

# Timeouts
BYTEBABE_TEST_TIMEOUT=30
BYTEBABE_TEST_RETRIES=3

# Verbosidade
BYTEBABE_TEST_VERBOSE=true
BYTEBABE_TEST_DEBUG=false

# Diretórios
BYTEBABE_TEST_DATA_DIR=tests/fixtures/data
BYTEBABE_TEST_REPORTS_DIR=tests/reports
BYTEBABE_TEST_CONFIGS_DIR=tests/fixtures/configs

# Docker (para testes de integração)
BYTEBABE_TEST_DOCKER_IMAGE=bytebabe-test:latest
BYTEBABE_TEST_DOCKER_NETWORK=bytebabe-test-network

# Database (para testes de integração)
BYTEBABE_TEST_DB_HOST=localhost
BYTEBABE_TEST_DB_PORT=5432
BYTEBABE_TEST_DB_NAME=bytebabe_test
BYTEBABE_TEST_DB_USER=test_user
BYTEBABE_TEST_DB_PASS=test_pass

# API (para testes de integração)
BYTEBABE_TEST_API_BASE_URL=http://localhost:3000
BYTEBABE_TEST_API_TIMEOUT=10

# Relatórios
BYTEBABE_TEST_GENERATE_REPORTS=true
BYTEBABE_TEST_COVERAGE_THRESHOLD=80
EOF

    log "SUCCESS" "Arquivo de configuração criado: $TEST_CONFIG_FILE"
}

# Configurar variáveis de ambiente
setup_environment() {
    log "INFO" "Configurando variáveis de ambiente..."
    
    # Carregar configuração
    if [ -f "$TEST_CONFIG_FILE" ]; then
        set -a
        source "$TEST_CONFIG_FILE"
        set +a
    fi
    
    # Variáveis padrão
    export BYTEBABE_TEST_MODE=true
    export BYTEBABE_TEST_ROOT="$TESTS_DIR"
    export BYTEBABE_TEST_PROJECT_ROOT="$PROJECT_ROOT"
    
    log "SUCCESS" "Variáveis de ambiente configuradas"
}

# Verificar permissões
check_permissions() {
    log "INFO" "Verificando permissões..."
    
    # Verificar se o bytebabe é executável
    if [ ! -x "$PROJECT_ROOT/bin/bytebabe" ]; then
        log "WARNING" "bytebabe não é executável, ajustando permissões..."
        chmod +x "$PROJECT_ROOT/bin/bytebabe"
    fi
    
    # Verificar permissões dos scripts de teste
    find "$TESTS_DIR/scripts" -name "*.sh" -exec chmod +x {} \;
    
    log "SUCCESS" "Permissões verificadas"
}

# Criar dados de teste básicos
create_test_fixtures() {
    log "INFO" "Criando dados de teste básicos..."
    
    # Configuração de teste
    cat > "$TEST_FIXTURES_DIR/configs/test-config.json" << 'EOF'
{
  "app": {
    "name": "ByteBabe Test",
    "version": "1.0.0-test"
  },
  "test": {
    "timeout": 30,
    "retries": 3,
    "verbose": true
  }
}
EOF

    # Dados mock para comandos
    cat > "$TEST_FIXTURES_DIR/data/commands.json" << 'EOF'
{
  "hello": {
    "input": [],
    "expected_output": "Hello, Cyberpunk!",
    "exit_code": 0
  },
  "init": {
    "input": [],
    "expected_output": "Environment initialized",
    "exit_code": 0
  }
}
EOF

    # Respostas esperadas
    cat > "$TEST_FIXTURES_DIR/responses/api-responses.json" << 'EOF'
{
  "users": {
    "GET": {
      "status": 200,
      "body": [
        {"id": 1, "name": "Test User"}
      ]
    },
    "POST": {
      "status": 201,
      "body": {"id": 2, "name": "New User"}
    }
  }
}
EOF

    log "SUCCESS" "Dados de teste criados"
}

# Criar script de teste simples (sem BATS)
create_simple_test_runner() {
    log "INFO" "Criando runner de teste simples..."
    
    cat > "$TESTS_DIR/scripts/run_simple_tests.sh" << 'EOF'
#!/bin/bash

# ByteBabe CLI - Runner de Testes Simples
# Descrição: Executa testes sem dependência do BATS

set -euo pipefail

# Cores
readonly CYBER_RED='\033[0;31m'
readonly CYBER_GREEN='\033[0;32m'
readonly CYBER_BLUE='\033[0;34m'
readonly RESET='\033[0m'

# Diretórios
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TESTS_DIR="$(dirname "$SCRIPT_DIR")"
readonly PROJECT_ROOT="$(dirname "$TESTS_DIR")"
readonly BYTEBABE_BIN="$PROJECT_ROOT/bin/bytebabe"

# Contadores
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

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
    local expected_output="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    echo -n "Testando: $test_name... "
    
    if output=$(eval "$test_command" 2>&1); then
        if [[ "$output" == *"$expected_output"* ]]; then
            echo -e "${CYBER_GREEN}PASS${RESET}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
            return 0
        else
            echo -e "${CYBER_RED}FAIL${RESET}"
            echo "  Esperado: $expected_output"
            echo "  Obtido: $output"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            return 1
        fi
    else
        echo -e "${CYBER_RED}FAIL${RESET}"
        echo "  Erro: $output"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        return 1
    fi
}

# Testes básicos
run_basic_tests() {
    log "INFO" "Executando testes básicos..."
    
    # Teste 1: Comando hello sem argumentos
    run_test "hello sem argumentos" \
        "$BYTEBABE_BIN hello" \
        "Hello"
    
    # Teste 2: Comando hello com argumento
    run_test "hello com argumento" \
        "$BYTEBABE_BIN hello TestUser" \
        "Hello"
    
    # Teste 3: Comando help
    run_test "comando help" \
        "$BYTEBABE_BIN --help" \
        "bytebabe"
    
    # Teste 4: Verificar se é executável
    if [ -x "$BYTEBABE_BIN" ]; then
        echo -e "Testando: executável... ${CYBER_GREEN}PASS${RESET}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "Testando: executável... ${CYBER_RED}FAIL${RESET}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
}

# Mostrar resumo
show_summary() {
    echo
    log "INFO" "=== Resumo dos Testes ==="
    echo "Total: $TOTAL_TESTS"
    echo "Passou: $PASSED_TESTS"
    echo "Falhou: $FAILED_TESTS"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log "SUCCESS" "Todos os testes passaram!"
        exit 0
    else
        log "ERROR" "Alguns testes falharam"
        exit 1
    fi
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando testes simples do ByteBabe CLI..."
    
    if [ ! -f "$BYTEBABE_BIN" ]; then
        log "ERROR" "ByteBabe CLI não encontrado: $BYTEBABE_BIN"
        exit 1
    fi
    
    run_basic_tests
    show_summary
}

main "$@"
EOF

    chmod +x "$TESTS_DIR/scripts/run_simple_tests.sh"
    log "SUCCESS" "Runner de teste simples criado"
}

# Função principal
main() {
    log "INFO" "🚀 Iniciando setup do ambiente de testes ByteBabe CLI..."
    
    check_dependencies
    create_directories
    create_config_file
    setup_environment
    check_permissions
    create_test_fixtures
    create_simple_test_runner
    
    log "SUCCESS" "✅ Setup do ambiente de testes concluído!"
    log "INFO" "📁 Diretório de testes: $TESTS_DIR"
    log "INFO" "📊 Relatórios: $TEST_REPORTS_DIR"
    log "INFO" "⚙️ Configuração: $TEST_CONFIG_FILE"
    log "INFO" ""
    log "INFO" "Para executar os testes:"
    log "INFO" "  ./tests/scripts/run_simple_tests.sh    # Testes simples (sem BATS)"
    log "INFO" "  ./tests/scripts/run_all_tests.sh       # Testes completos (com BATS)"
}

# Executar se chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi 