#!/bin/bash

# Testes de caracterização dos geradores Spring.
# Nenhum projeto Maven real é necessário; a geração ocorre em diretório temporário.

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/test_helpers.sh
source "$TEST_DIR/../../lib/test_helpers.sh"

SPRING_DIR="$BASE_DIR/lib/backend/spring"
GENERATORS_DIR="$SPRING_DIR/generators"

source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/backend/spring/config.sh"
source "$BASE_DIR/lib/backend/spring/generators/main.sh"
source "$BASE_DIR/lib/backend/spring/dependency.sh"
source "$BASE_DIR/lib/backend/spring/security.sh"
source "$BASE_DIR/lib/backend/spring/monitoring.sh"
source "$BASE_DIR/lib/backend/spring/deployment.sh"

setup_spring_env() {
    SPRING_WORK="$TEST_TMP_DIR/spring-work"
    mkdir -p "$SPRING_WORK/.bytebabe" "$SPRING_WORK/src/main/resources"
    cat > "$SPRING_WORK/pom.xml" << 'XML'
<project>
    <dependencies>
    </dependencies>
</project>
XML

    cat > "$SPRING_WORK/.bytebabe/spring-config.json" << 'JSON'
{
  "basePackage": "com.example.api",
  "defaultPackages": {
    "controller": "controller",
    "service": "service",
    "repository": "repository",
    "entity": "model",
    "dto": "dto",
    "mapper": "mapper",
    "exception": "exception",
    "config": "config"
  }
}
JSON
    export SPRING_WORK
}

test_generator_files_are_source_safe() {
    local file output status
    while IFS= read -r file; do
        if output=$(timeout 5 /bin/bash --noprofile --norc -c \
            'BASE_DIR="$1"; source "$2"' _ "$BASE_DIR" "$file" 2>&1); then
            status=0
        else
            status=$?
        fi

        assert_eq 0 "$status" "source de ${file#$BASE_DIR/} deve retornar 0"
        assert_eq "" "$output" "source de ${file#$BASE_DIR/} não deve produzir saída"
    done < <(find "$GENERATORS_DIR" -maxdepth 1 -name '*.sh' -type f | sort)
}

test_canonical_loader_and_archive() {
    assert_success "mapper.sh deve existir" test -f "$GENERATORS_DIR/mapper.sh"
    assert_success "carregador paralelo deve estar arquivado" \
        test -f "$BASE_DIR/archive/legacy/spring/generators.sh"
    assert_failure "carregador paralelo não deve existir no código ativo" \
        test -e "$SPRING_DIR/generators.sh"

    assert_success "commands/backend/spring/main.sh deve carregar o carregador canônico" \
        grep -q 'generators/main.sh' "$BASE_DIR/commands/backend/spring/main.sh"
    assert_failure "commands/backend/spring/main.sh não deve carregar archive" \
        grep -q 'archive/legacy/spring' "$BASE_DIR/commands/backend/spring/main.sh"

    local duplicate
    for duplicate in controller_generator.sh repository_generator.sh service_generator.sh; do
        assert_success "$duplicate deve estar arquivado" \
            test -f "$BASE_DIR/archive/legacy/spring/generators/$duplicate"
        assert_failure "$duplicate não deve existir no código ativo" \
            test -e "$GENERATORS_DIR/$duplicate"
    done
}

test_one_implementation_per_type() {
    local function_name count files
    for function_name in generate_entity generate_dto generate_repository generate_service generate_controller generate_mapper generate_exception_handler generate_security_config; do
        count=$(grep -RIl "^${function_name}()" "$SPRING_DIR" | wc -l | tr -d ' ')
        assert_eq 1 "$count" "$function_name deve ter uma única implementação ativa"
    done

    assert_success "mapper deve estar no carregador canônico" \
        grep -q 'generators/mapper.sh' "$GENERATORS_DIR/main.sh"
    assert_success "exception handler deve estar no carregador canônico" \
        grep -q 'generators/exception_handler.sh' "$GENERATORS_DIR/main.sh"
}

