#!/bin/bash

perform_delete_request() {
    local url="$1"
    local params="$2"
    local loading_style="${3:-default}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Header estilizado
    echo -e "\n${CYBER_BLUE}╔════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║${RESET} ${CYBER_RED}DELETE${RESET} Request ${CYBER_YELLOW}@${timestamp}${RESET}"
    echo -e "${CYBER_BLUE}╚════════════════════════════════════════════════════════════════════════╝${RESET}"
    
    # URL com parsing dos componentes
    local protocol=$(echo "$url" | grep -oP '^https?')
    local host=$(echo "$url" | grep -oP '://\K[^/]+')
    local path=$(echo "$url" | grep -oP '://[^/]+\K.*')
    
    echo -e "${CYBER_YELLOW}URL Details${RESET}"
    echo -e "  ${CYBER_BLUE}Protocol:${RESET} $protocol"
    echo -e "  ${CYBER_BLUE}Host:${RESET}     $host"
    echo -e "  ${CYBER_BLUE}Path:${RESET}     $path"
    
    # Headers da requisição
    local curl_cmd="curl -s -i -w '\n%{http_code}\n%{time_total}\n%{size_download}\n%{speed_download}' -X DELETE"
    curl_cmd+=" -H 'User-Agent: ByteBabe-Flux/2.0'"
    curl_cmd+=" -H 'Accept: application/json'"
    curl_cmd+=" -H 'X-Request-ID: $(uuidgen)'"
    
    # Adiciona headers customizados
    if [[ -n "$params" ]]; then
        echo -e "\n${CYBER_YELLOW}Custom Headers${RESET}"
        echo "$params" | tr " " "\n" | grep -E '^-H' | cut -d" " -f2- | sed 's/^/  /'
        curl_cmd+=" $params"
    fi
    
    curl_cmd+=" '$url'"
    
    # Spinner customizado com mensagem
    echo -ne "\n${CYBER_PINK}⚡ Initiating DELETE request...${RESET}"
    eval "$curl_cmd" > /tmp/flux_response.$$ &
    
    local pid=$!
    local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local i=0
    while kill -0 $pid 2>/dev/null; do
        printf "\r${CYBER_PINK}${frames[i]} Processing request...${RESET}"
        i=$(( (i+1) % ${#frames[@]} ))
        sleep .1
    done
    printf "\r${CYBER_GREEN}✔ Request completed!      ${RESET}\n"
    
    # Processa a resposta
    local response_headers=$(sed '/^\r$/q' /tmp/flux_response.$$)
    local response_body=$(sed '1,/^\r$/d' /tmp/flux_response.$$ | head -n -4)
    local status_code=$(tail -n 4 /tmp/flux_response.$$ | head -n 1)
    local duration=$(tail -n 3 /tmp/flux_response.$$ | head -n 1 | awk '{printf "%.0f", $1 * 1000}')
    local size=$(tail -n 2 /tmp/flux_response.$$ | head -n 1 | awk '{printf "%.2f", $1/1024}')
    local speed=$(tail -n 1 /tmp/flux_response.$$ | awk '{printf "%.2f", $1/1024}')
    
    rm -f /tmp/flux_response.$$
    
    # Status com emoji
    local status_icon status_color
    if [[ $status_code -ge 200 && $status_code -lt 300 ]]; then
        status_color="${CYBER_GREEN}"
        status_icon="✔"
    elif [[ $status_code -ge 400 && $status_code -lt 500 ]]; then
        status_color="${CYBER_YELLOW}"
        status_icon="⚠"
    else
        status_color="${CYBER_RED}"
        status_icon="✖"
    fi
    
    # Resposta estilizada
    echo -e "\n${CYBER_BLUE}╔════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║${RESET} ${CYBER_PINK}Response Details${RESET}"
    echo -e "${CYBER_BLUE}╚════════════════════════════════════════════════════════════════════════╝${RESET}"
    
    echo -e "\n${CYBER_YELLOW}Metrics${RESET}"
    echo -e "  ${CYBER_BLUE}Status:${RESET}  ${status_color}${status_icon} ${status_code}${RESET}"
    echo -e "  ${CYBER_BLUE}Time:${RESET}    ${duration}ms"
    echo -e "  ${CYBER_BLUE}Size:${RESET}    ${size}KB"
    echo -e "  ${CYBER_BLUE}Speed:${RESET}   ${speed}KB/s"
    
    echo -e "\n${CYBER_YELLOW}Response Headers${RESET}"
    echo "$response_headers" | grep -iE '^(content-type|content-length|location|x-|authorization|cache-|etag)' | 
        while IFS= read -r line; do
            local header_name=$(echo "$line" | cut -d: -f1)
            local header_value=$(echo "$line" | cut -d: -f2-)
            echo -e "  ${CYBER_BLUE}${header_name}:${RESET}${header_value}"
        done
    
    if [[ -n "$response_body" ]]; then
        echo -e "\n${CYBER_YELLOW}Response Body${RESET}"
        if [[ "$response_body" =~ ^\{.*\}$ || "$response_body" =~ ^\[.*\]$ ]]; then
            echo "$response_body" | jq -C '.' 2>/dev/null || echo "$response_body"
        else
            echo "$response_body"
        fi
    fi
    
    # Footer com timestamp
    echo -e "\n${CYBER_BLUE}╔════════════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYBER_BLUE}║${RESET} ${CYBER_YELLOW}Request completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
    echo -e "${CYBER_BLUE}╚════════════════════════════════════════════════════════════════════════╝${RESET}"
    
    return $(( status_code >= 200 && status_code < 300 ? 0 : 1 ))
}