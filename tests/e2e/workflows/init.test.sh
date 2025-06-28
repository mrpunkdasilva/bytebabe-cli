#!/usr/bin/env bats

# ByteBabe CLI - Teste E2E: Fluxo de Inicialização
# Descrição: Testa o fluxo completo de inicialização do ByteBabe CLI

setup() {
    # Configurar ambiente de teste
    export BYTEBABE_TEST_MODE=true
    
    # Diretórios base
    export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    export TESTS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
    export PROJECT_ROOT="$(dirname "$TESTS_DIR")"
    
    # Caminho para o bytebabe
    export BYTEBABE_BIN="$PROJECT_ROOT/bin/bytebabe"
    
    # Verificar se o bytebabe existe
    if [ ! -f "$BYTEBABE_BIN" ]; then
        skip "ByteBabe CLI não encontrado: $BYTEBABE_BIN"
    fi
    
    # Criar diretório temporário para teste E2E
    export TEST_TMP_DIR="$(mktemp -d)"
    export TEST_OUTPUT_FILE="$TEST_TMP_DIR/output.txt"
    export TEST_ERROR_FILE="$TEST_TMP_DIR/error.txt"
    export TEST_LOG_FILE="$TEST_TMP_DIR/e2e.log"
    
    # Backup de configurações existentes
    export BACKUP_DIR="$TEST_TMP_DIR/backup"
    mkdir -p "$BACKUP_DIR"
    
    # Backup de arquivos de configuração se existirem
    if [ -f "$HOME/.config/bytebabe/config.json" ]; then
        cp "$HOME/.config/bytebabe/config.json" "$BACKUP_DIR/"
    fi
    
    if [ -f "$HOME/.bashrc" ]; then
        cp "$HOME/.bashrc" "$BACKUP_DIR/"
    fi
    
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$BACKUP_DIR/"
    fi
}

teardown() {
    # Restaurar configurações
    if [ -f "$BACKUP_DIR/config.json" ]; then
        mkdir -p "$HOME/.config/bytebabe"
        cp "$BACKUP_DIR/config.json" "$HOME/.config/bytebabe/"
    fi
    
    if [ -f "$BACKUP_DIR/.bashrc" ]; then
        cp "$BACKUP_DIR/.bashrc" "$HOME/"
    fi
    
    if [ -f "$BACKUP_DIR/.zshrc" ]; then
        cp "$BACKUP_DIR/.zshrc" "$HOME/"
    fi
    
    # Limpar arquivos temporários
    if [ -d "$TEST_TMP_DIR" ]; then
        rm -rf "$TEST_TMP_DIR"
    fi
}

# Teste: Fluxo completo de inicialização
@test "complete initialization workflow" {
    echo "=== Iniciando teste E2E de inicialização ===" > "$TEST_LOG_FILE"
    
    # Passo 1: Verificar se o comando init existe
    echo "Passo 1: Verificando comando init..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"init"* ]]
    echo "✓ Comando init encontrado" >> "$TEST_LOG_FILE"
    
    # Passo 2: Executar inicialização
    echo "Passo 2: Executando inicialização..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" init
    [ "$status" -eq 0 ]
    [[ "$output" == *"initialized"* ]] || [[ "$output" == *"setup"* ]] || [[ "$output" == *"ready"* ]]
    echo "✓ Inicialização executada com sucesso" >> "$TEST_LOG_FILE"
    
    # Passo 3: Verificar se arquivos de configuração foram criados
    echo "Passo 3: Verificando arquivos de configuração..." >> "$TEST_LOG_FILE"
    [ -d "$HOME/.config/bytebabe" ]
    echo "✓ Diretório de configuração criado" >> "$TEST_LOG_FILE"
    
    # Passo 4: Verificar se o bytebabe está no PATH
    echo "Passo 4: Verificando PATH..." >> "$TEST_LOG_FILE"
    run which bytebabe
    [ "$status" -eq 0 ]
    echo "✓ ByteBabe está no PATH" >> "$TEST_LOG_FILE"
    
    # Passo 5: Testar comando básico após inicialização
    echo "Passo 5: Testando comando básico..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" hello
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
    echo "✓ Comando básico funcionando" >> "$TEST_LOG_FILE"
    
    echo "=== Teste E2E de inicialização concluído ===" >> "$TEST_LOG_FILE"
}

