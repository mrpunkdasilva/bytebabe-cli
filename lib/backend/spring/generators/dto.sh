#!/bin/bash

generate_dto() {
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
        echo -e "${CYBER_RED}✘ Nome do DTO é obrigatório${RESET}"
        show_spring_generate_help
        return 1
    fi

    # Se package não foi fornecido, usa o padrão da configuração
    if [[ -z "$package" ]]; then
        package=$(get_package "dto")
        if [[ -z "$package" ]]; then
            echo -e "${CYBER_RED}✘ Package é obrigatório. Configure um package padrão ou forneça via -p${RESET}"
            return 1
        fi
    fi

    # Se entity_name não foi fornecido, deriva do nome do DTO
    if [[ -z "$entity_name" ]]; then
        entity_name=$(echo "$name" | sed 's/DTO$//')
    fi

    # Adiciona sufixo DTO se não existir
    if [[ ! $name =~ DTO$ ]]; then
        name="${name}DTO"
    fi

    echo -e "${CYBER_BLUE}▶ Gerando DTO: ${name}...${RESET}"

    # Cria estrutura de diretórios do package
    local package_dir="src/main/java/${package//./\/}"
    mkdir -p "$package_dir"

    # Caminho completo do arquivo
    local file_path="$package_dir/$name.java"

    # Gera o código do DTO
    {
        echo "package $package;"
        echo
        echo "import lombok.Data;"
        echo "import java.io.Serializable;"
        echo
        echo "@Data"
        echo "public class $name implements Serializable {"
        echo
        echo "    private Long id;"
        echo
        echo "    // TODO: Adicione seus campos aqui"
        echo
        echo "    // Construtor vazio"
        echo "    public $name() {}"
        echo
        echo "    // Construtor com entity"
        echo "    public $name($entity_name entity) {"
        echo "        if (entity != null) {"
        echo "            this.id = entity.getId();"
        echo "            // TODO: Mapeie os outros campos aqui"
        echo "        }"
        echo "    }"
        echo
        echo "    // Converter para entity"
        echo "    public $entity_name toEntity() {"
        echo "        $entity_name entity = new $entity_name();"
        echo "        entity.setId(this.id);"
        echo "        // TODO: Mapeie os outros campos aqui"
        echo "        return entity;"
        echo "    }"
        echo "}"
    } > "$file_path"

    echo -e "${CYBER_GREEN}✔ DTO gerado em: ${CYBER_CYAN}$file_path${RESET}"
}