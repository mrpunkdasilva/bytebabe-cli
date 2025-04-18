#!/bin/bash

source "$BASE_DIR/lib/flux/verbs/put/executor.sh"
source "$BASE_DIR/lib/flux/verbs/put/parser.sh"
source "$BASE_DIR/lib/flux/verbs/put/validator.sh"
source "$BASE_DIR/lib/flux/verbs/put/help.sh"

execute_put() {
    local url="$1"
    shift
    
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_put_help
        return 0
    fi

    if ! validate_url "$url"; then
        return 1
    fi

    local params
    if ! params=$(parse_put_args "$@"); then
        return 1
    fi

    perform_put_request "$url" "$params"
}