#!/bin/bash

# Shim de compatibilidade: as implementações canônicas vivem em lib/core/ui.sh.
if [[ "${BASH_SOURCE[0]}" == */* ]]; then
    _bytebabe_headers_dir="${BASH_SOURCE[0]%/*}"
else
    _bytebabe_headers_dir="."
fi
source "$(cd -P -- "$_bytebabe_headers_dir/../core" && pwd)/ui.sh"
unset _bytebabe_headers_dir
