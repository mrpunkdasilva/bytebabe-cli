#!/bin/bash

# Load core functions and variables
source "$BASE_DIR/lib/core/colors.sh"
source "$BASE_DIR/lib/core/helpers.sh"

# Docker command with proper permissions
cmd_docker="docker"
if ! docker ps >/dev/null 2>&1; then
    cmd_docker="sudo docker"
fi

image_harbor() {
    # Verify Docker is accessible
    if ! $cmd_docker ps >/dev/null 2>&1; then
        echo -e "${CYBER_RED}Error: Cannot connect to Docker daemon${RESET}"
        echo -e "${CYBER_YELLOW}Please ensure Docker is running and you have permissions${RESET}"
        return 1
    fi

    # Non-interactive mode
    if [[ -n "$1" ]]; then
        handle_image_args "$@"
        return $?
    fi

    # Interactive mode - Main Menu
    while true; do
        clear
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ IMAGE HARBOR - MAIN MENU ▓▓${RESET}"

        local main_options=(
            "📋 List Images"
            "🔍 Search Images"
            "📊 Image Statistics"
            "🛠️ Create New Image"
            "📥 Pull Management"
            "📤 Push Management"
            "🧹 Cleanup Images"
            "⬅ Back to Main Menu"
        )

        choose_from_menu "Select an action:" main_action "${main_options[@]}"

        case $main_action in
            *List*)
                list_images_menu
                ;;
            *Search*)
                search_images_menu
                ;;
            *Statistics*)
                show_image_stats
                ;;
            *Create*)
                create_image_menu
                ;;
            *Pull*)
                pull_management_menu
                ;;
            *Push*)
                push_management_menu
                ;;
            *Cleanup*)
                cleanup_images_menu
                ;;
            *Back*)
                return
                ;;
        esac
    done
}

### Main Menu Functions ###

list_images_menu() {
    while true; do
        clear
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ LIST IMAGES ▓▓${RESET}"

        local list_options=(
            "🔄 List All Images"
            "🏃 List Running Images"
            "💤 List Dangling Images"
            "⬅ Back"
        )

        choose_from_menu "Select listing option:" list_option "${list_options[@]}"

        case $list_option in
            *All*)
                show_all_images
                ;;
            *Running*)
                show_running_images
                ;;
            *Dangling*)
                show_dangling_images
                ;;
            *Back*)
                return
                ;;
        esac
    done
}

search_images_menu() {
    echo "Search functionality will be implemented here"
    read -n 1 -s -r -p "Press any key to continue..."
}

show_image_stats() {
    while true; do
        clear
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ IMAGE STATISTICS ▓▓${RESET}"

        # 1. DADOS BÁSICOS DO SISTEMA
        echo -e "\n${CYBER_BLUE}▓▓ UTILIZAÇÃO DO SISTEMA ▓▓${RESET}"

        # Cabeçalho da tabela
        printf "${CYBER_WHITE}%-15s %-10s %-15s %-15s${RESET}\n" "TIPO" "QTD" "TAMANHO" "RECLAIMABLE"

        # Dados da tabela com cores
        $cmd_docker system df --format "{{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}" | while IFS=$'\t' read -r type count size reclaim; do
            # Define cores baseadas no tipo
            local color=""
            case "$type" in
                Images*) color="${CYBER_YELLOW}" ;;
                Containers*) color="${CYBER_CYAN}" ;;
                Local\ Volumes*) color="${CYBER_PURPLE}" ;;
                *) color="${CYBER_WHITE}" ;;
            esac

            # Formata cada linha
            printf "${color}%-15s %-10s %-15s %-15s${RESET}\n" "$type" "$count" "$size" "$reclaim"
        done

        # 2. ESTATÍSTICAS DAS IMAGENS
        echo -e "\n${CYBER_BLUE}▓▓ ESTATÍSTICAS DAS IMAGENS ▓▓${RESET}"

        # Número total de imagens
        local image_count=$($cmd_docker images -q | wc -l | tr -d '[:space:]')
        echo -e "📦 ${CYBER_YELLOW}Total de imagens:${RESET} ${CYBER_CYAN}$image_count${RESET}"

        # Imagens pendentes
        local dangling_count=$($cmd_docker images -f "dangling=true" -q | wc -l | tr -d '[:space:]')
        echo -e "🧹 ${CYBER_YELLOW}Imagens pendentes:${RESET} ${CYBER_CYAN}$dangling_count${RESET}"

        # Imagens não utilizadas (método mais confiável)
        local unused_count=$($cmd_docker images --format "{{.Repository}}" | grep -v "<none>" | sort -u | wc -l | tr -d '[:space:]')
        echo -e "🗑️  ${CYBER_YELLOW}Imagens não utilizadas:${RESET} ${CYBER_CYAN}$unused_count${RESET}"

        # 3. VISUALIZAÇÃO GRÁFICA (VERSÃO ROBUSTA)
        echo -e "\n${CYBER_BLUE}▓▓ VISUALIZAÇÃO DE USO ▓▓${RESET}"

        # Extrai a porcentagem reclaimable de forma segura
        local reclaim_pct=$($cmd_docker system df --format '{{.Reclaimable}}' | head -1 | grep -oE '^[0-9]+' || echo "0")

        # Garante que é um número válido entre 0-100
        if ! [[ "$reclaim_pct" =~ ^[0-9]+$ ]]; then
            reclaim_pct=0
        fi
        if (( reclaim_pct > 100 )); then
            reclaim_pct=100
        fi

        local used_pct=$((100 - reclaim_pct))

        # Barra de progresso
        echo -n "["
        for ((i=0; i<50; i++)); do
            if [ $i -lt $((used_pct/2)) ]; then
                echo -ne "${CYBER_RED}▓${RESET}"
            else
                echo -ne "${CYBER_GREEN}▓${RESET}"
            fi
        done
        echo -e "] ${used_pct}% usado | ${reclaim_pct}% reclaimable"

        # 4. MENU DE AÇÕES AVANÇADAS
        echo -e "\n${CYBER_PURPLE}▓▓ AÇÕES AVANÇADAS ▓▓${RESET}"
        local options=(
            "🧹 Limpar imagens pendentes"
            "🗑️  Remover imagens não utilizadas"
            "📊 Gerar relatório completo"
            "📉 Análise de histórico"
            "⬅ Voltar"
        )

        choose_from_menu "Selecione uma ação:" action "${options[@]}"

        case $action in
            *pendentes*)
                echo -e "${CYBER_YELLOW}Removendo imagens pendentes...${RESET}"
                $cmd_docker image prune -f
                date "+%Y-%m-%d %H:%M:%S - Limpeza de imagens pendentes" >> ~/.docker_clean_history
                ;;
            *utilizadas*)
                echo -e "${CYBER_YELLOW}Removendo imagens não utilizadas...${RESET}"
                $cmd_docker image prune -a --force
                date "+%Y-%m-%d %H:%M:%S - Limpeza de imagens não utilizadas" >> ~/.docker_clean_history
                ;;
            *relatório*)
                generate_image_report
                ;;
            *histórico*)
                show_image_history
                ;;
            *Voltar*)
                return
                ;;
        esac

        # Atualiza a tela após cada ação (exceto Voltar)
        [[ "$action" != *Voltar* ]] && sleep 1
    done
}