test_generators_create_expected_files() {
    cd "$SPRING_WORK"

    generate_entity -n User >/dev/null
    generate_dto -n UserDTO -e User >/dev/null
    generate_repository -n UserRepository -e User >/dev/null
    generate_service -n UserService >/dev/null
    generate_controller -n UserController >/dev/null
    generate_mapper -n UserMapper >/dev/null
    generate_exception_handler >/dev/null
    generate_security_config -t basic >/dev/null
    generate_service_test User >/dev/null
    generate_docker_files >/dev/null
    setup_swagger >/dev/null

    local expected
    for expected in \
        src/main/java/com/example/api/model/User.java \
        src/main/java/com/example/api/dto/UserDTO.java \
        src/main/java/com/example/api/repository/UserRepository.java \
        src/main/java/com/example/api/service/UserService.java \
        src/main/java/com/example/api/controller/UserController.java \
        src/main/java/com/example/api/mapper/UserMapper.java \
        src/main/java/com/example/api/exception/GlobalExceptionHandler.java \
        src/main/java/com/example/api/config/SecurityConfig.java \
        src/test/java/com/example/api/service/UserServiceTest.java \
        Dockerfile docker-compose.yml .dockerignore; do
        assert_success "$expected deve ser gerado" test -f "$expected"
    done

    assert_contains "$(cat src/main/java/com/example/api/mapper/UserMapper.java)" \
        'package com.example.api.mapper;' "mapper deve usar o package configurado"
    assert_contains "$(cat src/main/java/com/example/api/mapper/UserMapper.java)" \
        '@Mapper(componentModel = "spring")' "mapper deve usar MapStruct"
    assert_contains "$(cat src/main/java/com/example/api/model/User.java)" \
        'package com.example.api.model;' "entity deve usar o package configurado"

    assert_contains "$(cat pom.xml)" '<artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>' \
        "setup_swagger deve adicionar a dependência ao pom"
    assert_contains "$(cat pom.xml)" '<version>2.3.0</version>' \
        "add_dependency deve preservar a versão explícita"
    add_dependency "org.springdoc:springdoc-openapi-starter-webmvc-ui:2.3.0" >/dev/null
    assert_eq 1 "$(grep -c '<artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>' pom.xml)" \
        "add_dependency deve ser idempotente"

    remove_dependency "org.springdoc:springdoc-openapi-starter-webmvc-ui:2.3.0" >/dev/null
    assert_eq 0 "$(grep -c '<artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>' pom.xml)" \
        "remove_dependency deve remover a dependência"
}

