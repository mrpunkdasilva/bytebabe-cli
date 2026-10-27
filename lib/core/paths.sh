#!/bin/bash

# Resolução de caminhos canônicos do ByteBabe.
# Este arquivo apenas declara funções; carregá-lo não produz saída nem altera
# o diretório atual.

if [[ -n "${_BYTEBABE_CORE_PATHS_LOADED:-}" ]]; then
    return 0
fi
_BYTEBABE_CORE_PATHS_LOADED=1

# Resolve a cadeia de symlinks de um caminho e imprime o caminho final.
# Retorna 1 para entrada vazia, caminho inválido ou ciclo de symlinks.
bytebabe_resolve_symlink() {
    local target="${1:-}"
    local dir link
    local count=0

    [[ -n "$target" ]] || return 1

    while [[ -L "$target" ]]; do
        count=$((count + 1))
        [[ $count -le 40 ]] || return 1

        if [[ "$target" == */* ]]; then
            dir="${target%/*}"
            [[ -n "$dir" ]] || dir="/"
        else
            dir="."
        fi

        dir="$(cd -P -- "$dir" && pwd)" || return 1
        link="$(readlink -- "$target")" || return 1

        if [[ "$link" == /* ]]; then
            target="$link"
        else
            target="$dir/$link"
        fi
    done

    if [[ "$target" == */* ]]; then
        dir="${target%/*}"
        [[ -n "$dir" ]] || dir="/"
    else
        dir="."
    fi

    dir="$(cd -P -- "$dir" && pwd)" || return 1

    if [[ "$dir" == "/" ]]; then
        printf '/%s\n' "${target##*/}"
    else
        printf '%s/%s\n' "$dir" "${target##*/}"
    fi
}

# Imprime o diretório do script informado, com symlinks resolvidos.
# Sem argumento, usa o arquivo do chamador.
bytebabe_script_dir() {
    local script="${1:-${BASH_SOURCE[1]:-$0}}"
    local resolved dir

    resolved="$(bytebabe_resolve_symlink "$script")" || return 1

    dir="${resolved%/*}"
    [[ -n "$dir" ]] || dir="/"

    printf '%s\n' "$dir"
}

# Imprime a raiz do projeto a partir de um entrypoint em bin/ (um nível acima).
# Sem argumento, usa o arquivo do chamador.
bytebabe_entrypoint_base_dir() {
    local script="${1:-${BASH_SOURCE[1]:-$0}}"
    local dir

    dir="$(bytebabe_script_dir "$script")" || return 1
    (cd -P -- "$dir/.." && pwd)
}