# Função para gerar relatório completo
generate_image_report() {
    local report_file="/tmp/docker_image_report_$(date +%Y%m%d_%H%M%S).txt"

    {
        echo "=== RELATÓRIO COMPLETO DE IMAGENS DOCKER ==="
        echo "Data: $(date)"
        echo "============================================"

        # 1. Status do sistema
        echo -e "\n[STATUS DO SISTEMA]"
        $cmd_docker system df --format "table {{.Type}}\t{{.TotalCount}}\t{{.Size}}\t{{.Reclaimable}}" | column -t -s $'\t'

        # 2. Lista de imagens
        echo -e "\n[LISTA DE IMAGENS]"
        $cmd_docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}" | column -t -s $'\t'

        # 3. Imagens não utilizadas
        echo -e "\n[IMAGENS NÃO UTILIZADAS]"
        $cmd_docker images --filter "dangling=true" --format "table {{.ID}}\t{{.Size}}\t{{.CreatedSince}}" | column -t -s $'\t'

        # 4. Containers ativos
        echo -e "\n[CONTAINERS ATIVOS]"
        $cmd_docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | column -t -s $'\t'

    } > "$report_file"

    echo -e "${CYBER_GREEN}Relatório gerado em: ${CYBER_CYAN}$report_file${RESET}"
    less "$report_file"
}

# Função para mostrar histórico
show_image_history() {
    echo -e "\n${CYBER_BLUE}▓▓ HISTÓRICO DE USO ▓▓${RESET}"

    # Histórico de tamanho das imagens
    echo -e "📅 ${CYBER_YELLOW}Últimas 5 medições de tamanho:${RESET}"
    $cmd_docker images --format "{{.Size}}" | head -5 | nl -s ". "

    # Histórico de limpezas
    echo -e "\n🧹 ${CYBER_YELLOW}Últimas limpezas realizadas:${RESET}"
    if [ -f ~/.docker_clean_history ]; then
        tail -5 ~/.docker_clean_history | nl -s ". "
    else
        echo "Nenhum histórico encontrado"
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

create_image_menu() {
    while true; do
        clear
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ CRIAR NOVA IMAGEM DOCKER ▓▓${RESET}"

        # Opções de criação
        local options=(
            "🛠️  Criar a partir de Dockerfile"
            "📦 Criar a partir de container existente"
            "🔍 Importar de arquivo tar"
            "⬅ Voltar"
        )

        choose_from_menu "Selecione o método de criação:" creation_method "${options[@]}"

        case $creation_method in
            *Dockerfile*)
                create_from_dockerfile
                ;;
            *container*)
                create_from_container
                ;;
            *Importar*)
                import_from_tar
                ;;
            *Voltar*)
                return
                ;;
        esac
    done
}

