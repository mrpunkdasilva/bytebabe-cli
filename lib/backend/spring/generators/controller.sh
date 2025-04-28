#!/bin/bash

generate_controller() {
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_generator_help "controller"
        return 0
    fi

    local name=""
    local package=""
    local is_rest=true

    # Se o primeiro argumento não começa com '-', é o nome
    if [[ $# -gt 0 && ! "$1" =~ ^- ]]; then
        name="$1"
        shift
    fi
    
    # Parse argumentos
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -n|--name) name="$2"; shift ;;
            -p|--package) package="$2"; shift ;;
            --no-rest) is_rest=false ;;
            *) echo -e "${CYBER_RED}✖ Opção inválida: $1${NC}"; return 1 ;;
        esac
        shift
    done
    
    # Valida nome
    if [[ -z "$name" ]]; then
        echo -e "${CYBER_RED}✖ Nome do controller é obrigatório${NC}"
        show_generator_help "controller"
        return 1
    fi
    
    # Se package não foi fornecido, usa o padrão da configuração
    if [[ -z "$package" ]]; then
        package=$(get_package "controller")
        if [[ -z "$package" ]]; then
            echo -e "${CYBER_RED}✖ Package é obrigatório. Configure um package padrão ou forneça via -p${NC}"
            return 1
        fi
    fi

    # Adiciona sufixo Controller se não existir
    if [[ ! $name =~ Controller$ ]]; then
        name="${name}Controller"
    fi

    echo -e "${CYBER_BLUE}▶ Gerando controller: ${name}...${RESET}"

    # Cria estrutura de diretórios do package
    local package_dir="src/main/java/${package//./\/}"
    mkdir -p "$package_dir"

    # Caminho completo do arquivo
    local file_path="$package_dir/$name.java"

    # Gera o código do controller
    {
        echo "package $package;"
        echo
        echo "import org.springframework.web.bind.annotation.*;"
        if $is_rest; then
            echo "import org.springframework.http.ResponseEntity;"
            echo "import java.util.List;"
        fi
        echo
        if $is_rest; then
            echo "@RestController"
            echo "@RequestMapping(\"/api/${name,,}\")"  # nome em lowercase
        else
            echo "@Controller"
        fi
        echo "public class $name {"
        echo
        if $is_rest; then
            echo "    @GetMapping"
            echo "    public ResponseEntity<List<Object>> getAll() {"
            echo "        // TODO: Implement getAll method"
            echo "        return ResponseEntity.ok().build();"
            echo "    }"
            echo
            echo "    @GetMapping(\"/{id}\")"
            echo "    public ResponseEntity<Object> getById(@PathVariable Long id) {"
            echo "        // TODO: Implement getById method"
            echo "        return ResponseEntity.ok().build();"
            echo "    }"
            echo
            echo "    @PostMapping"
            echo "    public ResponseEntity<Object> create(@RequestBody Object request) {"
            echo "        // TODO: Implement create method"
            echo "        return ResponseEntity.ok().build();"
            echo "    }"
            echo
            echo "    @PutMapping(\"/{id}\")"
            echo "    public ResponseEntity<Object> update(@PathVariable Long id, @RequestBody Object request) {"
            echo "        // TODO: Implement update method"
            echo "        return ResponseEntity.ok().build();"
            echo "    }"
            echo
            echo "    @DeleteMapping(\"/{id}\")"
            echo "    public ResponseEntity<Void> delete(@PathVariable Long id) {"
            echo "        // TODO: Implement delete method"
            echo "        return ResponseEntity.ok().build();"
            echo "    }"
        fi
        echo "}"
    } > "$file_path"

    echo -e "${CYBER_GREEN}✔ Controller gerado em: ${CYBER_CYAN}$file_path${RESET}"
}