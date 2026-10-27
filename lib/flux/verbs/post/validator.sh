#!/bin/bash

# Adaptador da validação compartilhada para POST.

_flux_validator_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../validation.sh
source "$_flux_validator_dir/../../validation.sh"
unset _flux_validator_dir

validate_url() {
    flux_validate_url "$1" show_post_help
}
