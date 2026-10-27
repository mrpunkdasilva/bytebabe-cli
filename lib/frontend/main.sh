#!/bin/bash

# Carrega as dependências
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"
source "$BASE_DIR/lib/core/pkg.sh"
source "$BASE_DIR/lib/frontend/config.sh"
source "$BASE_DIR/lib/frontend/templates.sh"
[ -f "$BASE_DIR/lib/frontend/help.sh" ] && source "$BASE_DIR/lib/frontend/help.sh"

for _frontend_feature in tailwind redux router i18n; do
    if [ -f "$BASE_DIR/lib/frontend/features/$_frontend_feature.sh" ]; then
        source "$BASE_DIR/lib/frontend/features/$_frontend_feature.sh"
    fi
done
unset _frontend_feature

[ -f "$BASE_DIR/lib/frontend/generators.sh" ] && source "$BASE_DIR/lib/frontend/generators.sh"

# Verifica requisitos básicos
check_frontend_requirements() {
    if ! command -v node &> /dev/null; then
        echo -e "${CYBER_RED}✘ Node.js não encontrado! Por favor, instale o Node.js${RESET}"
        return 1
    fi

    if ! command -v "$(detect_node_pkg_manager)" &> /dev/null; then
        echo -e "${CYBER_RED}✘ Nenhum package manager JavaScript encontrado!${RESET}"
        return 1
    fi
}

# Executa um binário Node usando o package manager detectado.
frontend_exec() {
    local pm
    pm=$(detect_node_pkg_manager)

    case "$pm" in
        npm) npx "$@" ;;
        pnpm) pnpm dlx "$@" ;;
        yarn) yarn dlx "$@" ;;
        bun) bunx "$@" ;;
        *) return 1 ;;
    esac
}

# Instala dependências no projeto atual.
# Uso: frontend_install dev|prod <pacotes...>
frontend_install() {
    local mode="${1:-prod}"
    shift || true

    local pm
    pm=$(detect_node_pkg_manager)

    case "$pm" in
        npm)
            if [[ "$mode" == "dev" ]]; then
                npm install --save-dev "$@"
            else
                npm install "$@"
            fi
            ;;
        pnpm)
            if [[ "$mode" == "dev" ]]; then
                pnpm add -D "$@"
            else
                pnpm add "$@"
            fi
            ;;
        yarn)
            if [[ "$mode" == "dev" ]]; then
                yarn add -D "$@"
            else
                yarn add "$@"
            fi
            ;;
        bun)
            if [[ "$mode" == "dev" ]]; then
                bun add -d "$@"
            else
                bun add "$@"
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

# Instala as dependências já declaradas no projeto.
frontend_install_deps() {
    local pm
    pm=$(detect_node_pkg_manager)

    case "$pm" in
        npm) npm install ;;
        pnpm) pnpm install ;;
        yarn) yarn install ;;
        bun) bun install ;;
        *) return 1 ;;
    esac
}

# Executa um script do package.json com o package manager detectado.
frontend_run_script() {
    local script="${1:-}"
    shift || true

    local pm
    pm=$(detect_node_pkg_manager)

    case "$pm" in
        npm) npm run "$script" -- "$@" ;;
        pnpm|yarn|bun) "$pm" run "$script" "$@" ;;
        *) return 1 ;;
    esac
}

# Cria projeto Vite com o package manager detectado.
frontend_create_vite() {
    local name="$1"
    local template="${2:-react-ts}"

    local pm
    pm=$(detect_node_pkg_manager)

    case "$pm" in
        npm) npm create vite@latest "$name" -- --template "$template" ;;
        pnpm) pnpm create vite@latest "$name" --template "$template" ;;
        yarn) yarn create vite "$name" --template "$template" ;;
        bun) bun create vite "$name" --template "$template" ;;
        *) return 1 ;;
    esac
}

# Cria projeto Vue com o package manager detectado.
frontend_create_vue() {
    local name="$1"

    local pm
    pm=$(detect_node_pkg_manager)

    case "$pm" in
        npm) npm create vue@latest "$name" ;;
        pnpm) pnpm create vue@latest "$name" ;;
        yarn) yarn create vue "$name" ;;
        bun) bun create vue "$name" ;;
        *) return 1 ;;
    esac
}
