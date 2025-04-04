#!/bin/bash

# Carrega as configurações
CONFIG_FILE="$(dirname "${BASH_SOURCE[0]}")/config.json"
load_config() {
    if ! command -v jq &> /dev/null; then
        echo -e "${CYBER_RED}Error: jq is required for Neo mode${NC}"
        exit 1
    fi
    
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo -e "${CYBER_RED}Error: Neo configuration file not found${NC}"
        exit 1
    fi
}

# Pega uma mensagem aleatória de uma categoria
get_random_message() {
    local category="$1"
    jq -r ".messages.$category[$(( RANDOM % $(jq ".messages.$category | length" "$CONFIG_FILE") ))]" "$CONFIG_FILE"
}

# Efeito de chuva matrix aprimorado
matrix_rain() {
    local speed=$(jq -r '.effects.rain.speed' "$CONFIG_FILE")
    local chars=$(jq -r '.effects.rain.chars' "$CONFIG_FILE")
    local density=$(jq -r '.effects.rain.density' "$CONFIG_FILE")
    local columns=$(tput cols)
    local lines=$(tput lines)
    
    # Limpa a tela e esconde o cursor
    clear
    tput civis

    # Restaura o cursor quando o script for interrompido
    trap 'tput cnorm; exit 0' INT TERM

    # Arrays para controlar as posições das gotas
    declare -a drops
    declare -a speeds
    for ((i=0; i<columns; i++)); do
        drops[i]=-1
        speeds[i]=$(( (RANDOM % 3) + 1 ))
    done

    while true; do
        # Move o cursor para o topo
        tput cup 0 0
        
        # Atualiza cada coluna
        for ((x=0; x<columns; x++)); do
            for ((y=0; y<lines; y++)); do
                if [ "$y" -eq "${drops[$x]}" ]; then
                    echo -en "${CYBER_GREEN}${BOLD}$(tr -dc "$chars" < /dev/urandom | head -c1)${NC}"
                elif [ "$y" -lt "${drops[$x]}" ] && [ "$y" -gt "$(( ${drops[$x]} - 10 ))" ]; then
                    intensity=$(( 7 - (${drops[$x]} - y) ))
                    if [ $intensity -lt 2 ]; then intensity=2; fi
                    echo -en "\033[38;5;${intensity}2m$(tr -dc "$chars" < /dev/urandom | head -c1)${NC}"
                else
                    echo -n " "
                fi
            done
            
            # Atualiza a posição da gota
            drops[x]=$(( ${drops[$x]} + ${speeds[$x]} ))
            if [ "${drops[$x]}" -gt "$lines" ]; then
                drops[x]=$(( (RANDOM % 20) - 20 ))
                speeds[x]=$(( (RANDOM % 3) + 1 ))
            fi
        done
        
        sleep "$speed"
    done
}

# Efeito glitch
glitch_effect() {
    local text="$1"
    local glitch_chars=$(jq -r '.effects.glitch.chars' "$CONFIG_FILE")
    local duration=$(jq -r '.effects.glitch.duration' "$CONFIG_FILE")
    local intensity=$(jq -r '.effects.glitch.intensity' "$CONFIG_FILE")
    
    for ((i=0; i<intensity; i++)); do
        local glitched=${text}
        for ((j=0; j<5; j++)); do
            local pos=$((RANDOM % ${#text}))
            local char=${glitch_chars:$((RANDOM % ${#glitch_chars})):1}
            glitched=${glitched:0:$pos}${char}${glitched:$((pos+1))}
        done
        echo -en "\r${CYBER_RED}${glitched}${NC}"
        sleep "$duration"
    done
    echo -e "\r${CYBER_GREEN}${text}${NC}"
}

# Mostra ASCII art aleatória
show_random_ascii() {
    local art=$(get_random_message "ascii_art")
    echo -e "${CYBER_GREEN}${art}${NC}"
}

# Consulta o Oráculo
consult_oracle() {
    echo -e "${CYBER_BLUE}The Oracle says:${NC}"
    sleep 1
    glitch_effect "$(get_random_message "quotes")"
}

# Show help for Neo mode
show_neo_help() {
    echo -e "${CYBER_GREEN}WELCOME TO THE DESERT OF THE REAL${NC}"
    echo
    echo -e "${CYBER_BLUE}USAGE:${NC}"
    echo -e "  prime neo ${CYBER_YELLOW}[command]${NC}"
    echo
    echo -e "${CYBER_BLUE}COMMANDS:${NC}"
    
    jq -r '.commands | to_entries[] | "  \(.key): \(.value.description)"' "$CONFIG_FILE" | \
    while read -r line; do
        echo -e "${CYBER_GREEN}${line}${NC}"
    done
    
    echo
    echo -e "${CYBER_BLUE}OPTIONS:${NC}"
    echo -e "  ${CYBER_YELLOW}-h, --help${NC}   Show this help message"
    echo
    echo -e "${CYBER_RED}$(get_random_message "quotes")${NC}"
}

# Main Neo mode function
run_neo_mode() {
    load_config
    
    case "$1" in
        "rain"|"digital-rain"|"code-rain")
            clear
            glitch_effect "$(get_random_message "wake_up")"
            sleep 1
            matrix_rain
            ;;
        "truth"|"reveal"|"enlighten")
            clear
            show_random_ascii
            sleep 1
            glitch_effect "$(get_random_message "truth")"
            ;;
        "train"|"practice"|"learn")
            clear
            echo -e "${CYBER_BLUE}$(get_random_message "training")${NC}"
            sleep 1
            glitch_effect "$(get_random_message "training")"
            ;;
        "glitch"|"bug"|"error")
            clear
            glitch_effect "$(get_random_message "errors")"
            ;;
        "oracle"|"predict"|"fortune")
            clear
            consult_oracle
            ;;
        "--help"|"-h")
            show_neo_help
            ;;
        *)
            echo -e "${CYBER_GREEN}$(get_random_message "wake_up")${NC}"
            sleep 1
            show_neo_help
            ;;
    esac
}

# If executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_neo_mode "$@"
fi
