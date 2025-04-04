#!/bin/bash

# Configurações
QUARANTINE_DIR="/var/lib/bytebabe/quarantine"
QUARANTINE_LOG="/var/log/bytebabe/quarantine.log"

# Função para mostrar ajuda
show_quarantine_help() {
    show_header_custom "MALWARE QUARANTINE" "☣️" "${CYBER_RED}"
    
    echo -e "${CYBER_BLUE}USAGE:${NC}"
    echo -e "  prime quarantine ${CYBER_YELLOW}<command>${NC} [options]"
    echo
    
    echo -e "${CYBER_BLUE}COMMANDS:${NC}"
    echo -e "  ${CYBER_GREEN}list${NC}        Lista itens em quarentena"
    echo -e "  ${CYBER_GREEN}isolate${NC}     Isola arquivo suspeito"
    echo -e "  ${CYBER_GREEN}restore${NC}     Restaura arquivo da quarentena"
    echo -e "  ${CYBER_GREEN}remove${NC}      Remove ameaça permanentemente"
    echo -e "  ${CYBER_GREEN}analyze${NC}     Analisa item em quarentena"
    echo
    
    echo -e "${CYBER_BLUE}OPTIONS:${NC}"
    echo -e "  ${CYBER_YELLOW}--force${NC}     Força operação"
    echo -e "  ${CYBER_YELLOW}--deep${NC}      Análise profunda"
    echo -e "  ${CYBER_YELLOW}--verbose${NC}   Saída detalhada"
    echo
    
    echo -e "${CYBER_BLUE}EXAMPLES:${NC}"
    echo -e "  ${CYBER_YELLOW}prime quarantine list${NC}"
    echo -e "  ${CYBER_YELLOW}prime quarantine isolate /path/to/suspicious/file${NC}"
    echo -e "  ${CYBER_YELLOW}prime quarantine analyze --deep threat_123${NC}"
}

# Função para inicializar ambiente
setup_quarantine_env() {
    sudo mkdir -p "$QUARANTINE_DIR"
    sudo chmod 700 "$QUARANTINE_DIR"
    sudo touch "$QUARANTINE_LOG"
    sudo chmod 600 "$QUARANTINE_LOG"
}

# Função para registrar logs
log_quarantine() {
    local action="$1"
    local item="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $action: $item" | sudo tee -a "$QUARANTINE_LOG" > /dev/null
}

