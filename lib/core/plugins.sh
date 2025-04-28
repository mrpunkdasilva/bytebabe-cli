#!/bin/bash

# Diretório base para plugins
PLUGINS_DIR="$HOME/.config/bytebabe/plugins"
COMPLETION_DIR="$HOME/.config/bytebabe/completion"

# Inicializa a estrutura de diretórios
init_plugin_system() {
    mkdir -p "$PLUGINS_DIR"
    mkdir -p "$COMPLETION_DIR"
}

# Carrega todos os plugins instalados
load_plugins() {
    if [[ -d "$PLUGINS_DIR" ]]; then
        for plugin in "$PLUGINS_DIR"/*.sh; do
            if [[ -f "$plugin" ]]; then
                source "$plugin"
            fi
        done
    fi
}

# Registra um novo plugin
register_plugin() {
    local plugin_name="$1"
    local plugin_path="$2"

    if [[ -f "$plugin_path" ]]; then
        cp "$plugin_path" "$PLUGINS_DIR/${plugin_name}.sh"
        echo -e "${CYBER_GREEN}✔ Plugin $plugin_name instalado com sucesso${RESET}"
    else
        echo -e "${CYBER_RED}✘ Arquivo do plugin não encontrado${RESET}"
        return 1
    fi
}

# Remove um plugin
remove_plugin() {
    local plugin_name="$1"
    local plugin_file="$PLUGINS_DIR/${plugin_name}.sh"

    if [[ -f "$plugin_file" ]]; then
        rm "$plugin_file"
        echo -e "${CYBER_GREEN}✔ Plugin $plugin_name removido com sucesso${RESET}"
    else
        echo -e "${CYBER_RED}✘ Plugin não encontrado${RESET}"
        return 1
    fi
}