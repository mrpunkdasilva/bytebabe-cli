#!/bin/bash

generate_mapper() {
    local name=""
    local package=""
    local entity_name=""
    local dto_name=""

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
            -d|--dto)
                dto_name="$2"
                shift 2
                ;;
            *)
                echo -e "${CYBER_RED}✘ Opção inválida: $1${RESET}"
                show_generator_help "mapper"
                return 1
                ;;
        esac
    done

    # Validações
    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome do mapper é obrigatório${RESET}"
        show_generator_help "mapper"
        return 1
    fi

    if [[ -z "$package" ]]; then
        package=$(get_package "mapper")
        if [[ -z "$package" ]]; then
            echo -e "${CYBER_RED}✘ Package é obrigatório. Configure um package padrão ou forneça via -p${RESET}"
            return 1
        fi
    fi

    # Deriva entity/DTO a partir do nome quando não informados
    if [[ -z "$entity_name" ]]; then
        entity_name=$(echo "$name" | sed 's/Mapper$//')
    fi

    if [[ -z "$dto_name" ]]; then
        dto_name="${entity_name}DTO"
    fi

    if [[ ! $name =~ Mapper$ ]]; then
        name="${name}Mapper"
    fi

    local entity_package
    local dto_package
    entity_package=$(get_package "entity")
    dto_package=$(get_package "dto")
    [[ -z "$entity_package" ]] && entity_package="$package"
    [[ -z "$dto_package" ]] && dto_package="$package"

    echo -e "${CYBER_BLUE}▶ Gerando mapper: ${name}...${RESET}"

    local package_dir="src/main/java/${package//./\/}"
    mkdir -p "$package_dir"

    local file_path="$package_dir/$name.java"

    {
        echo "package $package;"
        echo
        echo "import org.mapstruct.Mapper;"
        echo "import org.mapstruct.MappingTarget;"
        echo "import $entity_package.$entity_name;"
        echo "import $dto_package.$dto_name;"
        echo
        echo "@Mapper(componentModel = \"spring\")"
        echo "public interface $name {"
        echo
        echo "    $dto_name toDto($entity_name entity);"
        echo
        echo "    $entity_name toEntity($dto_name dto);"
        echo
        echo "    void updateEntity($dto_name dto, @MappingTarget $entity_name entity);"
        echo "}"
    } > "$file_path"

    echo -e "${CYBER_GREEN}✔ Mapper gerado em: ${CYBER_CYAN}$file_path${RESET}"
}
