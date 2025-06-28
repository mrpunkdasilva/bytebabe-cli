#!/usr/bin/env bats

# ByteBabe CLI - Teste Unitário: Comando Hello
# Descrição: Testa o comando hello do ByteBabe CLI

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
    
    # Verificar se é executável
    if [ ! -x "$BYTEBABE_BIN" ]; then
        chmod +x "$BYTEBABE_BIN"
    fi
    
    # Criar diretório temporário para testes
    export TEST_TMP_DIR="$(mktemp -d)"
    export TEST_OUTPUT_FILE="$TEST_TMP_DIR/output.txt"
    export TEST_ERROR_FILE="$TEST_TMP_DIR/error.txt"
}

teardown() {
    # Limpar arquivos temporários
    if [ -d "$TEST_TMP_DIR" ]; then
        rm -rf "$TEST_TMP_DIR"
    fi
}

# Teste: Comando hello sem argumentos
@test "hello command without arguments" {
    run "$BYTEBABE_BIN" hello
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
    [[ "$output" == *"Cyberpunk"* ]]
}

# Teste: Comando hello com argumento
@test "hello command with argument" {
    run "$BYTEBABE_BIN" hello "TestUser"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
    [[ "$output" == *"TestUser"* ]]
}

# Teste: Comando hello com múltiplos argumentos
@test "hello command with multiple arguments" {
    run "$BYTEBABE_BIN" hello "User1" "User2"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
    [[ "$output" == *"User1"* ]]
}

# Teste: Comando hello com argumentos especiais
@test "hello command with special characters" {
    run "$BYTEBABE_BIN" hello "User@123"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
    [[ "$output" == *"User@123"* ]]
}

# Teste: Comando hello com argumentos vazios
@test "hello command with empty arguments" {
    run "$BYTEBABE_BIN" hello ""
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
}

# Teste: Comando hello com argumentos muito longos
@test "hello command with very long argument" {
    local long_name="$(printf 'A%.0s' {1..1000})"
    run "$BYTEBABE_BIN" hello "$long_name"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
}

# Teste: Comando hello com caracteres Unicode
@test "hello command with unicode characters" {
    run "$BYTEBABE_BIN" hello "João"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
    [[ "$output" == *"João"* ]]
}

# Teste: Verificar se o comando hello existe
@test "hello command exists" {
    run "$BYTEBABE_BIN" --help
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"hello"* ]]
}

# Teste: Verificar ajuda do comando hello
@test "hello command help" {
    run "$BYTEBABE_BIN" hello --help
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"hello"* ]]
}

# Teste: Verificar se o comando hello é executável
@test "hello command is executable" {
    [ -x "$BYTEBABE_BIN" ]
}

# Teste: Verificar formato da saída
@test "hello command output format" {
    run "$BYTEBABE_BIN" hello "TestUser"
    
    [ "$status" -eq 0 ]
    # Verificar se a saída não está vazia
    [ -n "$output" ]
    # Verificar se não contém caracteres de controle estranhos
    [[ "$output" =~ ^[[:print:][:space:]]*$ ]]
}

# Teste: Verificar performance do comando
@test "hello command performance" {
    local start_time
    local end_time
    local execution_time
    
    start_time=$(date +%s%N)
    run "$BYTEBABE_BIN" hello "TestUser"
    end_time=$(date +%s%N)
    
    execution_time=$(( (end_time - start_time) / 1000000 ))  # em milissegundos
    
    [ "$status" -eq 0 ]
    # O comando deve executar em menos de 1 segundo
    [ "$execution_time" -lt 1000 ]
}

# Teste: Verificar se o comando não deixa processos órfãos
@test "hello command no orphaned processes" {
    local initial_processes
    local final_processes
    
    initial_processes=$(pgrep -c "$(basename "$BYTEBABE_BIN")" || echo "0")
    
    run "$BYTEBABE_BIN" hello "TestUser"
    
    # Aguardar um pouco para garantir que processos sejam finalizados
    sleep 0.1
    
    final_processes=$(pgrep -c "$(basename "$BYTEBABE_BIN")" || echo "0")
    
    [ "$status" -eq 0 ]
    [ "$initial_processes" -eq "$final_processes" ]
}

# Teste: Verificar se o comando funciona em diferentes diretórios
@test "hello command works from different directories" {
    local original_dir
    local temp_dir
    
    original_dir=$(pwd)
    temp_dir=$(mktemp -d)
    
    cd "$temp_dir"
    run "$BYTEBABE_BIN" hello "TestUser"
    cd "$original_dir"
    
    rm -rf "$temp_dir"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
}

# Teste: Verificar se o comando respeita variáveis de ambiente
@test "hello command respects environment variables" {
    export BYTEBABE_TEST_MODE=true
    export BYTEBABE_VERBOSE=true
    
    run "$BYTEBABE_BIN" hello "TestUser"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
}

# Teste: Verificar se o comando não falha com entrada inválida
@test "hello command handles invalid input gracefully" {
    # Testar com caracteres de controle
    run "$BYTEBABE_BIN" hello $'\x00\x01\x02'
    
    # O comando deve não falhar (pode ignorar caracteres inválidos)
    [ "$status" -eq 0 ]
}

# Teste: Verificar se o comando funciona com redirecionamento
@test "hello command works with redirection" {
    run "$BYTEBABE_BIN" hello "TestUser" > "$TEST_OUTPUT_FILE" 2> "$TEST_ERROR_FILE"
    
    [ "$status" -eq 0 ]
    [ -f "$TEST_OUTPUT_FILE" ]
    [ -s "$TEST_OUTPUT_FILE" ]  # Arquivo não está vazio
    
    local output_content
    output_content=$(cat "$TEST_OUTPUT_FILE")
    [[ "$output_content" == *"Hello"* ]]
}

# Teste: Verificar se o comando não gera erros em stderr
@test "hello command produces no stderr output" {
    run "$BYTEBABE_BIN" hello "TestUser" 2> "$TEST_ERROR_FILE"
    
    [ "$status" -eq 0 ]
    [ -f "$TEST_ERROR_FILE" ]
    [ ! -s "$TEST_ERROR_FILE" ]  # Arquivo de erro deve estar vazio
}

# Teste: Verificar se o comando funciona com pipe
@test "hello command works with pipe" {
    run bash -c "$BYTEBABE_BIN hello 'TestUser' | grep -i hello"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
}

# Teste: Verificar se o comando funciona com subshell
@test "hello command works in subshell" {
    run bash -c "(\"$BYTEBABE_BIN\" hello 'TestUser')"
    
    [ "$status" -eq 0 ]
    [[ "$output" == *"Hello"* ]]
} 