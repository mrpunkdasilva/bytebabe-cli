#!/bin/bash

# Adaptador fino para a engine HTTP compartilhada.

_flux_executor_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../engine.sh
source "$_flux_executor_dir/../../engine.sh"
unset _flux_executor_dir

perform_post_request() {
    flux_execute_request POST "$@"
}
