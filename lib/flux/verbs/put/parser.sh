#!/bin/bash

# Adaptador do parser compartilhado para PUT.

_flux_parser_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../args.sh
source "$_flux_parser_dir/../../args.sh"
unset _flux_parser_dir

parse_put_args() {
    flux_parse_request_args PUT "$@"
}
