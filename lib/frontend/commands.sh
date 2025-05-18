#!/bin/bash

# Arquivo de comandos para o frontend
# Este arquivo foi criado para resolver o problema de importação no main.sh

# Função para executar comandos npm
run_npm_command() {
    local command="$1"
    shift
    npm run "$command" "$@"
}

# Função para executar comandos yarn
run_yarn_command() {
    local command="$1"
    shift
    yarn "$command" "$@"
}

# Função para executar comandos pnpm
run_pnpm_command() {
    local command="$1"
    shift
    pnpm "$command" "$@"
}

# Função para executar comandos bun
run_bun_command() {
    local command="$1"
    shift
    bun "$command" "$@"
}

# Função para detectar o gerenciador de pacotes do projeto
detect_package_manager() {
    if [[ -f "yarn.lock" ]]; then
        echo "yarn"
    elif [[ -f "pnpm-lock.yaml" ]]; then
        echo "pnpm"
    elif [[ -f "bun.lockb" ]]; then
        echo "bun"
    else
        echo "npm"
    fi
}

# Função para executar comandos com o gerenciador de pacotes detectado
run_command() {
    local command="$1"
    shift
    
    local pm=$(detect_package_manager)
    
    case "$pm" in
        "yarn")
            run_yarn_command "$command" "$@"
            ;;
        "pnpm")
            run_pnpm_command "$command" "$@"
            ;;
        "bun")
            run_bun_command "$command" "$@"
            ;;
        *)
            run_npm_command "$command" "$@"
            ;;
    esac
}