# Lista itens em quarentena
list_quarantine() {
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║ ${CYBER_RED}QUARANTINED ITEMS ${CYBER_BLUE}                                              ║${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
    
    if [ -d "$QUARANTINE_DIR" ] && [ "$(ls -A $QUARANTINE_DIR)" ]; then
        for item in "$QUARANTINE_DIR"/*; do
            local name=$(basename "$item")
            local date=$(stat -c %y "$item" | cut -d' ' -f1)
            local risk=$(cat "$item.meta" 2>/dev/null | grep "RISK:" | cut -d':' -f2 || echo "Unknown")
            
            echo -e "${CYBER_YELLOW}Item:${NC} $name"
            echo -e "${CYBER_YELLOW}Data:${NC} $date"
            echo -e "${CYBER_YELLOW}Risco:${NC} $risk\n"
        done
    else
        echo -e "${CYBER_GREEN}Nenhum item em quarentena${NC}"
    fi
    
    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
}

# Isola arquivo suspeito
isolate_file() {
    local file="$1"
    local force="$2"
    
    if [ ! -f "$file" ]; then
        echo -e "${CYBER_RED}✖ Arquivo não encontrado: $file${RESET}"
        return 1
    fi
    
    local hash=$(sha256sum "$file" | cut -d' ' -f1)
    local quarantine_file="$QUARANTINE_DIR/$hash"
    
    # Verifica se arquivo já está em quarentena
    if [ -f "$quarantine_file" ] && [ "$force" != "--force" ]; then
        echo -e "${CYBER_YELLOW}⚠ Arquivo já está em quarentena${RESET}"
        return 1
    }
    
    # Move arquivo para quarentena
    if sudo mv "$file" "$quarantine_file"; then
        # Cria metadados
        {
            echo "ORIGINAL_PATH:$file"
            echo "RISK:Medium"
            echo "TIMESTAMP:$(date '+%Y-%m-%d %H:%M:%S')"
        } | sudo tee "$quarantine_file.meta" > /dev/null
        
        log_quarantine "ISOLATED" "$file"
        echo -e "${CYBER_GREEN}✔ Arquivo isolado com sucesso${RESET}"
    else
        echo -e "${CYBER_RED}✖ Falha ao isolar arquivo${RESET}"
        return 1
    fi
}

# Restaura arquivo da quarentena
restore_file() {
    local hash="$1"
    local quarantine_file="$QUARANTINE_DIR/$hash"
    
    if [ ! -f "$quarantine_file" ]; then
        echo -e "${CYBER_RED}✖ Item não encontrado na quarentena${RESET}"
        return 1
    }
    
    local original_path=$(cat "$quarantine_file.meta" | grep "ORIGINAL_PATH:" | cut -d':' -f2)
    
    if sudo mv "$quarantine_file" "$original_path"; then
        sudo rm "$quarantine_file.meta"
        log_quarantine "RESTORED" "$original_path"
        echo -e "${CYBER_GREEN}✔ Arquivo restaurado com sucesso${RESET}"
    else
        echo -e "${CYBER_RED}✖ Falha ao restaurar arquivo${RESET}"
        return 1
    fi
}

# Remove ameaça permanentemente
remove_threat() {
    local hash="$1"
    local quarantine_file="$QUARANTINE_DIR/$hash"
    
    if [ ! -f "$quarantine_file" ]; then
        echo -e "${CYBER_RED}✖ Item não encontrado na quarentena${RESET}"
        return 1
    }
    
    echo -e "${CYBER_RED}⚠ ATENÇÃO: Esta ação é irreversível!${RESET}"
    read -p "$(echo -e ${CYBER_YELLOW}"Confirma remoção? (y/N): "${NC})" confirm
    
    if [[ $confirm =~ ^[Yy]$ ]]; then
        if sudo rm -f "$quarantine_file" "$quarantine_file.meta"; then
            log_quarantine "REMOVED" "$hash"
            echo -e "${CYBER_GREEN}✔ Ameaça removida permanentemente${RESET}"
        else
            echo -e "${CYBER_RED}✖ Falha ao remover ameaça${RESET}"
            return 1
        fi
    fi
}

# Analisa item em quarentena
analyze_item() {
    local hash="$1"
    local deep="$2"
    local quarantine_file="$QUARANTINE_DIR/$hash"
    
    if [ ! -f "$quarantine_file" ]; then
        echo -e "${CYBER_RED}✖ Item não encontrado na quarentena${RESET}"
        return 1
    }
    
    echo -e "\n${CYBER_BLUE}╔══════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║ ${CYBER_RED}THREAT ANALYSIS ${CYBER_BLUE}                                                ║${RESET}"
    echo -e "${CYBER_BLUE}╠══════════════════════════════════════════════════════════════════════╣${RESET}"
    
    # Análise básica
    echo -e "${CYBER_YELLOW}Análise Básica:${NC}"
    echo -e "Hash: $(sha256sum "$quarantine_file" | cut -d' ' -f1)"
    echo -e "Tipo: $(file -b "$quarantine_file")"
    echo -e "Tamanho: $(du -h "$quarantine_file" | cut -f1)"
    
    # Análise profunda se solicitado
    if [ "$deep" == "--deep" ]; then
        echo -e "\n${CYBER_YELLOW}Análise Profunda:${NC}"
        if command -v clamav &> /dev/null; then
            sudo clamscan --no-summary "$quarantine_file"
        else
            echo -e "${CYBER_YELLOW}⚠ ClamAV não instalado${NC}"
        fi
        
        echo -e "\nStrings suspeitas:"
        strings "$quarantine_file" | grep -i "malware\|virus\|hack\|exploit"
    fi
    
    echo -e "${CYBER_BLUE}╚══════════════════════════════════════════════════════════════════════╝${RESET}"
    log_quarantine "ANALYZED" "$hash"
}

# Função principal
run_quarantine() {
    setup_quarantine_env
    
    if [ $# -eq 0 ]; then
        show_quarantine_help
        return
    fi
    
    local command="$1"
    shift
    
    case "$command" in
        list)
            list_quarantine
            ;;
        isolate)
            if [ $# -eq 0 ]; then
                echo -e "${CYBER_RED}✖ Especifique o arquivo para isolar${RESET}"
                return 1
            fi
            isolate_file "$1" "$2"
            ;;
        restore)
            if [ $# -eq 0 ]; then
                echo -e "${CYBER_RED}✖ Especifique o hash do item${RESET}"
                return 1
            fi
            restore_file "$1"
            ;;
        remove)
            if [ $# -eq 0 ]; then
                echo -e "${CYBER_RED}✖ Especifique o hash do item${RESET}"
                return 1
            fi
            remove_threat "$1"
            ;;
        analyze)
            if [ $# -eq 0 ]; then
                echo -e "${CYBER_RED}✖ Especifique o hash do item${RESET}"
                return 1
            fi
            analyze_item "$1" "$2"
            ;;
        --help|-h)
            show_quarantine_help
            ;;
        *)
            echo -e "${CYBER_RED}✖ Comando inválido: $command${RESET}"
            show_quarantine_help
            return 1
            ;;
    esac
}

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_quarantine "$@"
fi