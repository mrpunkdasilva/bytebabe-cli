#!/bin/bash

source "$BASE_DIR/lib/flux/verbs/post/executor.sh"
source "$BASE_DIR/lib/flux/verbs/post/parser.sh"
source "$BASE_DIR/lib/flux/verbs/post/validator.sh"
source "$BASE_DIR/lib/flux/verbs/post/help.sh"

execute_post() {
    local url="$1"
    shift
    
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_post_help
        return 0
    fi

    if ! validate_url "$url"; then
        return 1
    fi

    local params
    if ! params=$(parse_post_args "$@"); then
        return 1
    fi

    perform_post_request "$url" "$params"
}