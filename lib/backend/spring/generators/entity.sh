#!/bin/bash

generate_entity() {
    local name=""
    local package=""
    local table_name=""

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
            -t|--table)
                table_name="$2"
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
        echo -e "${CYBER_RED}✘ Nome da entity é obrigatório${RESET}"
        show_spring_generate_help
        return 1
    fi

    # Se package não foi fornecido, usa o padrão da configuração
    if [[ -z "$package" ]]; then
        package=$(get_package "entity")
        if [[ -z "$package" ]]; then
            echo -e "${CYBER_RED}✘ Package é obrigatório. Configure um package padrão ou forneça via -p${RESET}"
            return 1
        fi
    fi

    # Se table_name não foi fornecido, gera baseado no nome da entity
    if [[ -z "$table_name" ]]; then
        table_name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    fi

    echo -e "${CYBER_BLUE}▶ Gerando entity: ${name}...${RESET}"

    # Cria estrutura de diretórios do package
    local package_dir="src/main/java/${package//./\/}"
    mkdir -p "$package_dir"

    # Caminho completo do arquivo
    local file_path="$package_dir/$name.java"

    # Gera o código da entity
    {
        echo "package $package;"
        echo
        echo "import jakarta.persistence.*;"
        echo "import lombok.Data;"
        echo "import java.io.Serializable;"
        echo
        echo "@Data"
        echo "@Entity"
        echo "@Table(name = \"$table_name\")"
        echo "public class $name implements Serializable {"
        echo
        echo "    @Id"
        echo "    @GeneratedValue(strategy = GenerationType.IDENTITY)"
        echo "    private Long id;"
        echo
        echo "    // TODO: Adicione seus campos aqui"
        echo "}"
    } > "$file_path"

    echo -e "${CYBER_GREEN}✔ Entity gerada em: ${CYBER_CYAN}$file_path${RESET}"
}