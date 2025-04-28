#!/bin/bash

# Gera o script de autocompletion
generate_completion() {
    cat > "$COMPLETION_DIR/bytebabe.bash" << 'EOF'
_bytebabe_completion() {
    local cur prev words cword
    _init_completion || return

    # Comandos principais
    local commands="spring docker git devtools terminal db"

    # Subcomandos para cada comando principal
    local spring_subcmds="new template dependency profile config generator generate run build test docs docker clean"
    local docker_subcmds="containers images volumes networks compose stats"
    local git_subcmds="init clone status commit push pull"
    local devtools_subcmds="terminal database api browser"
    local terminal_subcmds="zsh ohmyzsh spaceship plugins all"
    local db_subcmds="setup start backup restore"

    # Se estamos no primeiro argumento
    if [[ $cword -eq 1 ]]; then
        COMPREPLY=($(compgen -W "$commands" -- "$cur"))
        return
    fi

    # Autocompletion baseado no comando principal
    case "${words[1]}" in
        spring)
            COMPREPLY=($(compgen -W "$spring_subcmds" -- "$cur"))
            ;;
        docker)
            COMPREPLY=($(compgen -W "$docker_subcmds" -- "$cur"))
            ;;
        git)
            COMPREPLY=($(compgen -W "$git_subcmds" -- "$cur"))
            ;;
        devtools)
            COMPREPLY=($(compgen -W "$devtools_subcmds" -- "$cur"))
            ;;
        terminal)
            COMPREPLY=($(compgen -W "$terminal_subcmds" -- "$cur"))
            ;;
        db)
            COMPREPLY=($(compgen -W "$db_subcmds" -- "$cur"))
            ;;
    esac
}

complete -F _bytebabe_completion bytebabe
EOF

    # Instala o script de autocompletion
    if [[ -f ~/.bashrc ]]; then
        echo "source $COMPLETION_DIR/bytebabe.bash" >> ~/.bashrc
    fi
    if [[ -f ~/.zshrc ]]; then
        echo "source $COMPLETION_DIR/bytebabe.bash" >> ~/.zshrc
    fi
}