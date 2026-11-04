#!/bin/bash

BASE_DIR="${BASE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/azure/main.sh"

show_azure_header() {
    echo -e "${CYBER_BLUE}"
    cat << "EOF"
 █████╗ ███████╗██╗   ██╗██████╗ ███████╗
██╔══██╗╚══███╔╝██║   ██║██╔══██╗██╔════╝
███████║  ███╔╝ ██║   ██║██████╔╝█████╗
██╔══██║ ███╔╝  ██║   ██║██╔══██╗██╔══╝
██║  ██║███████╗╚██████╔╝██║  ██║███████╗
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
EOF
    echo -e "${RESET}"
}

_azure_banner() {
    echo -e "${CYBER_PINK}╔══════════════════════════════════════════════════╗"
    echo -e "║${CYBER_CYAN}  $1  ${CYBER_PINK}"
    echo -e "╚══════════════════════════════════════════════════╝${RESET}"
}

main() {
    local cmd=${1:-help}
    [ $# -gt 0 ] && shift

    case "$cmd" in
        install|i)
            show_azure_header
            _azure_banner "INSTALANDO INTERFACE AZURE CLI..."
            az_install
            ;;
        setup)
            show_azure_header
            _azure_banner "CONECTANDO À NUVEM AZURE DEVOPS..."
            az_setup "$@"
            ;;
        login|auth)
            show_azure_header
            _azure_banner "AUTENTICANDO CONEXÃO SECRETA..."
            az_login "$@"
            ;;
        pr)
            show_azure_header
            _azure_banner "INICIANDO PROTOCOLO DE FUSÃO DE REALIDADES..."
            az_pr "$@"
            ;;
        prs|pr-list|search-pr|pr-search|find-pr)
            show_azure_header
            _azure_banner "ESCANEANDO PORTAIS INTERDIMENSIONAIS ABERTOS..."
            az_prs "$@"
            ;;
        projects|proj)
            show_azure_header
            _azure_banner "MAPEANDO SETORES DA MEGACORP AZURE..."
            az_projects "$@"
            ;;
        branches|br|refs)
            show_azure_header
            _azure_banner "ESCANEANDO FLUXOS TEMPORAIS DO REPOSITÓRIO..."
            az_branches "$@"
            ;;
        tags|tag)
            show_azure_header
            _azure_banner "INVENTARIANDO ARTEFATOS SELADOS DO REPOSITÓRIO..."
            az_tags "$@"
            ;;
        merge)
            show_azure_header
            _azure_banner "FUNDINDO REALIDADES NA LINHA TEMPORAL PRINCIPAL..."
            az_merge "$@"
            ;;
        project|repo|pr-manage|pipeline|boards|artifacts|devops|cli)
            az_operations "$cmd" "$@"
            ;;
        help|--help|-h)
            show_azure_header
            az_help
            ;;
        *)
            show_azure_header
            echo -e "${CYBER_RED}Comando inválido: $cmd${RESET}"
            az_help
            return 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
