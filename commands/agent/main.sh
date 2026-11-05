#!/bin/bash

# ==================================================
# MODULE AGENT — gera o knowledge pack de IA (.bytebabe/)
# ==================================================

source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

# ==========================================
# FUNÇÕES PRINCIPAIS
# ==========================================

show_agent_header() {
    echo -e "${CYBER_PINK}"
    echo '╔══════════════════════════════════════════════╗'
    echo '║      ⛁ AGENT KNOWLEDGE PACK — BYTEBABE       ║'
    echo '╚══════════════════════════════════════════════╝'
    echo -e "${RESET}"
    cyber_divider
}

agent_usage() {
    echo -e "${CYBER_CYAN}Uso: bytebabe agent <comando>${RESET}"
    echo ""
    echo -e "${CYBER_YELLOW}Comandos:${RESET}"
    echo -e "${CYBER_GREEN}  init${RESET}      Gera .bytebabe/SKILL.md com o conhecimento da CLI"
    echo -e "${CYBER_GREEN}  update${RESET}    Regenera o pack (sobrescreve arquivos gerados)"
    echo -e "${CYBER_GREEN}  status${RESET}    Mostra o estado do pack no diretório atual"
    echo -e "${CYBER_GREEN}  remove${RESET}    Remove o pack (.bytebabe/)"
    echo -e "${CYBER_GREEN}  help${RESET}      Mostra esta ajuda"
}

agent_source_lib() {
    source "${BASE_DIR}/lib/agent/skill.sh"
}

agent_target_files() {
    printf '.bytebabe/SKILL.md\n.bytebabe/README.md\n'
}

agent_write_file() {
    local target="$1"
    local parent
    parent="$(dirname "$target")"
    mkdir -p "$parent" || { echo "Falha ao criar $parent" >&2; return 1; }
    render_skill_md > "$target"
}

agent_init() {
    agent_source_lib

    echo -e "\n${CYBER_YELLOW}⚡ Gerando knowledge pack em .bytebabe/...${RESET}"

    agent_write_file ".bytebabe/SKILL.md" || return 1
    render_agent_readme_md > ".bytebabe/README.md"

    echo -e "${CYBER_GREEN}✔ Pack criado:${RESET}"
    agent_target_files | while read -r target; do
        echo -e "${CYBER_CYAN}  - ${target}${RESET}"
    done
    echo -e "${CYBER_GRAY}╰┈➤ Mantenha o pack atualizado após evoluir a CLI: bytebabe agent update${RESET}"
    return 0
}

agent_status() {
    agent_source_lib >/dev/null 2>&1

    if [[ -f .bytebabe/SKILL.md ]]; then
        echo -e "${CYBER_GREEN}✔ .bytebabe/SKILL.md presente${RESET}"
        return 0
    fi
    echo -e "${CYBER_RED}✘ .bytebabe/SKILL.md ausente${RESET}"
    echo -e "${CYBER_GRAY}╰┈➤ Nada encontrado ainda: bytebabe agent init${RESET}"
    return 1
}

agent_remove() {
    if [[ ! -d .bytebabe ]]; then
        echo -e "${CYBER_GRAY}• Nenhum pack instalado neste diretório.${RESET}"
        return 0
    fi

    local reply=""
    read -rp "$(echo -e "
${CYBER_YELLOW}? Remover ${CYBER_RED}.bytebabe/${CYBER_YELLOW} deste diretório? [s/N]: ${RESET}")" reply
    if [[ ! $reply =~ ^[sS][iI]?m?$ ]]; then
        echo -e "${CYBER_GRAY}• Operação cancelada.${RESET}"
        return 0
    fi

    rm -rf .bytebabe
    echo -e "${CYBER_GREEN}✔ Pack removido da plataforma.${RESET}"
    return 0
}

# ==========================================
# DISPATCH
# ==========================================

main() {
    local action="${1:-init}"
    [[ $# -gt 0 ]] && shift

    case "$action" in
        init|update)
            show_agent_header
            agent_init "$@"
            ;;
        status)
            agent_status
            ;;
        remove)
            agent_remove
            ;;
        help|-h|--help)
            show_agent_header
            agent_usage
            ;;
        *)
            show_agent_header
            agent_usage
            echo -e "${CYBER_RED}✘ Ação desconhecida: ${action}${RESET}"
            return 1
            ;;
    esac
}

# Executa apenas quando chamado diretamente
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