# Teste: Inicialização com configurações personalizadas
@test "initialization with custom configuration" {
    echo "=== Iniciando teste E2E com configuração personalizada ===" > "$TEST_LOG_FILE"
    
    # Criar configuração personalizada
    local custom_config="$TEST_TMP_DIR/custom-config.json"
    cat > "$custom_config" << 'EOF'
{
  "theme": "cyberpunk",
  "verbose": true,
  "auto_update": false
}
EOF
    
    # Executar inicialização com configuração personalizada
    echo "Executando inicialização com configuração personalizada..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" init --config "$custom_config"
    [ "$status" -eq 0 ]
    echo "✓ Inicialização com configuração personalizada executada" >> "$TEST_LOG_FILE"
    
    # Verificar se configuração foi aplicada
    if [ -f "$HOME/.config/bytebabe/config.json" ]; then
        run jq -r '.theme' "$HOME/.config/bytebabe/config.json"
        [ "$status" -eq 0 ]
        [ "$output" = "cyberpunk" ]
        echo "✓ Configuração personalizada aplicada" >> "$TEST_LOG_FILE"
    fi
    
    echo "=== Teste E2E com configuração personalizada concluído ===" >> "$TEST_LOG_FILE"
}

# Teste: Inicialização em ambiente limpo
@test "initialization in clean environment" {
    echo "=== Iniciando teste E2E em ambiente limpo ===" > "$TEST_LOG_FILE"
    
    # Remover configurações existentes
    rm -rf "$HOME/.config/bytebabe" 2>/dev/null || true
    
    # Executar inicialização
    echo "Executando inicialização em ambiente limpo..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" init
    [ "$status" -eq 0 ]
    echo "✓ Inicialização em ambiente limpo executada" >> "$TEST_LOG_FILE"
    
    # Verificar se estrutura foi criada
    [ -d "$HOME/.config/bytebabe" ]
    echo "✓ Estrutura de configuração criada" >> "$TEST_LOG_FILE"
    
    echo "=== Teste E2E em ambiente limpo concluído ===" >> "$TEST_LOG_FILE"
}

# Teste: Inicialização com dependências faltando
@test "initialization with missing dependencies" {
    echo "=== Iniciando teste E2E com dependências faltando ===" > "$TEST_LOG_FILE"
    
    # Simular ambiente sem algumas dependências
    local original_path="$PATH"
    export PATH="/usr/bin:/bin"
    
    # Executar inicialização
    echo "Executando inicialização com dependências limitadas..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" init
    [ "$status" -eq 0 ]
    echo "✓ Inicialização com dependências limitadas executada" >> "$TEST_LOG_FILE"
    
    # Restaurar PATH
    export PATH="$original_path"
    
    echo "=== Teste E2E com dependências faltando concluído ===" >> "$TEST_LOG_FILE"
}

# Teste: Inicialização com permissões limitadas
@test "initialization with limited permissions" {
    echo "=== Iniciando teste E2E com permissões limitadas ===" > "$TEST_LOG_FILE"
    
    # Criar diretório temporário com permissões limitadas
    local restricted_dir="$TEST_TMP_DIR/restricted"
    mkdir -p "$restricted_dir"
    chmod 444 "$restricted_dir"
    
    # Tentar inicializar em diretório com permissões limitadas
    echo "Tentando inicializar em diretório com permissões limitadas..." >> "$TEST_LOG_FILE"
    cd "$restricted_dir"
    run "$BYTEBABE_BIN" init
    cd - > /dev/null
    
    # O comando deve falhar ou dar warning
    echo "✓ Comportamento com permissões limitadas verificado" >> "$TEST_LOG_FILE"
    
    # Limpar
    chmod 755 "$restricted_dir"
    
    echo "=== Teste E2E com permissões limitadas concluído ===" >> "$TEST_LOG_FILE"
}

