#!/bin/bash

generate_repository() {
    local name=""
    local package=""
    local entity_name=""

    # Se o primeiro argumento não começa com '-', é o nome
    if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
        name="$1"
        shift
    fi

    # Parse argumentos
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
            -e|--entity)
                entity_name="$2"
                shift 2
                ;;
            *)
                echo -e "${CYBER_RED}✘ Opção inválida: $1${RESET}"
                show_spring_generate_help
                return 1
                ;;
        esac
    done

    # Validações
    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome do repository é obrigatório${RESET}"
        show_spring_generate_help
        return 1
    fi

    # Se package não foi fornecido, usa o padrão da configuração
    if [[ -z "$package" ]]; then
        package=$(get_package "repository")
        if [[ -z "$package" ]]; then
            echo -e "${CYBER_RED}✘ Package é obrigatório. Configure um package padrão ou forneça via -p${RESET}"
            return 1
        fi
    fi

    # Se entity_name não foi fornecido, deriva do nome do repository
    if [[ -z "$entity_name" ]]; then
        entity_name=$(echo "$name" | sed 's/Repository$//')
    fi

    # Adiciona sufixo Repository se não existir
    if [[ ! $name =~ Repository$ ]]; then
        name="${name}Repository"
    fi

    echo -e "${CYBER_BLUE}▶ Gerando repository: ${name}...${RESET}"

    # Cria estrutura de diretórios do package
    local package_dir="src/main/java/${package//./\/}"
    mkdir -p "$package_dir"

    # Caminho completo do arquivo
    local file_path="$package_dir/$name.java"

    # Gera o código do repository
    {
        echo "package $package;"
        echo
        echo "import org.springframework.data.jpa.repository.JpaRepository;"
        echo "import org.springframework.stereotype.Repository;"
        echo
        echo "@Repository"
        echo "public interface $name extends JpaRepository<$entity_name, Long> {"
        echo "    // Adicione métodos customizados aqui"
        echo "}"
    } > "$file_path"

    echo -e "${CYBER_GREEN}✔ Repository gerado em: ${CYBER_CYAN}$file_path${RESET}"
}