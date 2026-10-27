#!/bin/bash

# Menu interativo canônico do ByteBabe.
# Este arquivo apenas declara funções; carregá-lo não abre menu nem lê entrada.

if [[ -n "${_BYTEBABE_CORE_MENU_LOADED:-}" ]]; then
    return 0
fi
_BYTEBABE_CORE_MENU_LOADED=1

if [[ -z "${CYBER_BLUE:-}" ]]; then
    if [[ "${BASH_SOURCE[0]}" == */* ]]; then
        _bytebabe_menu_dir="${BASH_SOURCE[0]%/*}"
    else
        _bytebabe_menu_dir="."
    fi
    _bytebabe_menu_dir="$(cd -P -- "$_bytebabe_menu_dir" && pwd)"
    source "$_bytebabe_menu_dir/colors.sh"
    unset _bytebabe_menu_dir
fi

# choose_from_menu <prompt> <outvar> <opções...>
# Retorna 0 em seleção e 1 em cancelamento, lista vazia ou fim de entrada.
choose_from_menu() {
    local prompt="${1:-}"
    local outvar="${2:-}"
    local options=("${@:3}")
    local cur=0
    local count=${#options[@]}
    local index=0
    local key

    if [[ -z "$outvar" ]]; then
        return 1
    fi

    if [[ $count -eq 0 ]]; then
        echo -e "${CYBER_RED}Nenhuma opção disponível${RESET}"
        return 1
    fi

    echo -e "${CYBER_BOLD}${CYBER_PURPLE}${prompt}${RESET}"

    while true; do
        index=0
        for o in "${options[@]}"; do
            if [[ "$index" -eq "$cur" ]]; then
                echo -e "${CYBER_GREEN} > ${CYBER_BLUE}${CYBER_BOLD}${o}${RESET}"
            else
                echo -e "   ${CYBER_YELLOW}${o}${RESET}"
            fi
            index=$((index + 1))
        done

        if ! IFS= read -rsn1 key; then
            return 1
        fi

        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key || key=""
        fi

        case "$key" in
            '[A')
                cur=$((cur - 1))
                [[ "$cur" -lt 0 ]] && cur=0
                ;;
            '[B')
                cur=$((cur + 1))
                [[ "$cur" -ge "$count" ]] && cur=$((count - 1))
                ;;
            '')
                break
                ;;
            [1-9])
                if [[ "$key" -gt 0 && "$key" -le "$count" ]]; then
                    cur=$((key - 1))
                    break
                fi
                ;;
            q|Q)
                return 1
                ;;
        esac

        printf '\033[%dA' "$count"
    done

    printf -v "$outvar" '%s' "${options[$cur]}"
    return 0
}