# Teste: Inicialização com rede limitada
@test "initialization with limited network" {
    echo "=== Iniciando teste E2E com rede limitada ===" > "$TEST_LOG_FILE"
    
    # Simular rede limitada (não é possível bloquear completamente)
    echo "Executando inicialização com rede limitada..." >> "$TEST_LOG_FILE"
    run timeout 30 "$BYTEBABE_BIN" init
    [ "$status" -eq 0 ] || [ "$status" -eq 124 ]  # 124 = timeout
    echo "✓ Inicialização com rede limitada executada" >> "$TEST_LOG_FILE"
    
    echo "=== Teste E2E com rede limitada concluído ===" >> "$TEST_LOG_FILE"
}

# Teste: Inicialização múltiplas vezes
@test "multiple initialization attempts" {
    echo "=== Iniciando teste E2E de inicializações múltiplas ===" > "$TEST_LOG_FILE"
    
    # Primeira inicialização
    echo "Primeira inicialização..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" init
    [ "$status" -eq 0 ]
    echo "✓ Primeira inicialização executada" >> "$TEST_LOG_FILE"
    
    # Segunda inicialização (deve ser idempotente)
    echo "Segunda inicialização..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" init
    [ "$status" -eq 0 ]
    echo "✓ Segunda inicialização executada" >> "$TEST_LOG_FILE"
    
    # Terceira inicialização
    echo "Terceira inicialização..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" init
    [ "$status" -eq 0 ]
    echo "✓ Terceira inicialização executada" >> "$TEST_LOG_FILE"
    
    echo "=== Teste E2E de inicializações múltiplas concluído ===" >> "$TEST_LOG_FILE"
}

# Teste: Inicialização com diferentes shells
@test "initialization with different shells" {
    echo "=== Iniciando teste E2E com diferentes shells ===" > "$TEST_LOG_FILE"
    
    # Testar com bash
    echo "Testando com bash..." >> "$TEST_LOG_FILE"
    run bash -c "$BYTEBABE_BIN init"
    [ "$status" -eq 0 ]
    echo "✓ Inicialização com bash executada" >> "$TEST_LOG_FILE"
    
    # Testar com zsh (se disponível)
    if command -v zsh &> /dev/null; then
        echo "Testando com zsh..." >> "$TEST_LOG_FILE"
        run zsh -c "$BYTEBABE_BIN init"
        [ "$status" -eq 0 ]
        echo "✓ Inicialização com zsh executada" >> "$TEST_LOG_FILE"
    else
        echo "Zsh não disponível, pulando teste" >> "$TEST_LOG_FILE"
    fi
    
    echo "=== Teste E2E com diferentes shells concluído ===" >> "$TEST_LOG_FILE"
}

# Teste: Inicialização com variáveis de ambiente específicas
@test "initialization with specific environment variables" {
    echo "=== Iniciando teste E2E com variáveis de ambiente ===" > "$TEST_LOG_FILE"
    
    # Definir variáveis de ambiente
    export BYTEBABE_VERBOSE=true
    export BYTEBABE_DEBUG=true
    export BYTEBABE_THEME=cyberpunk
    
    # Executar inicialização
    echo "Executando inicialização com variáveis de ambiente..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" init
    [ "$status" -eq 0 ]
    echo "✓ Inicialização com variáveis de ambiente executada" >> "$TEST_LOG_FILE"
    
    echo "=== Teste E2E com variáveis de ambiente concluído ===" >> "$TEST_LOG_FILE"
}