test_generator_errors_return_non_zero() {
    cd "$SPRING_WORK"

    local output status
    if output=$(generate_entity 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "entity sem nome deve retornar 1"
    assert_contains "$output" "Nome da entity é obrigatório" "erro deve explicar o nome"

    if output=$(generate_mapper 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "mapper sem nome deve retornar 1"
    assert_contains "$output" "Nome do mapper é obrigatório" "erro deve explicar o nome"

    if output=$(generate_controller -n User --invalida 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "opção inválida deve retornar 1"

    assert_failure "dependência sem coordenadas deve falhar" add_dependency "sem-coordenadas"
}

test_dispatcher_and_package_helpers() {
    cd "$SPRING_WORK"

    assert_eq "com.example.api" "$(get_base_package)" "get_base_package deve ler a config"
    assert_eq "com/example/api" "$(find_package_path)" "find_package_path deve converter pontos"
    assert_eq "com.example.api.mapper" "$(get_default_package mapper)" \
        "get_default_package deve resolver o package padrão"
    assert_success "generator_exists deve reconhecer mapper" generator_exists mapper
    assert_failure "generator_exists deve rejeitar tipo desconhecido" generator_exists inexistente

    generate_spring_component mapper -n ProductMapper -e Product -d ProductDTO >/dev/null
    assert_success "dispatcher deve gerar mapper" \
        test -f "src/main/java/com/example/api/mapper/ProductMapper.java"
}

test_auxiliary_modules_are_wired_and_source_safe() {
    local module file output status
    for module in security monitoring deployment; do
        file="$SPRING_DIR/${module}.sh"
        if output=$(timeout 5 /bin/bash --noprofile --norc -c \
            'BASE_DIR="$1"; source "$2"' _ "$BASE_DIR" "$file" 2>&1); then
            status=0
        else
            status=$?
        fi

        assert_eq 0 "$status" "source de ${module}.sh deve retornar 0"
        assert_eq "" "$output" "source de ${module}.sh não deve produzir saída"
        assert_success "entrypoint deve carregar ${module}.sh" \
            grep -q "lib/backend/spring/${module}.sh" "$BASE_DIR/commands/backend/spring/main.sh"
    done

    for module in generate_security_report scan_docker_security setup_keycloak_integration \
        export_metrics_data setup_log_aggregation analyze_log_patterns export_log_data list_alert_rules; do
        assert_success "${module} deve estar definida no entrypoint" declare -F "$module"
    done
}

test_security_and_monitoring_helpers() {
    cd "$SPRING_WORK"

    local output status
    assert_failure "scan Docker sem Dockerfile deve falhar" scan_docker_security

    printf 'FROM openjdk:latest\nUSER root\nENV DB_PASSWORD=secret\n' > Dockerfile
    if output=$(scan_docker_security 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "Dockerfile inseguro deve retornar 1"
    assert_contains "$output" "Total de achados: 3" "deve reportar os três achados"

    printf 'FROM eclipse-temurin:21-jre\nUSER app\n' > Dockerfile
    assert_success "Dockerfile seguro deve passar" scan_docker_security

    generate_security_report report.md >/dev/null
    assert_success "relatório de segurança deve ser gerado" test -f report.md

    assert_failure "listar alertas sem arquivo deve falhar" list_alert_rules
    printf 'groups:\n  - name: app\n    rules:\n      - alert: HighLatency\n' > alert-rules.yml
    output=$(list_alert_rules)
    assert_contains "$output" "HighLatency" "list_alert_rules deve mostrar o alerta"

    setup_log_aggregation >/dev/null
    assert_success "logback-spring.xml deve ser gerado" test -f src/main/resources/logback-spring.xml

    mkdir -p logs
    printf 'ERROR falha\nWARN atenção\n' > logs/application.log
    output=$(analyze_log_patterns)
    assert_contains "$output" "Erros: 1" "analyze_log_patterns deve contar erros"
    assert_contains "$output" "Alertas: 1" "analyze_log_patterns deve contar alertas"

    export_log_data >/dev/null
    assert_success "arquivo de logs deve ser exportado" \
        bash -c 'compgen -G "logs-export-*.tar.gz" >/dev/null'

    printf 'FROM eclipse-temurin:21-jre\nUSER app\n' > Dockerfile
    output=$("$BASE_DIR/bin/bytebabe" spring security scan docker 2>&1)
    assert_contains "$output" "Nenhum problema óbvio" \
        "dispatch deve remover o subcomando antes de escanear o Dockerfile"

    output=$("$BASE_DIR/bin/bytebabe" spring monitor logs analyze 2>&1)
    assert_contains "$output" "Erros: 1" "dispatch deve passar o diretório padrão de logs"

    "$BASE_DIR/bin/bytebabe" spring security audit report custom-report.md >/dev/null
    assert_success "dispatch deve respeitar o nome do relatório" test -f custom-report.md

    "$BASE_DIR/bin/bytebabe" spring deploy k8s setup >/dev/null
    assert_success "dispatch de deploy deve gerar manifestos" test -f k8s/deployment.yml
}

test_spring_entrypoint_has_no_exit() {
    assert_failure "commands/backend/spring/main.sh não deve usar exit" \
        grep -qE '^\s*exit\b' "$BASE_DIR/commands/backend/spring/main.sh"
    assert_failure "lib/backend/spring não deve usar exit" \
        grep -qRInE '^\s*exit\b' "$SPRING_DIR"

    assert_success "check_requirements deve retornar ao chamador" \
        grep -q 'check_requirements || return' "$BASE_DIR/commands/backend/spring/main.sh"
}

main() {
    setup_test_env
    setup_spring_env
    trap cleanup_test_env EXIT

    run_test_case "SPRING: geradores são source-safe" test_generator_files_are_source_safe
    run_test_case "SPRING: carregador canônico e archive" test_canonical_loader_and_archive
    run_test_case "SPRING: uma implementação por tipo" test_one_implementation_per_type
    run_test_case "SPRING: geração de arquivos esperados" test_generators_create_expected_files
    run_test_case "SPRING: erros retornam non-zero" test_generator_errors_return_non_zero
    run_test_case "SPRING: dispatcher e helpers de package" test_dispatcher_and_package_helpers
    run_test_case "SPRING: módulos auxiliares carregados" test_auxiliary_modules_are_wired_and_source_safe
    run_test_case "SPRING: segurança e monitoramento" test_security_and_monitoring_helpers
    run_test_case "SPRING: sem exit no entrypoint/libs" test_spring_entrypoint_has_no_exit

    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
