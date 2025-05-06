# No final da função perform_post_request, após processar a resposta:

# Salva a requisição no histórico
process_request_for_history "POST" "$url" "$(printf '%s\n' "${headers[@]}")" "$body" "$response_body" "$status_code"