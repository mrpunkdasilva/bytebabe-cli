#!/bin/bash

source "$BASE_DIR/lib/flux/verbs/delete/executor.sh"
source "$BASE_DIR/lib/flux/verbs/delete/parser.sh"
source "$BASE_DIR/lib/flux/verbs/delete/validator.sh"
source "$BASE_DIR/lib/flux/verbs/delete/help.sh"

execute_delete() {
    local url="$1"
    shift
    
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_delete_help
        return 0
    fi

    if ! validate_url "$url"; then
        return 1
    fi

    local params
    if ! params=$(parse_delete_args "$@"); then
        return 1
    fi

    perform_delete_request "$url" "$params"
}