create_from_dockerfile() {
    echo -e "\n${CYBER_BLUE}▓▓ CRIAR IMAGEM A PARTIR DE DOCKERFILE ▓▓${RESET}"

    # 1. Selecionar diretório do Dockerfile
    read -e -p "Digite o caminho do diretório com Dockerfile: " dockerfile_dir
    dockerfile_dir="${dockerfile_dir/#~/$HOME}"  # Expande ~ para $HOME

    if [ ! -f "$dockerfile_dir/Dockerfile" ]; then
        echo -e "${CYBER_RED}Erro: Dockerfile não encontrado no diretório especificado${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return
    fi

    # 2. Definir nome e tag
    read -p "Nome para a imagem (ex: minha-imagem): " image_name
    read -p "Tag (ex: latest): " image_tag
    image_tag="${image_tag:-latest}"  # Default para 'latest'

    # 3. Opções de build
    local build_opts=()
    if confirm "Usar cache na construção?"; then
        build_opts+=("--no-cache=false")
    else
        build_opts+=("--no-cache=true")
    fi

    if confirm "Remover containers intermediários após build?"; then
        build_opts+=("--rm=true")
    fi

    # 4. Executar build
    echo -e "\n${CYBER_YELLOW}Construindo imagem...${RESET}"
    if $cmd_docker build -t "${image_name}:${image_tag}" "${build_opts[@]}" "$dockerfile_dir"; then
        echo -e "\n${CYBER_GREEN}✔ Imagem construída com sucesso!${RESET}"
        echo -e "Nome: ${CYBER_CYAN}${image_name}:${image_tag}${RESET}"
        echo -e "Tamanho: ${CYBER_CYAN}$($cmd_docker images --format "{{.Size}}" "${image_name}:${image_tag}")${RESET}"
    else
        echo -e "\n${CYBER_RED}✖ Falha ao construir imagem${RESET}"
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

create_from_container() {
    echo -e "\n${CYBER_BLUE}▓▓ CRIAR IMAGEM A PARTIR DE CONTAINER ▓▓${RESET}"

    # Listar containers em execução
    echo -e "${CYBER_YELLOW}Containers disponíveis:${RESET}"
    $cmd_docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}" | head -6

    # Selecionar container
    read -p "Digite o ID ou nome do container: " container_id
    read -p "Nome para a nova imagem (ex: minha-imagem): " image_name
    read -p "Tag (ex: latest): " image_tag
    image_tag="${image_tag:-latest}"

    # Criar commit
    echo -e "\n${CYBER_YELLOW}Criando imagem...${RESET}"
    if $cmd_docker commit "$container_id" "${image_name}:${image_tag}"; then
        echo -e "\n${CYBER_GREEN}✔ Imagem criada com sucesso!${RESET}"
        echo -e "Nome: ${CYBER_CYAN}${image_name}:${image_tag}${RESET}"
    else
        echo -e "\n${CYBER_RED}✖ Falha ao criar imagem${RESET}"
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

import_from_tar() {
    echo -e "\n${CYBER_BLUE}▓▓ IMPORTAR IMAGEM DE ARQUIVO TAR ▓▓${RESET}"

    # Selecionar arquivo
    read -e -p "Digite o caminho do arquivo .tar: " tar_file
    tar_file="${tar_file/#~/$HOME}"

    if [ ! -f "$tar_file" ]; then
        echo -e "${CYBER_RED}Erro: Arquivo não encontrado${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return
    fi

    # Importar imagem
    echo -e "\n${CYBER_YELLOW}Importando imagem...${RESET}"
    if $cmd_docker load -i "$tar_file"; then
        echo -e "\n${CYBER_GREEN}✔ Imagem importada com sucesso!${RESET}"
    else
        echo -e "\n${CYBER_RED}✖ Falha ao importar imagem${RESET}"
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

# Função auxiliar para confirmações
confirm() {
    local prompt="$1 [y/N] "
    read -p "$prompt" -n 1 -r
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Função para processar comandos de imagens
handle_image_command() {
    local subcommand="$1"
    shift

    case "$subcommand" in
        "list"|"ls")
            show_all_images
            ;;
        "pull"|"p")
            if [ -z "$1" ]; then
                echo -e "${CYBER_RED}Erro: Especifique uma imagem para pull${RESET}"
                echo -e "Exemplo: ${CYBER_CYAN}bytebabe docker images pull nginx${RESET}"
                return 1
            fi
            $cmd_docker pull "$1"
            ;;
        "search"|"s")
            if [ -z "$1" ]; then
                echo -e "${CYBER_RED}Erro: Especifique um termo para busca${RESET}"
                echo -e "Exemplo: ${CYBER_CYAN}bytebabe docker images search nginx${RESET}"
                return 1
            fi
            $cmd_docker search "$1"
            ;;
        "prune"|"clean")
            echo -e "${CYBER_YELLOW}Removendo imagens não utilizadas...${RESET}"
            $cmd_docker image prune -a --force
            ;;
        "stats"|"stat")
            show_image_stats
            ;;
        *)
            echo -e "${CYBER_YELLOW}⚡ ${CYBER_BLUE}IMAGE COMMANDS:${RESET}"
            echo -e "  ${CYBER_GREEN}list${RESET}, ${CYBER_GREEN}ls${RESET}       List all images"
            echo -e "  ${CYBER_GREEN}pull${RESET}, ${CYBER_GREEN}p${RESET}        Pull an image"
            echo -e "  ${CYBER_GREEN}search${RESET}, ${CYBER_GREEN}s${RESET}      Search for images"
            echo -e "  ${CYBER_GREEN}prune${RESET}, ${CYBER_GREEN}clean${RESET}   Remove unused images"
            echo -e "  ${CYBER_GREEN}stats${RESET}, ${CYBER_GREEN}stat${RESET}    Show image statistics"
            ;;
    esac
}

pull_management_menu() {
    while true; do
        clear
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ GESTÃO DE PULL DE IMAGENS ▓▓${RESET}"

        # Opções principais
        local options=(
            "📥 Puxar imagem específica"
            "🔄 Verificar atualizações"
            "📋 Listar imagens disponíveis"
            "⚙️  Configurar registry"
            "⬅ Voltar"
        )

        choose_from_menu "Selecione uma ação:" action "${options[@]}"

        case $action in
            *Puxar*)
                pull_specific_image
                ;;
            *Verificar*)
                check_for_updates
                ;;
            *Listar*)
                list_available_images
                ;;
            *Configurar*)
                configure_registry
                ;;
            *Voltar*)
                return
                ;;
        esac
    done
}

pull_specific_image() {
    echo -e "\n${CYBER_BLUE}▓▓ PUXAR IMAGEM ESPECÍFICA ▓▓${RESET}"

    # Autocomplete para imagens conhecidas
    echo -e "${CYBER_YELLOW}Exemplos:${RESET}"
    echo -e "  • ubuntu:22.04"
    echo -e "  • nginx:latest"
    echo -e "  • postgres:13-alpine"
    echo -e "  • mcr.microsoft.com/vscode/devcontainers/base:ubuntu"

    read -p "Digite o nome completo da imagem (repo/nome:tag): " image_name

    if [[ -z "$image_name" ]]; then
        echo -e "${CYBER_RED}Nome da imagem não pode ser vazio${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return
    fi

    echo -e "\n${CYBER_YELLOW}Iniciando pull de ${CYBER_CYAN}$image_name${CYBER_YELLOW}...${RESET}"

    # Opções avançadas
    local pull_opts=()
    if confirm "Deseja puxar todas as tags para esta imagem?"; then
        pull_opts+=("--all-tags")
    fi

    if confirm "Deseja desativar a saída detalhada?"; then
        pull_opts+=("--quiet")
    fi

    # Executar pull
    if $cmd_docker pull "${pull_opts[@]}" "$image_name"; then
        echo -e "\n${CYBER_GREEN}✔ Pull concluído com sucesso!${RESET}"
        show_image_details "$image_name"
    else
        echo -e "\n${CYBER_RED}✖ Falha ao puxar imagem${RESET}"
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

check_for_updates() {
    echo -e "\n${CYBER_BLUE}▓▓ VERIFICAR ATUALIZAÇÕES ▓▓${RESET}"

    # Listar imagens locais
    echo -e "${CYBER_YELLOW}Imagens locais:${RESET}"
    $cmd_docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedSince}}" | head -6

    read -p "Digite o nome da imagem para verificar (deixe em branco para todas): " image_name

    echo -e "\n${CYBER_YELLOW}Verificando atualizações...${RESET}"

    if [[ -z "$image_name" ]]; then
        # Verificar todas as imagens
        $cmd_docker images --format "{{.Repository}}:{{.Tag}}" | while read -r img; do
            check_single_image "$img"
        done
    else
        # Verificar imagem específica
        check_single_image "$image_name"
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

