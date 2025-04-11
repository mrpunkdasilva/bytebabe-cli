BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"


source "$BASE_DIR/lib/github/main.sh"


cmd=$1
shift || true

case "$cmd" in
        clone)
            gh_clone "$@"
            ;;
        create)
            gh_create "$@"
            ;;
        commit)
            gh_commit "$@"
            ;;
        push)
            gh_push "$@"
            ;;
        pull)
            gh_pull "$@"
            ;;
        branch)
            gh_branch "$@"
            ;;
        branches)
            gh_branches
            ;;
        checkout)
            gh_checkout "$@"
            ;;
        pr)
            gh_pr "$@"
            ;;
        prs)
            gh_prs
            ;;
        status)
            gh_status
            ;;
        help|"")
            gh_help
            ;;
        *)
            echo -e "${RED}Comando GitHub desconhecido: $cmd${NC}"
            echo -e "Use 'bytebabe gh help' para ver os comandos disponíveis"
            return 1
            ;;
    esac
