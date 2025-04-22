#!/bin/bash

# Carrega o diretório base
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../" && pwd)"

# Carrega as dependências
source "$BASE_DIR/lib/backend/spring/help.sh"

# Handler principal de comandos
case "$1" in
    help|--help|-h)
        show_spring_help
        ;;
    generate|g)
        shift
        case "$1" in
            help|--help|-h)
                show_spring_generate_help
                ;;
            *)
                echo -e "${CYBER_RED}⚠️  Comando generate ainda não implementado${RESET}"
                ;;
        esac
        ;;
    *)
        show_spring_help
        ;;
esac