check_single_image() {
    local image=$1
    echo -e "\n🔍 ${CYBER_CYAN}Verificando ${image}...${RESET}"

    # Obter digest local
    local local_digest=$($cmd_docker inspect --format='{{.RepoDigests}}' "$image" 2>/dev/null)

    # Fazer pull --quiet para obter digest remoto sem baixar
    $cmd_docker pull --quiet "$image" > /dev/null 2>&1
    local remote_digest=$($cmd_docker inspect --format='{{.RepoDigests}}' "$image" 2>/dev/null)

    if [[ "$local_digest" != "$remote_digest" ]]; then
        echo -e "  ${CYBER_YELLOW}⚠ Atualização disponível!${RESET}"
        echo -e "  Local:  ${local_digest}"
        echo -e "  Remoto: ${remote_digest}"
    else
        echo -e "  ${CYBER_GREEN}✓ Está atualizada${RESET}"
    fi
}

list_available_images() {
    echo -e "\n${CYBER_BLUE}▓▓ IMAGENS DISPONÍVEIS NO REGISTRY ▓▓${RESET}"

    read -p "Digite o nome do repositório (ex: library/ubuntu): " repo_name

    if [[ -z "$repo_name" ]]; then
        repo_name="library"
    fi

    echo -e "\n${CYBER_YELLOW}Buscando tags para ${CYBER_CYAN}${repo_name}${CYBER_YELLOW}...${RESET}"

    # Usar skopeo se disponível para listar tags
    if command -v skopeo &> /dev/null; then
        skopeo list-tags "docker://$repo_name" | jq -r '.Tags[]' | sort | column
    else
        echo -e "${CYBER_RED}skopeo não instalado. Instale para listagem completa.${RESET}"
        echo -e "${CYBER_YELLOW}Mostrando apenas tags locais...${RESET}"
        $cmd_docker images "$repo_name/*" --format "{{.Repository}}:{{.Tag}}" | sort | column
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

configure_registry() {
    echo -e "\n${CYBER_BLUE}▓▓ CONFIGURAR REGISTRY ▓▓${RESET}"

    echo -e "${CYBER_YELLOW}Configuração atual:${RESET}"
    $cmd_docker info --format '{{json .RegistryConfig}}' | jq

    local options=(
        "🔒 Adicionar registry privado"
        "🗑️ Remover registry"
        "🔧 Configurar credenciais"
        "⬅ Voltar"
    )

    choose_from_menu "Selecione uma ação:" config_action "${options[@]}"

    case $config_action in
        *Adicionar*)
            read -p "Nome do registry (ex: registry.meudominio.com): " reg_name
            read -p "Endereço (ex: https://registry.meudominio.com/v2/): " reg_url

            if [[ -n "$reg_name" && -n "$reg_url" ]]; then
                if ! grep -q "$reg_name" /etc/docker/daemon.json 2>/dev/null; then
                    echo -e "${CYBER_YELLOW}Adicionando registry...${RESET}"
                    sudo mkdir -p /etc/docker
                    sudo jq --arg name "$reg_name" --arg url "$reg_url" \
                        '. += {"insecure-registries": [$name], "registry-mirrors": [$url]}' \
                        /etc/docker/daemon.json | sudo tee /etc/docker/daemon.json >/dev/null
                    echo -e "${CYBER_GREEN}✓ Registry adicionado${RESET}"
                    echo -e "${CYBER_YELLOW}Reinicie o Docker para aplicar as mudanças${RESET}"
                else
                    echo -e "${CYBER_RED}Registry já existe${RESET}"
                fi
            else
                echo -e "${CYBER_RED}Nome e endereço são obrigatórios${RESET}"
            fi
            ;;
        *Remover*)
            echo -e "\n${CYBER_YELLOW}Registries atuais:${RESET}"
            $cmd_docker info --format '{{.RegistryConfig.InsecureRegistryCIDRs}}'

            read -p "Digite o nome do registry para remover: " reg_name
            if [[ -n "$reg_name" ]]; then
                sudo jq --arg name "$reg_name" \
                    'del(.insecure-registries[] | select(. == $name))' \
                    /etc/docker/daemon.json | sudo tee /etc/docker/daemon.json >/dev/null
                echo -e "${CYBER_GREEN}✓ Registry removido${RESET}"
            fi
            ;;
        *Credenciais*)
            read -p "Nome do registry (ex: registry.meudominio.com): " reg_name
            read -p "Usuário: " reg_user
            read -s -p "Senha: " reg_pass
            echo

            if [[ -n "$reg_name" && -n "$reg_user" && -n "$reg_pass" ]]; then
                echo -e "${CYBER_YELLOW}Configurando credenciais...${RESET}"
                $cmd_docker login -u "$reg_user" -p "$reg_pass" "$reg_name"
                echo -e "${CYBER_GREEN}✓ Credenciais configuradas${RESET}"
            else
                echo -e "${CYBER_RED}Todos os campos são obrigatórios${RESET}"
            fi
            ;;
    esac

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

show_image_details() {
    local image=$1
    echo -e "\n${CYBER_BLUE}▓▓ DETALHES DA IMAGEM ▓▓${RESET}"

    $cmd_docker inspect "$image" | jq -r '.[0] | {
        "Nome": .RepoTags[0],
        "ID": .Id,
        "Criada": .Created,
        "Tamanho": .Size,
        "Arquitetura": .Architecture,
        "Sistema": .Os,
        "Digest": .RepoDigests[0]
    }' | jq
}



