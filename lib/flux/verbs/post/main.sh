#!/bin/bash

# Entry point do verbo POST do Flux.

_flux_main_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=executor.sh
source "$_flux_main_dir/executor.sh"
# shellcheck source=parser.sh
source "$_flux_main_dir/parser.sh"
# shellcheck source=validator.sh
source "$_flux_main_dir/validator.sh"
# shellcheck source=help.sh
source "$_flux_main_dir/help.sh"
unset _flux_main_dir

execute_post() {
    flux_execute_request POST "$@"
}
