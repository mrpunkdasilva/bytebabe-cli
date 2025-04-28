#!/bin/bash

# Diretório de traduções
I18N_DIR="$HOME/.config/bytebabe/i18n"
CURRENT_LANG="${LANG:-en_US}"

# Carrega as traduções
declare -A TRANSLATIONS

load_translations() {
    local lang_file="$I18N_DIR/${CURRENT_LANG}.sh"
    
    if [[ -f "$lang_file" ]]; then
        source "$lang_file"
    else
        # Fallback para inglês
        source "$I18N_DIR/en_US.sh"
    fi
}

# Função de tradução
translate() {
    local key="$1"
    echo "${TRANSLATIONS[$key]:-$key}"
}

# Alias mais curto para tradução
t() {
    translate "$1"
}

# Inicializa o sistema de i18n
init_i18n() {
    mkdir -p "$I18N_DIR"
    
    # Cria arquivo de tradução em inglês se não existir
    if [[ ! -f "$I18N_DIR/en_US.sh" ]]; then
        create_default_translations
    fi
    
    load_translations
}

# Cria traduções padrão
create_default_translations() {
    cat > "$I18N_DIR/en_US.sh" << 'EOF'
#!/bin/bash

TRANSLATIONS=(
    ["welcome"]="Welcome to ByteBabe CLI"
    ["error.not_found"]="Command not found"
    ["success"]="Operation completed successfully"
    ["warning"]="Warning"
    ["confirm"]="Do you want to continue?"
)
EOF

    # Cria arquivo de tradução em português
    cat > "$I18N_DIR/pt_BR.sh" << 'EOF'
#!/bin/bash

TRANSLATIONS=(
    ["welcome"]="Bem-vindo ao ByteBabe CLI"
    ["error.not_found"]="Comando não encontrado"
    ["success"]="Operação concluída com sucesso"
    ["warning"]="Atenção"
    ["confirm"]="Deseja continuar?"
)
EOF
}