select_docker_option() {
    local prompt="$1" outvar="$2"
    shift
    shift
    local options=("$@") cur=0 count=${#options[@]} index=0
    local key

    if [ $count -eq 0 ]; then
        echo -e "${CYBER_RED}Nenhuma opção disponível${RESET}"
        return 1
    fi

    echo -e "${BOLD}${CYBER_PURPLE}$prompt${RESET}"

    while true; do
        # Imprime todas as opções
        for index in $(seq 0 $((count-1))); do
            if [ $index -eq $cur ]; then
                echo -e "${CYBER_GREEN} > ${CYBER_CYAN}${BOLD}${options[index]}${RESET}"
            else
                echo -e "   ${CYBER_YELLOW}${options[index]}${RESET}"
            fi
        done

        # Lê apenas 1 caractere no modo silencioso
        read -rsn1 key

        # Se for uma sequência de escape (setas), lê mais 2 caracteres
        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 -t 0.1 key
        fi

        case "$key" in
            '[A')  # Seta para cima
                ((cur--))
                ;;
            '[B')  # Seta para baixo
                ((cur++))
                ;;
            '')  # Enter - confirma seleção
                break
                ;;
            [1-9])  # Seleção por número
                if ((key <= count)); then
                    ((cur=key-1))
                    break
                fi
                ;;
            q|Q)  # Tecla Q para sair
                return 1
                ;;
        esac

        # Ajusta os limites do cursor
        ((cur = (cur < 0) ? 0 : (cur >= count) ? count-1 : cur))

        # Move o cursor para reescrever o menu
        printf "\033[%dA" "$count"
    done

    # Retorna a seleção
    printf -v "$outvar" "%s" "${options[cur]}"
}


push_management_menu() {
    while true; do
        clear
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ GESTÃO DE PUSH DE IMAGENS ▓▓${RESET}"

        local options=(
            "🚀 Push Direto"
            "🏷️ Tag e Push"
            "📜 Listar Tags"
            "🔄 Sincronizar"
            "🔐 Login Registry"
            "⬅ Voltar"
        )

        select_docker_option "Selecione uma ação:" selected_action "${options[@]}"

        case "$selected_action" in
            *Direto*)
                push_direct
                ;;
            *Tag\ e\ Push*)
                tag_and_push
                ;;
            *Listar\ Tags*)
                list_remote_tags
                ;;
            *Sincronizar*)
                sync_with_registry
                ;;
            *Login*)
                registry_login
                ;;
            *Voltar*)
                return
                ;;
        esac
    done
}

# Função para autenticação em registry
registry_login() {
    echo -e "\n${CYBER_BLUE}▓▓ AUTENTICAÇÃO NO REGISTRY ▓▓${RESET}"

    read -p "Endereço do registry (ex: registry.example.com): " registry
    read -p "Usuário: " username
    read -s -p "Senha: " password
    echo

    if [[ -z "$registry" || -z "$username" ]]; then
        echo -e "${CYBER_RED}Registry e usuário são obrigatórios${RESET}"
    else
        echo -e "\n${CYBER_YELLOW}Efetuando login...${RESET}"
        if echo "$password" | $cmd_docker login -u "$username" --password-stdin "$registry"; then
            echo -e "${CYBER_GREEN}✓ Login bem-sucedido!${RESET}"
        else
            echo -e "${CYBER_RED}✖ Falha no login${RESET}"
        fi
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}


# Função melhorada para push direto
push_direct() {
    echo -e "\n${CYBER_BLUE}▓▓ PUSH DIRETO ▓▓${RESET}"

    # Lista imagens com formatação colorida
    echo -e "${CYBER_YELLOW}Imagens locais disponíveis:${RESET}"
    $cmd_docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}" |
    awk -v c1=${CYBER_CYAN} -v c2=${CYBER_WHITE} -v r=${RESET} '
    BEGIN {printf "%s%-12s %-30s %-15s %-10s%s\n", c2, "ID", "REPOSITÓRIO", "TAG", "TAMANHO", r}
    {printf "%s%-12s %s%-30s%s %s%-15s%s %s%-10s%s\n", c1, $1, c2, $2, r, c1, $3, r, c2, $4, r}' |
    head -10

    read -p "Digite o ID ou nome da imagem: " image_id
    read -p "Digite o destino (registry/repo:tag): " destination

    if [[ -z "$image_id" || -z "$destination" ]]; then
        echo -e "${CYBER_RED}ID da imagem e destino são obrigatórios${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return
    fi

    # Verifica se a imagem existe
    if ! $cmd_docker inspect "$image_id" &>/dev/null; then
        echo -e "${CYBER_RED}Imagem não encontrada!${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return
    fi

    # Confirmação
    if ! confirm "Confirmar push de '${image_id}' para '${destination}'?"; then
        echo -e "${CYBER_YELLOW}Push cancelado${RESET}"
        return
    fi

    # Processo de tag e push
    echo -e "\n${CYBER_YELLOW}1. Aplicando tag...${RESET}"
    if $cmd_docker tag "$image_id" "$destination"; then
        echo -e "${CYBER_GREEN}✓ Tag aplicada${RESET}"
    else
        echo -e "${CYBER_RED}✖ Falha ao aplicar tag${RESET}"
        return
    fi

    echo -e "\n${CYBER_YELLOW}2. Enviando imagem...${RESET}"
    if $cmd_docker push "$destination"; then
        echo -e "\n${CYBER_GREEN}✓ Push concluído com sucesso!${RESET}"

        # Opção de limpar tag
        if confirm "Deseja remover a tag temporária?"; then
            $cmd_docker rmi "$destination"
            echo -e "${CYBER_GREEN}✓ Tag removida${RESET}"
        fi
    else
        echo -e "\n${CYBER_RED}✖ Falha no push${RESET}"
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

