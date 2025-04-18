#!/bin/bash

source "$BASE_DIR/lib/flux/verbs/get/executor.sh"
source "$BASE_DIR/lib/flux/verbs/get/parser.sh"
source "$BASE_DIR/lib/flux/verbs/get/validator.sh"
source "$BASE_DIR/lib/flux/verbs/get/help.sh"

execute_get() {
    local url="$1"
    shift
    
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_get_help
        return 0
    fi

    if ! validate_url "$url"; then
        return 1
    fi

    local params
    if ! params=$(parse_get_args "$@"); then
        return 1
    fi

    perform_get_request "$url" "$params"
}