#!/bin/bash

perform_delete_request() {
    local url="$1"
    local params="$2"
    local loading_style="${3:-default}"
    
    local curl_cmd="curl -s -i -w '\n%{http_code}\n%{time_total}' -X DELETE"
    curl_cmd+=" -H 'User-Agent: Flux-HTTP-Client/1.0'"
    curl_cmd+=" -H 'Accept: application/json'"
    
    if [[ -n "$params" ]]; then
        curl_cmd+=" $params"
    fi
    
    curl_cmd+=" '$url'"
    
    eval "$curl_cmd" > /tmp/flux_response.$$
    
    local response_headers=$(sed '/^\r$/q' /tmp/flux_response.$$)
    local response_body=$(sed '1,/^\r$/d' /tmp/flux_response.$$ | head -n -2)
    local status_code=$(tail -n 2 /tmp/flux_response.$$ | head -n 1)
    local duration=$(tail -n 1 /tmp/flux_response.$$ | awk '{printf "%.0f", $1 * 1000}')
    
    rm -f /tmp/flux_response.$$
    
    echo -e "\n${CYBER_BLUE}Response:${RESET}"
    echo -e "${CYBER_YELLOW}Status:${RESET} $status_code"
    echo -e "${CYBER_YELLOW}Time:${RESET} ${duration}ms"
    echo -e "${CYBER_YELLOW}Headers:${RESET}"
    echo "$response_headers" | grep -v "^$" | sed 's/^/  /'
    
    if [[ -n "$response_body" ]]; then
        echo -e "${CYBER_YELLOW}Body:${RESET}"
        echo "$response_body" | jq '.' 2>/dev/null || echo "$response_body"
    fi
}