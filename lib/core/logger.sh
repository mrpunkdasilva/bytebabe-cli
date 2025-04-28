#!/bin/bash

# Configurações de logging
LOG_DIR="$HOME/.config/bytebabe/logs"
LOG_FILE="$LOG_DIR/bytebabe.log"
TELEMETRY_FILE="$LOG_DIR/telemetry.log"

# Níveis de log
declare -A LOG_LEVELS=(
    ["DEBUG"]=0
    ["INFO"]=1
    ["WARN"]=2
    ["ERROR"]=3
)

# Inicializa o sistema de logging
init_logger() {
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE"
    touch "$TELEMETRY_FILE"
}

# Função principal de logging
log() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp][$level] $message" >> "$LOG_FILE"
    
    # Output colorido no terminal se DEBUG estiver ativo
    if [[ "${LOG_LEVELS[$level]}" -ge "${LOG_LEVELS[${LOG_LEVEL:-INFO}]}" ]]; then
        case "$level" in
            "DEBUG") echo -e "${CYBER_BLUE}[$timestamp][$level] $message${RESET}" ;;
            "INFO")  echo -e "${CYBER_GREEN}[$timestamp][$level] $message${RESET}" ;;
            "WARN")  echo -e "${CYBER_YELLOW}[$timestamp][$level] $message${RESET}" ;;
            "ERROR") echo -e "${CYBER_RED}[$timestamp][$level] $message${RESET}" ;;
        esac
    fi
}

# Função para telemetria
track_event() {
    local event="$1"
    local data="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp][$event] $data" >> "$TELEMETRY_FILE"
}

# Funções helper
debug() { log "DEBUG" "$1"; }
info() { log "INFO" "$1"; }
warn() { log "WARN" "$1"; }
error() { log "ERROR" "$1"; }