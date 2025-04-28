#!/bin/bash

show_alias_header() {
    echo -e "${CYBER_GREEN}╔════════════════════════════════════════════════╗"
    echo -e "║             🔧 ALIAS MANAGER                 ║"
    echo -e "╚════════════════════════════════════════════════╝${RESET}"
}

show_alias_help() {
    show_alias_header
    
    echo -e "\n${CYBER_BLUE}USAGE:${RESET}"
    echo -e "  bytebabe alias ${CYBER_YELLOW}[command] [options]${RESET}"
    
    echo -e "\n${CYBER_BLUE}COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}list, ls${RESET}         Lista todos os aliases"
    echo -e "  ${CYBER_GREEN}add, a${RESET}           Adiciona novo alias"
    echo -e "  ${CYBER_GREEN}remove, rm${RESET}       Remove um alias"
    echo -e "  ${CYBER_GREEN}edit, e${RESET}          Edita um alias existente"
    echo -e "  ${CYBER_GREEN}template, t${RESET}      Gerencia templates de alias"
    echo -e "  ${CYBER_GREEN}backup, b${RESET}        Gerencia backups de alias"
    echo -e "  ${CYBER_GREEN}analyze, an${RESET}      Analisa uso dos aliases"
    
    echo -e "\n${CYBER_BLUE}TEMPLATE COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}template list${RESET}    Lista templates disponíveis"
    echo -e "  ${CYBER_GREEN}template apply${RESET}   Aplica um template específico"
    echo -e "  ${CYBER_GREEN}template show${RESET}    Mostra detalhes de um template"
    
    echo -e "\n${CYBER_BLUE}BACKUP COMMANDS:${RESET}"
    echo -e "  ${CYBER_GREEN}backup create${RESET}    Cria novo backup"
    echo -e "  ${CYBER_GREEN}backup list${RESET}      Lista backups disponíveis"
    echo -e "  ${CYBER_GREEN}backup restore${RESET}   Restaura um backup"
    
    echo -e "\n${CYBER_BLUE}OPTIONS:${RESET}"
    echo -e "  ${CYBER_YELLOW}-n, --name${RESET}      Nome do alias"
    echo -e "  ${CYBER_YELLOW}-c, --command${RESET}   Comando a ser executado"
    echo -e "  ${CYBER_YELLOW}-f, --force${RESET}     Força operação sem confirmação"
    
    echo -e "\n${CYBER_BLUE}EXAMPLES:${RESET}"
    echo -e "  ${CYBER_CYAN}# Adicionar novo alias${RESET}"
    echo -e "  bytebabe alias add -n gp -c 'git push'"
    
    echo -e "\n  ${CYBER_CYAN}# Aplicar template${RESET}"
    echo -e "  bytebabe alias template apply git"
    
    echo -e "\n  ${CYBER_CYAN}# Criar backup${RESET}"
    echo -e "  bytebabe alias backup create"
    
    echo -e "\n  ${CYBER_CYAN}# Restaurar backup${RESET}"
    echo -e "  bytebabe alias backup restore backup_20240101.json"
    
    echo -e "\n  ${CYBER_CYAN}# Analisar uso${RESET}"
    echo -e "  bytebabe alias analyze"
}

show_template_help() {
    show_alias_header
    
    echo -e "\n${CYBER_BLUE}TEMPLATE USAGE:${RESET}"
    echo -e "  bytebabe alias template ${CYBER_YELLOW}<action> [options]${RESET}"
    
    echo -e "\n${CYBER_BLUE}ACTIONS:${RESET}"
    echo -e "  ${CYBER_GREEN}list${RESET}     Lista todos os templates disponíveis"
    echo -e "  ${CYBER_GREEN}apply${RESET}    Aplica um template específico"
    echo -e "  ${CYBER_GREEN}show${RESET}     Mostra detalhes de um template"
    
    echo -e "\n${CYBER_BLUE}AVAILABLE TEMPLATES:${RESET}"
    echo -e "  ${CYBER_GREEN}git${RESET}         Aliases comuns para Git"
    echo -e "  ${CYBER_GREEN}docker${RESET}      Aliases para Docker"
    echo -e "  ${CYBER_GREEN}kubernetes${RESET}  Aliases para Kubernetes"
    
    echo -e "\n${CYBER_BLUE}EXAMPLES:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias template list${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias template apply git${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias template show docker${RESET}"
}

show_backup_help() {
    show_alias_header
    
    echo -e "\n${CYBER_BLUE}BACKUP USAGE:${RESET}"
    echo -e "  bytebabe alias backup ${CYBER_YELLOW}<action> [options]${RESET}"
    
    echo -e "\n${CYBER_BLUE}ACTIONS:${RESET}"
    echo -e "  ${CYBER_GREEN}create${RESET}   Cria novo backup dos aliases"
    echo -e "  ${CYBER_GREEN}list${RESET}     Lista backups disponíveis"
    echo -e "  ${CYBER_GREEN}restore${RESET}  Restaura um backup específico"
    
    echo -e "\n${CYBER_BLUE}OPTIONS:${RESET}"
    echo -e "  ${CYBER_YELLOW}-f, --force${RESET}    Força restauração sem confirmação"
    
    echo -e "\n${CYBER_BLUE}BACKUP LOCATION:${RESET}"
    echo -e "  ${CYBER_GREEN}$HOME/.bytebabe/backups/aliases/${RESET}"
    
    echo -e "\n${CYBER_BLUE}EXAMPLES:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias backup create${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias backup list${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias backup restore backup_20240101.json${RESET}"
}

show_analyze_help() {
    show_alias_header
    
    echo -e "\n${CYBER_BLUE}ANALYZE USAGE:${RESET}"
    echo -e "  bytebabe alias analyze ${CYBER_YELLOW}[options]${RESET}"
    
    echo -e "\n${CYBER_BLUE}OPTIONS:${RESET}"
    echo -e "  ${CYBER_GREEN}--detailed${RESET}    Mostra análise detalhada"
    echo -e "  ${CYBER_GREEN}--export${RESET}      Exporta análise para arquivo"
    
    echo -e "\n${CYBER_BLUE}ANALYSIS INCLUDES:${RESET}"
    echo -e "  ${CYBER_GREEN}• Total de aliases${RESET}"
    echo -e "  ${CYBER_GREEN}• Distribuição por categoria${RESET}"
    echo -e "  ${CYBER_GREEN}• Aliases mais usados${RESET}"
    echo -e "  ${CYBER_GREEN}• Sugestões de otimização${RESET}"
    
    echo -e "\n${CYBER_BLUE}EXAMPLES:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias analyze${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias analyze --detailed${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe alias analyze --export report.json${RESET}"
}