tag_and_push() {
    echo -e "\n${CYBER_BLUE}▓▓ TAG E PUSH DE IMAGEM ▓▓${RESET}"

    # Lista imagens locais com formatação colorida
    echo -e "${CYBER_YELLOW}Imagens locais disponíveis:${RESET}"
    $cmd_docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" |
    awk -v c1=${CYBER_CYAN} -v c2=${CYBER_WHITE} -v r=${RESET} '
    BEGIN {printf "%s%-30s %-20s %-10s%s\n", c2, "REPOSITÓRIO", "TAG", "TAMANHO", r}
    {printf "%s%-30s %s%-20s%s %s%-10s%s\n", c1, $1, c2, $2, r, c1, $3, r}' |
    head -10

    # Captura inputs do usuário
    read -p "Digite o nome da imagem local (ex: minha-imagem:tag): " source_image
    read -p "Digite o novo nome completo (ex: registry.com/user/repo:tag): " target_image

    # Validações
    if [[ -z "$source_image" || -z "$target_image" ]]; then
        echo -e "${CYBER_RED}Erro: Nomes de imagem são obrigatórios${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return 1
    fi

    if ! $cmd_docker inspect "$source_image" &>/dev/null; then
        echo -e "${CYBER_RED}Erro: Imagem local não encontrada${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return 1
    fi

    # Confirmação
    if ! confirm "Confirmar operação?\n  De: ${CYBER_CYAN}$source_image${RESET}\n  Para: ${CYBER_GREEN}$target_image${RESET}"; then
        echo -e "${CYBER_YELLOW}Operação cancelada${RESET}"
        return
    fi

    # Processo de tag
    echo -e "\n${CYBER_YELLOW}1. Aplicando tag...${RESET}"
    if $cmd_docker tag "$source_image" "$target_image"; then
        echo -e "${CYBER_GREEN}✓ Tag aplicada com sucesso${RESET}"
    else
        echo -e "${CYBER_RED}✖ Falha ao aplicar tag${RESET}"
        return 1
    fi

    # Processo de push
    echo -e "\n${CYBER_YELLOW}2. Enviando imagem...${RESET}"
    if $cmd_docker push "$target_image"; then
        echo -e "\n${CYBER_GREEN}✓ Push concluído com sucesso!${RESET}"

        # Limpeza opcional
        if confirm "Deseja remover a tag temporária?"; then
            $cmd_docker rmi "$target_image"
            echo -e "${CYBER_GREEN}✓ Tag removida${RESET}"
        fi
    else
        echo -e "\n${CYBER_RED}✖ Falha no push${RESET}"
        return 1
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

list_remote_tags() {
    echo -e "\n${CYBER_BLUE}▓▓ LISTAR TAGS REMOTAS ▓▓${RESET}"

    # Mostra exemplos
    echo -e "${CYBER_YELLOW}Exemplos de repositórios:${RESET}"
    echo -e "  • library/nginx"
    echo -e "  • ubuntu"
    echo -e "  • seu-user/meu-repositorio"

    read -p "Digite o nome do repositório: " repository

    if [[ -z "$repository" ]]; then
        echo -e "${CYBER_RED}Erro: Nome do repositório é obrigatório${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return 1
    fi

    # Verifica se é um registry customizado
    if [[ "$repository" == *.* ]]; then
        local registry="${repository%%/*}"
        echo -e "${CYBER_YELLOW}Consultando registry customizado...${RESET}"

        if ! curl -sSL "https://$registry/v2/" &>/dev/null; then
            echo -e "${CYBER_RED}Erro: Registry inacessível ou não suportado${RESET}"
            read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
            return 1
        fi

        # Usa API v2 para registry customizado
        echo -e "\n${CYBER_GREEN}Tags disponíveis em ${CYBER_CYAN}$repository${CYBER_GREEN}:${RESET}"
        curl -sSL "https://$registry/v2/$repository/tags/list" | jq -r '.tags[]' 2>/dev/null ||
        echo -e "${CYBER_RED}Não foi possível listar as tags (API não suportada)${RESET}"
    else
        # Usa Docker Hub para repositórios padrão
        echo -e "\n${CYBER_YELLOW}Consultando Docker Hub...${RESET}"

        # Tentativa com API v2
        local tags=$(curl -sSL "https://registry.hub.docker.com/v2/repositories/$repository/tags/?page_size=10" | jq -r '.results[].name' 2>/dev/null)

        if [[ -n "$tags" ]]; then
            echo -e "\n${CYBER_GREEN}Últimas 10 tags em ${CYBER_CYAN}$repository${CYBER_GREEN}:${RESET}"
            echo "$tags" | column
        else
            # Fallback para API v1
            echo -e "${CYBER_YELLOW}Tentando API mais antiga...${RESET}"
            curl -sSL "https://registry.hub.docker.com/v1/repositories/$repository/tags" | jq -r '.[].name' | column ||
            echo -e "${CYBER_RED}Não foi possível listar as tags${RESET}"
        fi
    fi

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}


sync_with_registry() {
    echo -e "\n${CYBER_BLUE}▓▓ SINCRONIZAR COM REGISTRY ▓▓${RESET}"

    # Lista imagens locais
    echo -e "${CYBER_YELLOW}Imagens locais disponíveis:${RESET}"
    $cmd_docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | head -10

    # Captura inputs
    read -p "Digite o nome da imagem local (ex: minha-imagem:tag): " local_image
    read -p "Digite o destino no registry (ex: registry.com/user/repo:tag): " remote_image

    # Validações
    if [[ -z "$local_image" || -z "$remote_image" ]]; then
        echo -e "${CYBER_RED}Erro: Nomes de imagem são obrigatórios${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return 1
    fi

    if ! $cmd_docker inspect "$local_image" &>/dev/null; then
        echo -e "${CYBER_RED}Erro: Imagem local não encontrada${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return 1
    fi

    # Confirmação
    if ! confirm "Confirmar sincronização?\n  Local: ${CYBER_CYAN}$local_image${RESET}\n  Remoto: ${CYBER_GREEN}$remote_image${RESET}"; then
        echo -e "${CYBER_YELLOW}Operação cancelada${RESET}"
        return
    fi

    # Fluxo completo
    echo -e "\n${CYBER_YELLOW}1. Aplicando tag...${RESET}"
    $cmd_docker tag "$local_image" "$remote_image" || {
        echo -e "${CYBER_RED}✖ Falha ao aplicar tag${RESET}"
        return 1
    }

    echo -e "\n${CYBER_YELLOW}2. Enviando imagem...${RESET}"
    $cmd_docker push "$remote_image" || {
        echo -e "${CYBER_RED}✖ Falha no push${RESET}"
        return 1
    }

    echo -e "\n${CYBER_YELLOW}3. Limpando tag local...${RESET}"
    $cmd_docker rmi "$remote_image" || {
        echo -e "${CYBER_YELLOW}⚠ Aviso: Não foi possível remover a tag local${RESET}"
    }

    echo -e "\n${CYBER_GREEN}✓ Sincronização completa!${RESET}"
    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

cleanup_images_menu() {
    while true; do
        clear
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ CYBER CLEANER v2.0 ▓▓${RESET}"
        echo -e "${CYBER_BLUE}System Status:${RESET} $(sudo docker system df | grep Images | awk '{print $4}') used"

        local actions=(
            "🧹 Purge Dangling Images"
            "💥 Full System Scrub"
            "⏳ Time-Based Purge (>30d)"
            "📊 Storage Diagnostics"
            "🔙 Return to Mainframe"
        )

        choose_from_menu "Select cleanup action:" action "${actions[@]}"

        case $action in
            *Dangling*)
                echo -e "\n${CYBER_CYAN}[ INITIATING DANGLING PURGE ]${RESET}"
                sudo docker image prune -f | while read -r line; do
                    echo -e "${CYBER_GRAY}⌁ $line${RESET}"
                done
                ;;
            *Scrub*)
                echo -e "\n${CYBER_CYAN}[ INITIATING FULL SYSTEM SCRUB ]${RESET}"
                sudo docker system prune -a -f | while read -r line; do
                    echo -e "${CYBER_GRAY}⌁ $line${RESET}"
                done
                ;;
            *Time-Based*)
                echo -e "\n${CYBER_CYAN}[ INITIATING CHRONO-PURGE ]${RESET}"
                sudo docker image prune -a -f --filter "until=720h" | while read -r line; do
                    echo -e "${CYBER_GRAY}⌁ $line${RESET}"
                done
                ;;
            *Diagnostics*)
                echo -e "\n${CYBER_CYAN}[ SYSTEM DIAGNOSTICS ]${RESET}"
                echo -e "${CYBER_GREEN}"
                sudo docker system df -v
                echo -e "${RESET}"
                ;;
            *Mainframe*)
                echo -e "${CYBER_RED}\n[ RETURNING TO MAINFRAME ]${RESET}"
                return
                ;;
        esac

        if [[ "$action" != *Mainframe* ]]; then
            echo -e "\n${CYBER_CYAN}[ OPERATION COMPLETE ]${RESET}"
            echo -e "${CYBER_GREEN}"
            sudo docker system df
            echo -e "${RESET}"
            read -n 1 -s -r -p "${CYBER_GRAY}⌁ Press any key to continue...${RESET}"
        fi
    done
}



