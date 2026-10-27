#!/bin/bash

# Histórico do Flux e pontes de compatibilidade.
# Deve permanecer seguro para source: apenas define funções.

if [[ -z "${BASE_DIR:-}" ]]; then
    _flux_request_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BASE_DIR="$(cd "$_flux_request_dir/../.." && pwd)"
    unset _flux_request_dir
fi

if ! declare -F save_request_history >/dev/null 2>&1; then
    # shellcheck source=history.sh
    source "$BASE_DIR/lib/flux/history.sh"
fi

# Processa e salva uma requisição no histórico.
process_request_for_history() {
    local method="$1"
    local url="$2"
    local headers="$3"
    local body="$4"
    local response="$5"
    local status_code="$6"

    if ! declare -F save_request_history >/dev/null 2>&1; then
        echo -e "${CYBER_YELLOW:-}Warning: history module is not loaded${RESET:-}" >&2
        return 1
    fi

    save_request_history "$method" "$url" "$headers" "$body" "$response" "$status_code"
}

# Menu interativo do histórico.
show_history_menu() {
    local option req_num filename method_choice

    init_history

    while true; do
        show_history_header
        echo -e "${CYBER_PURPLE:-}╔═══════════════════════════════════════════════════════════════╗${RESET:-}"
        echo -e "${CYBER_PURPLE:-}║ ${CYBER_CYAN:-}${BOLD:-}MENU DE HISTÓRICO${RESET:-}${CYBER_PURPLE:-}                                    ║${RESET:-}"
        echo -e "${CYBER_PURPLE:-}╚═══════════════════════════════════════════════════════════════╝${RESET:-}"
        echo
        echo -e "  ${CYBER_BLUE:-}[1]${RESET:-} ${CYBER_CYAN:-}Listar histórico${RESET:-}"
        echo -e "  ${CYBER_BLUE:-}[2]${RESET:-} ${CYBER_CYAN:-}Ver detalhes de uma requisição${RESET:-}"
        echo -e "  ${CYBER_BLUE:-}[3]${RESET:-} ${CYBER_CYAN:-}Limpar histórico${RESET:-}"
        echo -e "  ${CYBER_BLUE:-}[4]${RESET:-} ${CYBER_CYAN:-}Exportar histórico${RESET:-}"
        echo -e "  ${CYBER_BLUE:-}[5]${RESET:-} ${CYBER_CYAN:-}Forçar limpeza do histórico${RESET:-}"
        echo -e "  ${CYBER_BLUE:-}[6]${RESET:-} ${CYBER_CYAN:-}Filtrar por método${RESET:-}"
        echo -e "  ${CYBER_BLUE:-}[7]${RESET:-} ${CYBER_CYAN:-}Estatísticas do histórico${RESET:-}"
        echo -e "  ${CYBER_BLUE:-}[0]${RESET:-} ${CYBER_CYAN:-}Voltar${RESET:-}"
        echo
        echo -e "${CYBER_PURPLE:-}───────────────────────────────────────────────────────────────${RESET:-}"
        echo -ne "${CYBER_PINK:-}Escolha uma opção: ${RESET:-}"
        read -r option || return 0

        case "$option" in
            1)
                clear
                list_request_history
                echo
                echo -ne "${CYBER_BLUE:-}Pressione Enter para continuar...${RESET:-}"
                read -r || return 0
                ;;
            2)
                clear
                list_request_history
                echo
                echo -ne "${CYBER_PINK:-}Digite o número da requisição: ${RESET:-}"
                read -r req_num || return 0
                clear
                view_request_details "$req_num"
                ;;
            3)
                clear
                clear_request_history
                echo
                echo -ne "${CYBER_BLUE:-}Pressione Enter para continuar...${RESET:-}"
                read -r || return 0
                ;;
            4)
                clear
                echo -e "${CYBER_PURPLE:-}╔═══════════════════════════════════════════════════════════════╗${RESET:-}"
                echo -e "${CYBER_PURPLE:-}║ ${CYBER_CYAN:-}${BOLD:-}EXPORTAR HISTÓRICO${RESET:-}${CYBER_PURPLE:-}                                  ║${RESET:-}"
                echo -e "${CYBER_PURPLE:-}╚═══════════════════════════════════════════════════════════════╝${RESET:-}"
                echo
                echo -e "${CYBER_YELLOW:-}[i] O arquivo será salvo na pasta home do usuário se não for especificado um caminho completo.${RESET:-}"
                echo -e "${CYBER_YELLOW:-}[i] Exemplo: ${CYBER_CYAN:-}meu_historico.json${RESET:-} será salvo como ${CYBER_CYAN:-}$HOME/meu_historico.json${RESET:-}"
                echo
                echo -ne "${CYBER_PINK:-}Digite o nome do arquivo (ou Enter para padrão): ${RESET:-}"
                read -r filename || return 0
                export_request_history "$filename"
                echo
                echo -ne "${CYBER_BLUE:-}Pressione Enter para continuar...${RESET:-}"
                read -r || return 0
                ;;
            5)
                clear
                echo -e "${CYBER_YELLOW:-}[!] Forçando limpeza do histórico...${RESET:-}"
                clear_request_history 1
                echo
                echo -ne "${CYBER_BLUE:-}Pressione Enter para continuar...${RESET:-}"
                read -r || return 0
                ;;
            6)
                clear
                echo -e "${CYBER_PURPLE:-}╔═══════════════════════════════════════════════════════════════╗${RESET:-}"
                echo -e "${CYBER_PURPLE:-}║ ${CYBER_CYAN:-}${BOLD:-}FILTRAR HISTÓRICO${RESET:-}${CYBER_PURPLE:-}                                  ║${RESET:-}"
                echo -e "${CYBER_PURPLE:-}╚═══════════════════════════════════════════════════════════════╝${RESET:-}"
                echo
                echo -e "  ${CYBER_BLUE:-}[1]${RESET:-} ${CYBER_CYAN:-}GET${RESET:-}"
                echo -e "  ${CYBER_BLUE:-}[2]${RESET:-} ${CYBER_CYAN:-}POST${RESET:-}"
                echo -e "  ${CYBER_BLUE:-}[3]${RESET:-} ${CYBER_CYAN:-}PUT${RESET:-}"
                echo -e "  ${CYBER_BLUE:-}[4]${RESET:-} ${CYBER_CYAN:-}DELETE${RESET:-}"
                echo -e "  ${CYBER_BLUE:-}[0]${RESET:-} ${CYBER_CYAN:-}Voltar${RESET:-}"
                echo
                echo -ne "${CYBER_PINK:-}Escolha um método: ${RESET:-}"
                read -r method_choice || return 0

                case "$method_choice" in
                    1) clear; filter_request_history "GET" ;;
                    2) clear; filter_request_history "POST" ;;
                    3) clear; filter_request_history "PUT" ;;
                    4) clear; filter_request_history "DELETE" ;;
                    0) ;;
                    *) echo -e "${CYBER_RED:-}[✗] Opção inválida${RESET:-}"; sleep 1 ;;
                esac

                echo
                echo -ne "${CYBER_BLUE:-}Pressione Enter para continuar...${RESET:-}"
                read -r || return 0
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${CYBER_RED:-}[✗] Opção inválida${RESET:-}"
                sleep 1
                ;;
        esac
    done
}

# Mantidas para compatibilidade com menus antigos.
add_history_option_to_menu() {
    echo -e "H) ${CYBER_CYAN:-}Histórico de Requisições${RESET:-}"
}

handle_history_option() {
    show_history_menu
}
