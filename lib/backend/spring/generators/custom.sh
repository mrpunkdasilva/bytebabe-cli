#!/bin/bash

CUSTOM_GENERATORS_DIR="$HOME/.bytebabe/generators/spring"

# Inicializa diretório de geradores customizados
init_custom_generators() {
    if [[ ! -d "$CUSTOM_GENERATORS_DIR" ]]; then
        mkdir -p "$CUSTOM_GENERATORS_DIR"
        echo -e "${CYBER_GREEN}✔ Diretório de geradores customizados criado em: ${CYBER_CYAN}$CUSTOM_GENERATORS_DIR${RESET}"
    fi
}

# Lista todos os geradores customizados
list_custom_generators() {
    init_custom_generators
    
    echo -e "${CYBER_BLUE}Geradores customizados:${RESET}"
    
    if [[ ! -d "$CUSTOM_GENERATORS_DIR" || -z "$(ls -A "$CUSTOM_GENERATORS_DIR" 2>/dev/null)" ]]; then
        echo -e "  ${CYBER_YELLOW}Nenhum gerador customizado encontrado${RESET}"
        return 0
    fi
    
    for generator in "$CUSTOM_GENERATORS_DIR"/*.sh; do
        if [[ -f "$generator" ]]; then
            local name=$(basename "$generator" .sh)
            local description=$(grep "# Description:" "$generator" | cut -d':' -f2- | xargs)
            local author=$(grep "# Author:" "$generator" | cut -d':' -f2- | xargs)
            local version=$(grep "# Version:" "$generator" | cut -d':' -f2- | xargs)
            echo -e "  ${CYBER_GREEN}${name}${RESET} - ${description:-Sem descrição}"
            [[ -n "$author" ]] && echo -e "    Author: $author"
            [[ -n "$version" ]] && echo -e "    Version: $version"
        fi
    done
}

# Adiciona um novo gerador customizado
add_custom_generator() {
    init_custom_generators
    
    local name=$1
    
    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome do gerador é obrigatório${RESET}"
        return 1
    fi
    
    local generator_path="$CUSTOM_GENERATORS_DIR/${name}.sh"
    
    if [[ -f "$generator_path" ]]; then
        echo -e "${CYBER_RED}✘ Gerador '$name' já existe${RESET}"
        return 1
    fi
    
    # Template melhorado do gerador
    cat > "$generator_path" << 'EOF'
#!/bin/bash

# Description: Descrição do seu gerador aqui
# Author: Seu nome
# Version: 1.0.0

generate_NAME() {
    local name=""
    local package=""
    
    # Parse argumentos nomeados
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -n|--name)
                name="$2"
                shift 2
                ;;
            -p|--package)
                package="$2"
                shift 2
                ;;
            *)
                # Se não é um argumento nomeado, assume que é o nome
                if [[ -z "$name" && ! "$1" =~ ^- ]]; then
                    name="$1"
                    shift
                else
                    echo -e "${CYBER_RED}✘ Opção inválida: $1${RESET}"
                    return 1
                fi
                ;;
        esac
    done
    
    # Validações
    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome é obrigatório${RESET}"
        return 1
    fi
    
    # Se package não foi fornecido, usa o padrão da configuração
    if [[ -z "$package" ]]; then
        package=$(get_package "default")
        if [[ -z "$package" ]]; then
            echo -e "${CYBER_RED}✘ Package é obrigatório. Configure um package padrão ou forneça via -p${RESET}"
            return 1
        fi
    fi
    
    echo -e "${CYBER_BLUE}▶ Gerando componente personalizado: ${name}...${RESET}"
    
    # Cria estrutura de diretórios do package
    local package_dir="src/main/java/${package//./\/}"
    mkdir -p "$package_dir"
    
    # Caminho completo do arquivo
    local file_path="$package_dir/$name.java"
    
    # Gera o código
    cat > "$file_path" << JAVA_EOF
package $package;

public class $name {
    // TODO: Implemente sua lógica aqui
}
JAVA_EOF
    
    echo -e "${CYBER_GREEN}✔ Componente gerado em: ${CYBER_CYAN}$file_path${RESET}"
}
EOF

    # Substitui NAME pelo nome real do gerador
    sed -i "s/generate_NAME/generate_$name/g" "$generator_path"
    
    chmod +x "$generator_path"
    echo -e "${CYBER_GREEN}✔ Gerador '$name' criado em: ${CYBER_CYAN}$generator_path${RESET}"
    echo -e "${CYBER_YELLOW}ℹ️  Edite o arquivo para implementar a lógica do seu gerador${RESET}"
    
    # Recarrega os geradores
    load_custom_generators
}

# Remove um gerador customizado
remove_custom_generator() {
    local name=$1
    
    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome do gerador é obrigatório${RESET}"
        return 1
    fi
    
    local generator_path="$CUSTOM_GENERATORS_DIR/${name}.sh"
    
    if [[ ! -f "$generator_path" ]]; then
        echo -e "${CYBER_RED}✘ Gerador '$name' não encontrado${RESET}"
        return 1
    fi
    
    rm "$generator_path"
    echo -e "${CYBER_GREEN}✔ Gerador '$name' removido${RESET}"
}

# Edita um gerador customizado
edit_custom_generator() {
    local name=$1
    
    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome do gerador é obrigatório${RESET}"
        return 1
    fi
    
    local generator_path="$CUSTOM_GENERATORS_DIR/${name}.sh"
    
    if [[ ! -f "$generator_path" ]]; then
        echo -e "${CYBER_RED}✘ Gerador '$name' não encontrado${RESET}"
        return 1
    fi
    
    ${EDITOR:-vim} "$generator_path"
    
    # Recarrega os geradores após a edição
    load_custom_generators
}

# Carrega todos os geradores customizados
load_custom_generators() {
    init_custom_generators
    
    if [[ -d "$CUSTOM_GENERATORS_DIR" ]]; then
        for generator in "$CUSTOM_GENERATORS_DIR"/*.sh; do
            if [[ -f "$generator" ]]; then
                source "$generator"
            fi
        done
    fi
}