search_images_menu() {
    while true; do
        clear
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ PESQUISA DE IMAGENS DOCKER ▓▓${RESET}"

        local options=(
            "🔍 Pesquisar por nome"
            "📂 Buscar por categoria"
            "⬅ Voltar"
        )

        choose_from_menu "Selecione o tipo de pesquisa:" search_type "${options[@]}"

        case $search_type in
            *nome*)
                search_by_name
                ;;
            *categoria*)
                search_by_category
                ;;
            *Voltar*)
                return
                ;;
        esac
    done
}

search_by_name() {
    echo -e "\n${CYBER_BLUE}▓▓ PESQUISA POR NOME ▓▓${RESET}"
    read -p "Digite o termo de pesquisa (ex: nginx, postgres): " search_term

    if [[ -z "$search_term" ]]; then
        echo -e "${CYBER_RED}Termo de pesquisa não pode ser vazio${RESET}"
        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
        return
    fi

    echo -e "\n${CYBER_YELLOW}Procurando por '${CYBER_CYAN}$search_term${CYBER_YELLOW}'...${RESET}"

    # Formatação personalizada sem dependências externas
    {
        echo -e "${CYBER_WHITE}--------------------------------------------------------------------------------"
        printf "%-40s %-50s %-8s %-10s\n" "NOME" "DESCRIÇÃO" "ESTRELAS" "OFICIAL"
        echo -e "--------------------------------------------------------------------------------${RESET}"

        $cmd_docker search --format "{{.Name}}\t{{.Description}}\t{{.StarCount}}\t{{.IsOfficial}}" "$search_term" | while IFS=$'\t' read -r name desc stars official; do
            # Trunca descrição se for muito longa
            desc="${desc:0:50}"
            [[ ${#desc} -eq 50 ]] && desc="${desc}..."

            # Formata estrelas
            if [[ $stars -gt 1000 ]]; then
                stars="${CYBER_YELLOW}${stars}★${RESET}"
            else
                stars="${CYBER_WHITE}${stars}★${RESET}"
            fi

            # Formata flag oficial
            if [[ "$official" == "[OK]" ]]; then
                official="${CYBER_GREEN}✔${RESET}"
            else
                official="${CYBER_RED}✖${RESET}"
            fi

            printf "%-40s %-50s %-8b %-10b\n" "$name" "$desc" "$stars" "$official"
        done

        echo -e "${CYBER_WHITE}--------------------------------------------------------------------------------${RESET}"
    } | tee /dev/tty | grep -q . || echo -e "${CYBER_YELLOW}Nenhum resultado encontrado.${RESET}"

    read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
}

search_by_category() {
    while true; do
        clear
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ CATEGORIAS DE IMAGENS ▓▓${RESET}"

        # Categorias pré-definidas com exemplos (armazenadas como string)
        local categories=(
            "1) 🌐 Servidores Web|nginx apache httpd tomcat"
            "2) 🛢️ Bancos de Dados|mysql postgres mongo redis"
            "3) 💻 Sistemas Operacionais|ubuntu alpine debian centos"
            "4) 🛠️ Ferramentas de Desenvolvimento|node python golang"
            "5) 📊 Monitoramento|grafana prometheus influxdb"
            "6) 🔒 Segurança|vault owasp/zap sonarqube"
            "7) 🧪 CI/CD|jenkins gitlab-runner drone"
            "8) ⬅ Voltar"
        )

        # Mostrar menu de categorias
        for category in "${categories[@]}"; do
            IFS='|' read -r title terms <<< "$category"
            echo -e "${CYBER_CYAN}$title${RESET}"
        done

        read -p "Selecione uma categoria (1-8): " category_choice

        case $category_choice in
            1|2|3|4|5|6|7)
                IFS='|' read -r category_title search_terms <<< "${categories[$((category_choice-1))]}"
                echo -e "\n${CYBER_BLUE}▓▓ $category_title ▓▓${RESET}"

                for term in $search_terms; do
                    echo -e "\n${CYBER_YELLOW}▶ ${term^^}${RESET}"
                    $cmd_docker search --format "table {{.Name}}\t{{.Description}}\t{{.StarCount}}" "$term" | head -5
                done
                ;;
            8)
                return
                ;;
            *)
                echo -e "${CYBER_RED}Opção inválida!${RESET}"
                ;;
        esac

        read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
    done
}