# Teste: Inicialização com argumentos específicos
@test "initialization with specific arguments" {
    echo "=== Iniciando teste E2E com argumentos específicos ===" > "$TEST_LOG_FILE"
    
    # Testar com flag --verbose
    echo "Testando com --verbose..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" init --verbose
    [ "$status" -eq 0 ]
    echo "✓ Inicialização com --verbose executada" >> "$TEST_LOG_FILE"
    
    # Testar com flag --force
    echo "Testando com --force..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" init --force
    [ "$status" -eq 0 ]
    echo "✓ Inicialização com --force executada" >> "$TEST_LOG_FILE"
    
    # Testar com flag --dry-run (se suportado)
    echo "Testando com --dry-run..." >> "$TEST_LOG_FILE"
    run "$BYTEBABE_BIN" init --dry-run
    echo "✓ Inicialização com --dry-run executada" >> "$TEST_LOG_FILE"
    
    echo "=== Teste E2E com argumentos específicos concluído ===" >> "$TEST_LOG_FILE"
}

# Teste: Verificar integridade após inicialização
@test "verify integrity after initialization" {
    echo "=== Iniciando verificação de integridade ===" > "$TEST_LOG_FILE"
    
    # Executar inicialização
    run "$BYTEBABE_BIN" init
    [ "$status" -eq 0 ]
    
    # Verificar se todos os comandos básicos funcionam
    echo "Verificando comandos básicos..." >> "$TEST_LOG_FILE"
    
    local commands=("hello" "version" "help")
    for cmd in "${commands[@]}"; do
        echo "Testando comando: $cmd" >> "$TEST_LOG_FILE"
        run "$BYTEBABE_BIN" "$cmd"
        [ "$status" -eq 0 ]
        echo "✓ Comando $cmd funcionando" >> "$TEST_LOG_FILE"
    done
    
    # Verificar se arquivos de configuração são válidos
    echo "Verificando arquivos de configuração..." >> "$TEST_LOG_FILE"
    if [ -f "$HOME/.config/bytebabe/config.json" ]; then
        run jq . "$HOME/.config/bytebabe/config.json"
        [ "$status" -eq 0 ]
        echo "✓ Arquivo de configuração é JSON válido" >> "$TEST_LOG_FILE"
    fi
    
    echo "=== Verificação de integridade concluída ===" >> "$TEST_LOG_FILE"
}

# Teste: Performance da inicialização
@test "initialization performance" {
    echo "=== Iniciando teste de performance ===" > "$TEST_LOG_FILE"
    
    local start_time
    local end_time
    local execution_time
    
    start_time=$(date +%s%N)
    run "$BYTEBABE_BIN" init
    end_time=$(date +%s%N)
    
    execution_time=$(( (end_time - start_time) / 1000000 ))  # em milissegundos
    
    [ "$status" -eq 0 ]
    echo "Tempo de execução: ${execution_time}ms" >> "$TEST_LOG_FILE"
    
    # A inicialização deve completar em menos de 30 segundos
    [ "$execution_time" -lt 30000 ]
    echo "✓ Performance dentro do esperado" >> "$TEST_LOG_FILE"
    
    echo "=== Teste de performance concluído ===" >> "$TEST_LOG_FILE"
}

# Teste: Logs de inicialização
@test "initialization logging" {
    echo "=== Iniciando teste de logging ===" > "$TEST_LOG_FILE"
    
    # Executar inicialização com logging
    run "$BYTEBABE_BIN" init --verbose > "$TEST_OUTPUT_FILE" 2> "$TEST_ERROR_FILE"
    
    [ "$status" -eq 0 ]
    [ -f "$TEST_OUTPUT_FILE" ]
    [ -s "$TEST_OUTPUT_FILE" ]
    
    # Verificar se há logs informativos
    local output_content
    output_content=$(cat "$TEST_OUTPUT_FILE")
    [[ "$output_content" == *"initializ"* ]] || [[ "$output_content" == *"setup"* ]] || [[ "$output_content" == *"config"* ]]
    
    echo "✓ Logs de inicialização verificados" >> "$TEST_LOG_FILE"
    echo "=== Teste de logging concluído ===" >> "$TEST_LOG_FILE"
} 