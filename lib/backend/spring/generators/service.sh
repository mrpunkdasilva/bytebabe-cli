#!/bin/bash

generate_service() {
    local name=""
    local package=""

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
            *)
                echo -e "${CYBER_RED}✘ Opção inválida: $1${RESET}"
                show_spring_generate_help
                return 1
                ;;
        esac
    done

    # Validações
    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✘ Nome do service é obrigatório${RESET}"
        show_spring_generate_help
        return 1
    fi

    # Se package não foi fornecido, usa o padrão da configuração
    if [[ -z "$package" ]]; then
        package=$(get_package "service")
        if [[ -z "$package" ]]; then
            echo -e "${CYBER_RED}✘ Package é obrigatório. Configure um package padrão ou forneça via -p${RESET}"
            return 1
        fi
    fi

    # Adiciona sufixo Service se não existir
    if [[ ! $name =~ Service$ ]]; then
        name="${name}Service"
    fi

    echo -e "${CYBER_BLUE}▶ Gerando service: ${name}...${RESET}"

    # Cria estrutura de diretórios do package
    local package_dir="src/main/java/${package//./\/}"
    mkdir -p "$package_dir"

    # Caminho completo do arquivo
    local file_path="$package_dir/$name.java"

    # Gera o código do service
    {
        echo "package $package;"
        echo
        echo "import org.springframework.stereotype.Service;"
        echo "import org.springframework.transaction.annotation.Transactional;"
        echo "import java.util.List;"
        echo "import java.util.Optional;"
        echo
        echo "@Service"
        echo "@Transactional"
        echo "public class $name {"
        echo
        echo "    public List<Object> findAll() {"
        echo "        // TODO: Implement findAll method"
        echo "        return null;"
        echo "    }"
        echo
        echo "    public Optional<Object> findById(Long id) {"
        echo "        // TODO: Implement findById method"
        echo "        return Optional.empty();"
        echo "    }"
        echo
        echo "    public Object save(Object entity) {"
        echo "        // TODO: Implement save method"
        echo "        return null;"
        echo "    }"
        echo
        echo "    public void delete(Long id) {"
        echo "        // TODO: Implement delete method"
        echo "    }"
        echo "}"
    } > "$file_path"

    echo -e "${CYBER_GREEN}✔ Service gerado em: ${CYBER_CYAN}$file_path${RESET}"
}