### Image Listing Functions ###

show_all_images() {
    while true; do
        clear
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ ALL IMAGES ▓▓${RESET}"

        local images=()
        while IFS= read -r line; do
            images+=("$line")
        done < <($cmd_docker images --format "{{.Repository}}:{{.Tag}} ({{.Size}})" 2>/dev/null | sort)

        if [ ${#images[@]} -eq 0 ]; then
            echo -e "${CYBER_YELLOW}No Docker images found${RESET}"
            read -n 1 -s -r -p "Press any key to continue..."
            return
        fi

        choose_from_menu "Select an image:" selected_image "${images[@]}" "⬅ Back"

        [[ "$selected_image" == "⬅ Back" ]] && return

        local image_name=$(echo "$selected_image" | awk -F'[: ]' '{print $1":"$2}')
        show_image_actions "$image_name"
    done
}

show_running_images() {
    echo -e "${CYBER_BLUE}▓▓ RUNNING IMAGES ▓▓${RESET}"
    $cmd_docker ps --format "table {{.Image}}\t{{.Names}}\t{{.Status}}" | column -t
    read -n 1 -s -r -p "Press any key to continue..."
}

show_dangling_images() {
    echo -e "${CYBER_BLUE}▓▓ DANGLING IMAGES ▓▓${RESET}"
    $cmd_docker images -f "dangling=true" --format "table {{.ID}}\t{{.CreatedSince}}\t{{.Size}}" | column -t
    read -n 1 -s -r -p "Press any key to continue..."
}

### Image Actions ###

show_image_actions() {
    local image=$1

    while true; do
        clear
        show_docker_header
        echo -e "${CYBER_PURPLE}▓▓ IMAGE ACTIONS ▓▓${RESET}"
        echo -e "Selected: ${CYBER_CYAN}$image${RESET}"

        local actions=(
            "🔍 Inspect Image"
            "🚀 Run Container"
            "🏷️ Tag Image"
            "📤 Push Image"
            "📥 Pull Image"
            "🗑️ Remove Image"
            "⬅ Back"
        )

        choose_from_menu "Select action:" action "${actions[@]}"

        case $action in
            *Inspect*)
                inspect_image "$image"
                ;;
            *Run*)
                run_image "$image"
                ;;
            *Tag*)
                tag_image "$image"
                ;;
            *Push*)
                push_image "$image"
                ;;
            *Pull*)
                pull_image "$image"
                ;;
            *Remove*)
                remove_image "$image"
                ;;
            *Back*)
                return
                ;;
        esac

        [[ "$action" != *Back* ]] && read -n 1 -s -r -p "Press any key to continue..."
    done
}

### Image Operations ###

inspect_image() {
    echo "Inspecting image: $1"
    $cmd_docker inspect "$1" | less
}

run_image() {
    echo "Running image: $1"
    read -p "Enter container name (optional): " name
    read -p "Enter ports to expose (e.g., 8080:80): " ports
    read -p "Enter volume mounts (e.g., /local:/container): " volumes

    local cmd="$cmd_docker run -d"
    [ -n "$name" ] && cmd+=" --name $name"
    [ -n "$ports" ] && cmd+=" -p $ports"
    [ -n "$volumes" ] && cmd+=" -v $volumes"
    cmd+=" $1"

    echo -e "${CYBER_BLUE}Executing:${RESET} ${CYBER_CYAN}$cmd${RESET}"
    eval "$cmd"
}

tag_image() {
    echo "Tagging image: $1"
    read -p "Enter new tag (e.g., myrepo/image:newtag): " newtag
    $cmd_docker tag "$1" "$newtag"
    echo -e "${CYBER_GREEN}Image tagged as: $newtag${RESET}"
}

push_image() {
    echo "Pushing image: $1"
    $cmd_docker push "$1"
}

pull_image() {
    echo "Pulling image: $1"
    $cmd_docker pull "$1"
}

remove_image() {
    echo -e "${CYBER_RED}Warning: This will remove the image${RESET}"
    read -p "Are you sure? (y/N): " confirm
    if [[ "$confirm" =~ [yY] ]]; then
        $cmd_docker rmi "$1"
    else
        echo -e "${CYBER_YELLOW}Image removal canceled${RESET}"
    fi
}

### CLI Argument Handler ###

handle_image_args() {
    case "$1" in
        --list|-l)
            $cmd_docker images
            ;;
        --prune|-p)
            echo -e "${CYBER_YELLOW}Removing dangling images...${RESET}"
            $cmd_docker image prune -f
            ;;
        --help|-h)
            show_image_help
            ;;
        *)
            echo -e "${CYBER_RED}Invalid option: $1${RESET}"
            show_image_help
            return 1
            ;;
    esac
}

show_image_help() {
    echo -e "${CYBER_CYAN}📦 Image Harbor Help 📦${RESET}"
    echo -e "\n${CYBER_YELLOW}Usage:"
    echo -e "  bytebabe docker images [options]"
    echo -e "\nOptions:"
    echo -e "  --list, -l    List all images"
    echo -e "  --prune, -p   Remove dangling images"
    echo -e "  --help, -h    Show this help"
    echo -e "\nInteractive mode:"
    echo -e "  bytebabe docker images${RESET}"
    echo -e "\n${CYBER_GREEN}Examples:"
    echo -e "  bytebabe docker images --list"
    echo -e "  bytebabe docker images --prune${RESET}"
}