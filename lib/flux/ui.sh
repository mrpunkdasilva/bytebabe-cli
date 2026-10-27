#!/bin/bash

# Compatibilidade: a UI canônica do Flux vive em display.sh.

_flux_ui_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=display.sh
source "$_flux_ui_dir/display.sh"
unset _flux_ui_dir
