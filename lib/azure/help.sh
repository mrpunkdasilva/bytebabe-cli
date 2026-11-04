# ==================================================
# AZURE DEVOPS HELP DOCUMENTATION
# ==================================================

_az_help_section() {
    printf '\n%b%s%b\n' "$CYBER_PURPLE" '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━' "$RESET"
    printf '  %b%s%b\n\n' "$CYBER_YELLOW" "$1" "$RESET"
}

_az_help_entry() {
    local command=$1 description=$2 example
    shift 2
    printf '  %b%-12s%b\n    %s\n' "$CYBER_GREEN" "$command" "$RESET" "$description"
    for example in "$@"; do
        printf '    %b$ %s%b\n' "$CYBER_CYAN" "$example" "$RESET"
    done
    printf '\n'
}

az_help() {
    printf '  %bAZURE DEVOPS | CENTRAL DE COMANDOS%b\n' "$CYBER_BLUE" "$RESET"
    printf '  bytebabe azure <comando> [argumentos]  |  alias: az, ado\n'

    _az_help_section '01 / PREPARAÇÃO'
    _az_help_entry install 'Instala o Azure CLI via dnf, apt, zypper ou tdnf.' \
        'bytebabe az install'
    _az_help_entry login 'Faz login na Azure (AAD ou PAT); com org informada, também salva os padrões.' \
        'bytebabe az login' \
        'bytebabe az login minha-org' \
        'bytebabe az login --pat https://dev.azure.com/minha-org'
    _az_help_entry setup 'Instala CLI e extensão, faz login e salva organização/projeto.' \
        "bytebabe az setup minha-org 'Meu Projeto'" \
        "bytebabe az setup --login minha-org 'Meu Projeto'  # refaz o login"

    _az_help_section '02 / PULL REQUESTS'
    _az_help_entry pr 'Cria um PR da branch atual para a base indicada (padrão: main/master).' \
        'bytebabe az pr "Minha alteração" main'
    _az_help_entry prs 'Lista, pesquisa, filtra e categoriza PRs (busca por termo, tipo, autor ou branch).' \
        'bytebabe az prs' \
        'bytebabe az prs "vivo"' \
        'bytebabe az prs --author "Gustavo"' \
        'bytebabe az prs --mine' \
        'bytebabe az prs --type fix' \
        'bytebabe az prs --group' \
        'bytebabe az prs --by-author' \
        'bytebabe az prs --stats' \
        'bytebabe az prs --help'
    _az_help_entry merge 'Completa o PR indicado; sem ID, procura o PR da branch atual.' \
        'bytebabe az merge 20 merge' 'bytebabe az merge 20 squash'
    _az_help_entry pr-manage 'Consulta, atualiza, vota, adiciona revisores ou abandona PRs.' \
        'bytebabe az pr-manage show --id 20' \
        'bytebabe az pr-manage reviewer add --id 20 --reviewers pessoa@empresa.com' \
        'bytebabe az pr-manage set-vote --id 20 --vote approve' \
        'bytebabe az pr-manage update --id 20 --status abandoned'

    _az_help_section '03 / PROJETOS E REPOSITÓRIOS'
    _az_help_entry projects 'Lista projetos em uma tabela compacta (organização opcional).' \
        'bytebabe az projects minha-org'
    _az_help_entry project 'Lista, consulta, cria, atualiza ou exclui projetos.' \
        "bytebabe az project show --project 'Meu Projeto'" \
        "bytebabe az project create --name 'Meu Projeto'"
    _az_help_entry repo 'Gerencia repositórios, branches, políticas, referências e importações.' \
        "bytebabe az repo list --project 'Meu Projeto' --output table" \
        "bytebabe az repo create --name meu-repo --project 'Meu Projeto'" \
        'bytebabe az repo ref list --repository meu-repo' \
        'bytebabe az repo policy list --repository-id <id> --output table'
    _az_help_entry branches 'Lista as branchs de um repositório compactas e paginadas (alias: br, refs).' \
        'bytebabe az branches meu-repo' \
        'bytebabe az branches <repo> https://dev.azure.com/minha-org'
    _az_help_entry tags 'Lista as tags de um repositório compactas e paginadas (alias: tag).' \
        'bytebabe az tags meu-repo' \
        'bytebabe az tags <repo> https://dev.azure.com/minha-org'

    _az_help_section '04 / ENTREGA E PLANEJAMENTO'
    _az_help_entry pipeline 'Cria/executa pipelines e consulta runs, logs, variáveis e agentes.' \
        'bytebabe az pipeline list --output table' \
        'bytebabe az pipeline run --name meu-pipeline --branch main' \
        'bytebabe az pipeline runs show --id 42'
    _az_help_entry boards 'Gerencia work items, consultas, relações, áreas e iterações.' \
        "bytebabe az boards work-item create --type Task --title 'Minha tarefa'" \
        'bytebabe az boards work-item show --id 123' \
        "bytebabe az boards query --wiql 'SELECT [System.Id] FROM WorkItems'"
    _az_help_entry artifacts 'Publica ou baixa pacotes universais.' \
        $'bytebabe az artifacts universal publish \\\n      --feed meu-feed --name meu-pacote --version 1.0.0 --path ./dist' \
        $'bytebabe az artifacts universal download \\\n      --feed meu-feed --name meu-pacote --version 1.0.0 --path ./pacote'

    _az_help_section '05 / ADMINISTRAÇÃO E AZURE'
    _az_help_entry devops 'Gerencia usuários, equipes, permissões, endpoints e configuração.' \
        "bytebabe az devops team list --project 'Meu Projeto' --output table" \
        'bytebabe az devops user list --output table'
    _az_help_entry cli 'Acessa qualquer operação Azure, inclusive recursos fora do DevOps.' \
        'bytebabe az cli account list --output table' \
        'bytebabe az cli group list --output table' \
        'bytebabe az cli vm list --output table'

    _az_help_section '06 / ARGUMENTOS E AJUDA'
    printf '  %bOrganização%b\n' "$CYBER_BLUE" "$RESET"
    printf '    setup/projects aceitam nome ou https://dev.azure.com/minha-org.\n'
    printf '    URLs antigas (*.visualstudio.com) devem ser informadas completas.\n'
    printf '    Nos grupos completos, --organization exige a URL completa.\n'
    printf '    --project aceita nome ou ID; coloque nomes com espaços entre aspas.\n\n'
    printf '  %bPadrões e detecção%b\n' "$CYBER_BLUE" "$RESET"
    printf '    O az usa os padrões do setup ou detecta pelo remote Git.\n'
    printf '    Use --detect false para usar só os padrões, quando suportado.\n'
    printf '    Os grupos completos encaminham seus argumentos diretamente ao az.\n\n'
    _az_help_entry '--help' 'Mostra operações e parâmetros de cada grupo ou subcomando.' \
        'bytebabe az repo --help' \
        'bytebabe az pr-manage reviewer add --help'
    printf '  %bATENÇÃO%b\n' "$CYBER_RED" "$RESET"
    printf '    Substitua os exemplos pelos seus valores. Escrita exige permissões.\n'
    printf '    Exclusão e merge podem ser irreversíveis.\n'
}
