#!/bin/bash

# Testes de caracterização do dispatcher e adaptadores frontend.
# Nenhum projeto real é criado; apenas package.json e stubs de package managers.

set -euo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/test_helpers.sh
source "$TEST_DIR/../../lib/test_helpers.sh"

FRONTEND_DIR="$BASE_DIR/lib/frontend"

source "$BASE_DIR/lib/frontend/main.sh"

setup_frontend_workdir() {
    FRONTEND_WORK="$TEST_TMP_DIR/frontend-work"
    mkdir -p "$FRONTEND_WORK"
    export FRONTEND_WORK
}

make_project() {
    local framework="$1"
    local dir="$FRONTEND_WORK/$framework-project"
    mkdir -p "$dir"

    case "$framework" in
        react) printf '{"dependencies":{"react":"18.0.0"}}\n' > "$dir/package.json" ;;
        vue) printf '{"dependencies":{"vue":"3.0.0"}}\n' > "$dir/package.json" ;;
        angular) printf '{"dependencies":{"@angular/core":"17.0.0"}}\n' > "$dir/package.json" ;;
        *) printf '{"dependencies":{}}\n' > "$dir/package.json" ;;
    esac

    cd "$dir"
}

make_pm_stub() {
    local manager="$1"
    local dir="$TEST_TMP_DIR/pm-$manager"
    mkdir -p "$dir"
    cat > "$dir/$manager" << 'STUB'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >> "$PM_LOG"
STUB
    chmod +x "$dir/$manager"
    echo "$dir"
}

test_frontend_files_are_source_safe() {
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
    done < <(find "$FRONTEND_DIR" -name '*.sh' -type f | sort)
}

test_dispatcher_is_single() {
    local function_name count
    for function_name in detect_framework generate_component generate_service; do
        count=$(grep -RIl "^${function_name}()" "$FRONTEND_DIR" | wc -l | tr -d ' ')
        assert_eq 1 "$count" "$function_name deve ter uma única implementação"
    done

    assert_failure "adaptadores não devem definir generate_component" \
        grep -q '^generate_component()' "$FRONTEND_DIR/react/generators.sh" "$FRONTEND_DIR/vue/generators.sh" "$FRONTEND_DIR/angular/generators.sh"
    assert_success "dispatcher deve carregar adaptadores" \
        grep -q 'react/generators.sh' "$FRONTEND_DIR/generators.sh"
    assert_success "main deve carregar o dispatcher" \
        grep -q 'frontend/generators.sh' "$FRONTEND_DIR/main.sh"
}

test_react_generation() {
    make_project react

    generate_component UserProfile >/dev/null
    generate_service Auth >/dev/null
    generate_react_page Dashboard >/dev/null
    generate_react_hook Session >/dev/null

    assert_success "componente React deve ser criado" test -f src/components/UserProfile/UserProfile.tsx
    assert_success "estilo React deve ser criado" test -f src/components/UserProfile/UserProfile.scss
    assert_success "teste React deve ser criado" test -f src/components/UserProfile/UserProfile.test.tsx
    assert_success "serviço React deve ser criado" test -f src/services/AuthService.ts
    assert_success "página React deve ser criada" test -f src/pages/Dashboard/index.tsx
    assert_success "hook React deve ser criado" test -f src/hooks/useSession.ts
}

test_vue_generation() {
    make_project vue

    generate_component Card >/dev/null
    generate_service User >/dev/null

    assert_success "componente Vue deve ser criado" test -f src/components/Card/Card.vue
    assert_success "teste Vue deve ser criado" test -f src/components/Card/Card.spec.ts
    assert_success "store Vue deve ser criada" test -f src/stores/UserStore.ts
}

test_angular_generation() {
    make_project angular

    generate_component Hero >/dev/null
    generate_service Api >/dev/null

    assert_success "componente Angular deve ser criado" test -f src/app/components/Hero/Hero.component.ts
    assert_success "template Angular deve ser criado" test -f src/app/components/Hero/Hero.component.html
    assert_success "teste Angular deve ser criado" test -f src/app/components/Hero/Hero.component.spec.ts
    assert_success "serviço Angular deve ser criado" test -f src/app/services/Api.service.ts
}

