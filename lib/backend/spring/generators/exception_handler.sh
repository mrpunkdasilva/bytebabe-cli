#!/bin/bash

generate_exception_handler() {
    local name="GlobalExceptionHandler"
    local package=""

    # Parse argumentos
    while [[ $# -gt 0 ]]; do
        case "$1" in
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
    if [[ -z "$package" ]]; then
        package=$(get_default_package "exception")
    fi

    echo -e "${CYBER_BLUE}▶ Gerando exception handler...${RESET}"

    # Cria estrutura de diretórios
    local package_dir="src/main/java/${package//./\/}"
    mkdir -p "$package_dir"

    # Gera o código
    local file_path="$package_dir/$name.java"
    
    {
        echo "package $package;"
        echo
        echo "import org.springframework.http.HttpStatus;"
        echo "import org.springframework.http.ResponseEntity;"
        echo "import org.springframework.web.bind.annotation.ControllerAdvice;"
        echo "import org.springframework.web.bind.annotation.ExceptionHandler;"
        echo "import jakarta.persistence.EntityNotFoundException;"
        echo "import jakarta.validation.ConstraintViolationException;"
        echo
        echo "@ControllerAdvice"
        echo "public class $name {"
        echo
        echo "    @ExceptionHandler(EntityNotFoundException.class)"
        echo "    public ResponseEntity<Object> handleEntityNotFound(EntityNotFoundException ex) {"
        echo "        return ResponseEntity.notFound().build();"
        echo "    }"
        echo
        echo "    @ExceptionHandler(ConstraintViolationException.class)"
        echo "    public ResponseEntity<Object> handleValidation(ConstraintViolationException ex) {"
        echo "        return ResponseEntity.badRequest().body(ex.getMessage());"
        echo "    }"
        echo
        echo "    @ExceptionHandler(Exception.class)"
        echo "    public ResponseEntity<Object> handleGeneral(Exception ex) {"
        echo "        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)"
        echo "            .body(\"Internal server error\");"
        echo "    }"
        echo "}"
    } > "$file_path"

    echo -e "${CYBER_GREEN}✔ Exception handler gerado em: ${CYBER_CYAN}$file_path${RESET}"
}