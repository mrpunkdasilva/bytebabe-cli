#!/bin/bash

# Adaptador da validação compartilhada para DELETE.

_flux_validator_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../validation.sh
source "$_flux_validator_dir/../../validation.sh"
unset _flux_validator_dir

validate_url() {
    flux_validate_url "$1" show_delete_help
}

validate_delete_args() {
    return 0
}