test_generation_errors_return_non_zero() {
    make_project react

    local output status
    if output=$(generate_component 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "componente sem nome deve retornar 1"
    assert_contains "$output" "Nome do componente é obrigatório" "erro deve explicar o nome"

    if output=$(generate_service 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "serviço sem nome deve retornar 1"

    make_project desconhecido
    if output=$(generate_component Anything 2>&1); then
        status=0
    else
        status=$?
    fi
    assert_eq 1 "$status" "framework não detectado deve retornar 1"
    assert_contains "$output" "Framework não detectado" "erro deve explicar o framework"
}

test_core_detects_node_package_manager() {
    local pm_dir empty_dir
    pm_dir=$(make_pm_stub pnpm)
    empty_dir="$TEST_TMP_DIR/pm-empty"
    mkdir -p "$empty_dir"

    assert_eq "pnpm" "$(PATH="$pm_dir" detect_node_pkg_manager)" \
        "deve detectar pnpm quando disponível"
    assert_eq "npm" "$(PATH="$empty_dir" detect_node_pkg_manager)" \
        "deve usar npm como fallback"
}

test_package_helpers_use_detected_manager() {
    local pm_dir
    pm_dir=$(make_pm_stub pnpm)
    PM_LOG="$TEST_TMP_DIR/pm.log"
    : > "$PM_LOG"
    export PM_LOG

    PATH="$pm_dir" frontend_install dev vitest >/dev/null
    PATH="$pm_dir" frontend_install_deps >/dev/null
    PATH="$pm_dir" frontend_run_script test:watch >/dev/null
    PATH="$pm_dir" frontend_exec create vite@latest demo --template react-ts >/dev/null

    assert_contains "$(cat "$PM_LOG")" "pnpm add -D vitest" "install dev deve usar pnpm"
    assert_contains "$(cat "$PM_LOG")" "pnpm install" "install deps deve usar pnpm"
    assert_contains "$(cat "$PM_LOG")" "pnpm run test:watch" "script deve usar pnpm"
    assert_contains "$(cat "$PM_LOG")" "pnpm dlx create vite@latest demo --template react-ts" \
        "exec deve usar pnpm dlx"
}

test_features_and_config_are_wired() {
    local feature
    for feature in setup_tailwind generate_redux_store generate_react_router generate_vue_router generate_i18n_setup; do
        assert_success "$feature deve ser carregada pelo main" declare -F "$feature"
    done

    local dir="$FRONTEND_WORK/config-project"
    mkdir -p "$dir"
    printf '{"dependencies":{"react":"18.0.0"}}\n' > "$dir/package.json"
    cd "$dir"
    init_frontend_config
    assert_success "init_frontend_config deve criar .bytebabe" test -d .bytebabe
    assert_success "config frontend deve ser criada" test -f .bytebabe/frontend-config.json
}

main() {
    setup_test_env
    setup_frontend_workdir
    trap cleanup_test_env EXIT

    run_test_case "FRONTEND: arquivos são source-safe" test_frontend_files_are_source_safe
    run_test_case "FRONTEND: dispatcher único" test_dispatcher_is_single
    run_test_case "FRONTEND React: geração" test_react_generation
    run_test_case "FRONTEND Vue: geração" test_vue_generation
    run_test_case "FRONTEND Angular: geração" test_angular_generation
    run_test_case "FRONTEND: erros retornam non-zero" test_generation_errors_return_non_zero
    run_test_case "FRONTEND: detecção de package manager no core" test_core_detects_node_package_manager
    run_test_case "FRONTEND: helpers usam package manager detectado" test_package_helpers_use_detected_manager
    run_test_case "FRONTEND: features e config conectadas" test_features_and_config_are_wired

    show_test_summary
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
