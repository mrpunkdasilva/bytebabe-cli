#!/bin/bash

BASE_DIR="${BASE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/azure/main.sh"

show_azure_header() {
    echo -e "${CYBER_BLUE}"
    cat << "EOF"
 █████╗ ███████╗██╗   ██╗██████╗ ███████╗
██╔══██╗╚══███╔╝██║   ██║██╔══██╗██╔════╝
███████║  ███╔╝ ██║   ██║██████╔╝█████╗
██╔══██║ ███╔╝  ██║   ██║██╔══██╗██╔══╝
██║  ██║███████╗╚██████╔╝██║  ██║███████╗
╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝
EOF
    echo -e "${RESET}"
}

_azure_banner() {
    echo -e "${CYBER_PINK}╔══════════════════════════════════════════════════╗"
    echo -e "║${CYBER_CYAN}  $1  ${CYBER_PINK}"
    echo -e "╚══════════════════════════════════════════════════╝${RESET}"
}

# Ajuda específica de um subcomando. Chamada por <subcomando> -h/--help.
azure_command_help() {
    local cmd="$1"
    local foot="${CYBER_GRAY}Ajuda geral: bytebabe azure help  |  Detalhes do az: bytebabe azure <grupo> --help${RESET}"

    echo -e "${CYBER_CYAN}━━━ bytebabe azure ${CYBER_BOLD}${cmd}${RESET}${CYBER_CYAN} ━━━${RESET}"
    echo ""

    case "$cmd" in
        install|i)
            echo -e "${CYBER_YELLOW}Instala o Azure CLI (az) nativamente, pelo gerenciador de pacotes.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure install ${CYBER_GRAY}(alias: i)${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}O que faz:${RESET}"
            echo -e "  ${CYBER_GREEN}1.${RESET} Detecta o gerenciador suportado: ${CYBER_GREEN}dnf${RESET}, ${CYBER_GREEN}apt-get${RESET}, ${CYBER_GREEN}zypper${RESET} ou ${CYBER_GREEN}tdnf${RESET}"
            echo -e "  ${CYBER_GREEN}2.${RESET} Configura o repositório Microsoft e instala o pacote ${CYBER_GREEN}azure-cli${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Detalhes:${RESET}"
            echo -e "  Se o ${CYBER_GREEN}az${RESET} já existir, só mostra a versão e não reinstala"
            echo -e "  RHEL/CentOS/Alma/Rocky 8, 9 e 10 têm repositórios dedicados; Fedora usa o genérico"
            echo -e "  As extensões do az precisam de pip; se faltar, o ${CYBER_GREEN}setup${RESET} instala python3-pip"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure install${RESET}"
            echo ""
            echo -e "  ${CYBER_RED}Usa sudo para instalar pacotes do sistema.${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        setup)
            echo -e "${CYBER_YELLOW}Configuração completa do Azure DevOps em 4 passos:${RESET}"
            echo -e "  ${CYBER_GREEN}1.${RESET} Instala o Azure CLI, se ainda não existir"
            echo -e "  ${CYBER_GREEN}2.${RESET} Instala a extensão azure-devops (necessária para PRs, repos e boards)"
            echo -e "  ${CYBER_GREEN}3.${RESET} Faz login na sua conta Microsoft (AAD)"
            echo -e "  ${CYBER_GREEN}4.${RESET} Salva organização/projeto padrão via az devops configure --defaults"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure setup ${CYBER_GRAY}[--login] <organização|URL> [projeto]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}organização${RESET}  Nome curto ou URL; aceita https://dev.azure.com/<org>/<projeto>"
            echo -e "                       ${CYBER_GRAY}(o projeto da URL é separado automaticamente)${RESET}"
            echo -e "  ${CYBER_GREEN}projeto${RESET}      Nome do projeto; opcional; coloque entre aspas se tiver espaços"
            echo -e "  ${CYBER_GREEN}--login${RESET}      Refaz o login mesmo que já haja sessão ativa"
            echo ""
            echo -e "${CYBER_GRAY}Sem organização em terminal interativo, ela é perguntada (Enter pula o passo).${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure setup minha-org 'Meu Projeto'${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure setup --login minha-org 'Meu Projeto'${RESET}   ${CYBER_GRAY}# refaz o login${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure setup https://dev.azure.com/minha-org${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        login|auth)
            echo -e "${CYBER_YELLOW}Autentica na Azure por AAD (navegador/código) ou PAT (token).${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure login ${CYBER_GRAY}[organização|URL]${RESET}         ${CYBER_GRAY}# AAD (padrão)${RESET}"
            echo -e "  bytebabe azure login --pat ${CYBER_GRAY}[organização|URL]${RESET}   ${CYBER_GRAY}# token de acesso pessoal${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Modos:${RESET}"
            echo -e "  ${CYBER_GREEN}AAD${RESET}   az login --allow-no-subscriptions (cobre orgs em tenant sem assinatura)"
            echo -e "  ${CYBER_GREEN}PAT${RESET}   az devops login; o token é pedido sem eco no terminal"
            echo ""
            echo -e "${CYBER_GRAY}Com organização informada, também salva organization/project como padrão do az.${RESET}"
            echo -e "${CYBER_GRAY}URLs antigas (*.visualstudio.com) devem ser informadas completas.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure login${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure login minha-org${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure login --pat https://dev.azure.com/minha-org${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        pr)
            echo -e "${CYBER_YELLOW}Cria um pull request da branch atual para a base indicada.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure pr ${CYBER_BOLD}<título>${RESET} ${CYBER_GRAY}[base]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}título${RESET}   Título do PR (obrigatório)"
            echo -e "  ${CYBER_GREEN}base${RESET}     Branch de destino; sem ela, usa main ou master (nessa ordem)"
            echo ""
            echo -e "${CYBER_YELLOW}Como funciona:${RESET}"
            echo -e "  Origem é a branch atual do repositório Git local"
            echo -e "  Descrição é montada com os commits entre a base e o HEAD (${CYBER_GREEN}origin/base..HEAD${RESET})"
            echo -e "  Cria via ${CYBER_GREEN}az repos pr create${RESET} e exibe ID, título e status em tabela"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            -e "  ${CYBER_GREEN}bytebabe azure pr \"Minha alteração\"${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure pr \"Minha alteração\" develop${RESET}"
            echo ""
            echo -e "  ${CYBER_RED}Precisa de repositório Git, az com a extensão azure-devops e login válido.${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        prs|pr-list|search-pr|pr-search|find-pr)
            echo -e "${CYBER_YELLOW}Lista, pesquisa, filtra e agrupa os pull requests do repositório atual.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure prs ${CYBER_GRAY}[termo] [opções]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Opções:${RESET}"
            echo -e "  ${CYBER_GREEN}-q${RESET}, ${CYBER_GREEN}-s${RESET}, ${CYBER_GREEN}--query${RESET} <termo>    Filtro livre por id, título, branches e autor"
            echo -e "  ${CYBER_GREEN}-a${RESET}, ${CYBER_GREEN}--author${RESET} <nome>       Filtro por autor (contém, ignora maiúsc/minúsc)"
            echo -e "  ${CYBER_GREEN}-m${RESET}, ${CYBER_GREEN}--mine${RESET}                Só os PRs do usuário atual (git config ou az account)"
            echo -e "  ${CYBER_GREEN}-t${RESET}, ${CYBER_GREEN}--target${RESET} <branch>     Filtra pela branch de destino"
            echo -e "  ${CYBER_GREEN}-b${RESET}, ${CYBER_GREEN}--branch${RESET} <branch>     Filtra pela branch de origem"
            echo -e "  ${CYBER_GREEN}-T${RESET}, ${CYBER_GREEN}--type${RESET} <categoria>    Categoria pelo título: fix, feat, docs, chore..."
            echo -e "  ${CYBER_GREEN}--status${RESET} <status>          active (padrão), abandoned, completed, all"
            echo -e "  ${CYBER_GREEN}-n${RESET}, ${CYBER_GREEN}--top${RESET}, ${CYBER_GREEN}--limit${RESET} <n>    Quantos PRs buscar do servidor (padrão 100)"
            echo -e "  ${CYBER_GREEN}--group${RESET}, ${CYBER_GREEN}--by-type${RESET}          Agrupa por categoria do título"
            echo -e "  ${CYBER_GREEN}--by-author${RESET}                Agrupa por autor"
            echo -e "  ${CYBER_GREEN}--by-target${RESET}                Agrupa por branch de destino"
            echo -e "  ${CYBER_GREEN}--stats${RESET}, ${CYBER_GREEN}--summary${RESET}          Resumo com contagens"
            echo -e "  ${CYBER_GREEN}-p${RESET}/${CYBER_GREEN}--project${RESET}, ${CYBER_GREEN}-r${RESET}/${CYBER_GREEN}--repository${RESET}, ${CYBER_GREEN}--org${RESET}   Repassados diretamente ao az"
            echo ""
            echo -e "${CYBER_GRAY}Em terminal, a saída é paginada com less.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure prs${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure prs \"vivo\"${RESET}                 ${CYBER_GRAY}# termo livre${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure prs --mine --by-author${RESET}     ${CYBER_GRAY}# meus PRs agrupados${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure prs --type fix --stats${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        projects|proj)
            echo -e "${CYBER_YELLOW}Lista os projetos da organização em tabela compacta e ordenada por nome.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure projects ${CYBER_GRAY}[organização|URL]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}organização${RESET}  Nome curto ou URL; sem ela, usa a organização padrão do setup"
            echo ""
            echo -e "${CYBER_YELLOW}Saída:${RESET}"
            echo -e "  Colunas: nº, nome, visibilidade (private/public) e data da última atualização"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure projects${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure projects minha-org${RESET}"
            echo ""
            echo -e "  ${CYBER_RED}Precisa do az com a extensão azure-devops e login válido.${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        branches|br|refs)
            echo -e "${CYBER_YELLOW}Lista as branchs (refs/heads) de um repositório em tabela paginada.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure branches ${CYBER_BOLD}<repo>${RESET} ${CYBER_GRAY}[organização|URL]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}repo${RESET}         Nome ou ID do repositório (obrigatório)"
            echo -e "  ${CYBER_GREEN}organização${RESET}  Opcional; sem ela, usa a organização padrão do setup"
            echo ""
            echo -e "${CYBER_YELLOW}Saída:${RESET}"
            echo -e "  Colunas: branch, ID abreviado (8 caracteres) e autor; ordenada por nome"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure branches meu-repo${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure branches meu-repo https://dev.azure.com/minha-org${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        tags|tag)
            echo -e "${CYBER_YELLOW}Lista as tags (refs/tags) de um repositório em tabela paginada.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure tags ${CYBER_BOLD}<repo>${RESET} ${CYBER_GRAY}[organização|URL]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}repo${RESET}         Nome ou ID do repositório (obrigatório)"
            echo -e "  ${CYBER_GREEN}organização${RESET}  Opcional; sem ela, usa a organização padrão do setup"
            echo ""
            echo -e "${CYBER_YELLOW}Saída:${RESET}"
            echo -e "  Colunas: tag, ID abreviado (8 caracteres) e autor; ordenada por nome"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure tags meu-repo${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure tags meu-repo https://dev.azure.com/minha-org${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        merge)
            echo -e "${CYBER_YELLOW}Conclui (completa) um pull request na branch de destino.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure merge ${CYBER_GRAY}[id] [merge|squash]${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Argumentos:${RESET}"
            echo -e "  ${CYBER_GREEN}id${RESET}       Número do PR; sem ele, procura o PR ativo da branch atual"
            echo -e "  ${CYBER_GREEN}método${RESET}   ${CYBER_GREEN}merge${RESET} (padrão) ou ${CYBER_GREEN}squash${RESET}; outro valor é rejeitado"
            echo ""
            echo -e "${CYBER_YELLOW}Como funciona:${RESET}"
            echo -e "  Executa ${CYBER_GREEN}az repos pr update --status completed${RESET} no PR indicado"
            echo -e "  Com políticas de branch, a conclusão só ocorre após as aprovações"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure merge 20 merge${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure merge 20 squash${RESET}"
            echo ""
            echo -e "  ${CYBER_RED}Merge e exclusão podem ser irreversíveis; confira o PR antes.${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        project)
            echo -e "${CYBER_YELLOW}Grupo completo do az devops project: criar, consultar, listar, atualizar e excluir.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure project ${CYBER_GRAY}[subcomando do az] [argumentos]${RESET}"
            echo ""
            echo -e "${CYBER_GRAY}Sem argumentos, mostra a ajuda do próprio az para este grupo.${RESET}"
            echo -e "${CYBER_GRAY}Os argumentos são encaminhados diretamente ao az; --project aceita nome ou ID.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure project show --project 'Meu Projeto'${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure project create --name 'Meu Projeto'${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure project list --output table${RESET}"
            echo ""
            echo -e "  ${CYBER_RED}Create/delete exigem permissões; exclusão é permanente.${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        repo)
            echo -e "${CYBER_YELLOW}Grupo completo do az repos: repositórios, branches, políticas e importações.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure repo ${CYBER_GRAY}[subcomando do az] [argumentos]${RESET}"
            echo ""
            echo -e "${CYBER_GRAY}Sem argumentos, mostra a ajuda do próprio az para este grupo.${RESET}"
            echo -e "${CYBER_GRAY}Subgrupos úteis: repo list/create, repo ref, repo policy, repo import.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure repo list --project 'Meu Projeto' --output table${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure repo create --name meu-repo --project 'Meu Projeto'${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure repo ref list --repository meu-repo${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure repo policy list --repository-id <id> --output table${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        pr-manage)
            echo -e "${CYBER_YELLOW}Grupo completo do az repos pr: consultar, atualizar, votar e revisar PRs.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure pr-manage ${CYBER_GRAY}[subcomando do az] [argumentos]${RESET}"
            echo ""
            echo -e "${CYBER_GRAY}Sem argumentos, mostra a ajuda do próprio az para este grupo.${RESET}"
            echo -e "${CYBER_GRAY}Subcomandos: show, update, list, vote, reviewer add/remove/list, work-item add/remove.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure pr-manage show --id 20${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure pr-manage set-vote --id 20 --vote approve${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure pr-manage reviewer add --id 20 --reviewers pessoa@empresa.com${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure pr-manage update --id 20 --status abandoned${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        pipeline)
            echo -e "${CYBER_YELLOW}Grupo completo do az pipelines: criar, executar e inspecionar pipelines.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure pipeline ${CYBER_GRAY}[subcomando do az] [argumentos]${RESET}"
            echo ""
            echo -e "${CYBER_GRAY}Sem argumentos, mostra a ajuda do próprio az para este grupo.${RESET}"
            echo -e "${CYBER_GRAY}Subgrupos: runs, logs, variable-groups, agent-pools, build, release...${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure pipeline list --output table${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure pipeline run --name meu-pipeline --branch main${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure pipeline runs show --id 42${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        boards)
            echo -e "${CYBER_YELLOW}Grupo completo do az boards: work items, consultas, áreas e iterações.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure boards ${CYBER_GRAY}[subcomando do az] [argumentos]${RESET}"
            echo ""
            echo -e "${CYBER_GRAY}Sem argumentos, mostra a ajuda do próprio az para este grupo.${RESET}"
            echo -e "${CYBER_GRAY}Subgrupos: work-item (create/show/update), query, area, iteration...${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure boards work-item create --type Task --title 'Minha tarefa'${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure boards work-item show --id 123${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure boards query --wiql 'SELECT [System.Id] FROM WorkItems'${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        artifacts)
            echo -e "${CYBER_YELLOW}Grupo completo do az artifacts: feeds e pacotes universais.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure artifacts ${CYBER_GRAY}[subcomando do az] [argumentos]${RESET}"
            echo ""
            echo -e "${CYBER_GRAY}Sem argumentos, mostra a ajuda do próprio az para este grupo.${RESET}"
            echo -e "${CYBER_GRAY}Subgrupos: universal publish/download, feed, package, version...${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure artifacts universal publish --feed meu-feed --name meu-pacote --version 1.0.0 --path ./dist${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure artifacts universal download --feed meu-feed --name meu-pacote --version 1.0.0 --path ./pacote${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        devops)
            echo -e "${CYBER_YELLOW}Grupo completo do az devops: usuários, equipes, permissões e configuração.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure devops ${CYBER_GRAY}[subcomando do az] [argumentos]${RESET}"
            echo ""
            echo -e "${CYBER_GRAY}Sem argumentos, mostra a ajuda do próprio az para este grupo.${RESET}"
            echo -e "${CYBER_GRAY}Subgrupos: user, team, security, service-endpoint, extension, configure...${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure devops team list --project 'Meu Projeto' --output table${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure devops user list --output table${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        cli)
            echo -e "${CYBER_YELLOW}Executa o az diretamente: qualquer operação Azure, inclusive fora do DevOps.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Uso:${RESET}"
            echo -e "  bytebabe azure cli ${CYBER_GRAY}[comando do az] [argumentos]${RESET}"
            echo ""
            echo -e "${CYBER_GRAY}Requer o az instalado (${CYBER_GREEN}bytebabe azure install${CYBER_GRAY}); os argumentos vão direto ao az.${RESET}"
            echo ""
            echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure cli account list --output table${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure cli group list --output table${RESET}"
            echo -e "  ${CYBER_GREEN}bytebabe azure cli vm list --output table${RESET}"
            echo ""
            echo -e "$foot"
            ;;
        *)
            echo -e "${CYBER_YELLOW}Sem ajuda específica para este subcomando.${RESET}"
            echo ""
            echo -e "$foot"
            ;;
    esac
}

main() {
    local cmd=${1:-help}
    [ $# -gt 0 ] && shift

    # -h/--help junto ao subcomando: mostra a ajuda textual e não executa nada
    if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
        azure_command_help "$cmd"
        return 0
    fi

    case "$cmd" in
        install|i)
            show_azure_header
            _azure_banner "INSTALANDO INTERFACE AZURE CLI..."
            az_install
            ;;
        setup)
            show_azure_header
            _azure_banner "CONECTANDO À NUVEM AZURE DEVOPS..."
            az_setup "$@"
            ;;
        login|auth)
            show_azure_header
            _azure_banner "AUTENTICANDO CONEXÃO SECRETA..."
            az_login "$@"
            ;;
        pr)
            show_azure_header
            _azure_banner "INICIANDO PROTOCOLO DE FUSÃO DE REALIDADES..."
            az_pr "$@"
            ;;
        prs|pr-list|search-pr|pr-search|find-pr)
            show_azure_header
            _azure_banner "ESCANEANDO PORTAIS INTERDIMENSIONAIS ABERTOS..."
            az_prs "$@"
            ;;
        projects|proj)
            show_azure_header
            _azure_banner "MAPEANDO SETORES DA MEGACORP AZURE..."
            az_projects "$@"
            ;;
        branches|br|refs)
            show_azure_header
            _azure_banner "ESCANEANDO FLUXOS TEMPORAIS DO REPOSITÓRIO..."
            az_branches "$@"
            ;;
        tags|tag)
            show_azure_header
            _azure_banner "INVENTARIANDO ARTEFATOS SELADOS DO REPOSITÓRIO..."
            az_tags "$@"
            ;;
        merge)
            show_azure_header
            _azure_banner "FUNDINDO REALIDADES NA LINHA TEMPORAL PRINCIPAL..."
            az_merge "$@"
            ;;
        project|repo|pr-manage|pipeline|boards|artifacts|devops|cli)
            az_operations "$cmd" "$@"
            ;;
        help|--help|-h)
            show_azure_header
            az_help
            ;;
        *)
            show_azure_header
            echo -e "${CYBER_RED}Comando inválido: $cmd${RESET}"
            az_help
            return 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
