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

push_management_menu() {
    echo "Push management functionality will be implemented here"
    read -n 1 -s -r -p "Press any key to continue..."
}

cleanup_images_menu() {
    echo "Cleanup functionality will be implemented here"
    read -n 1 -s -r -p "Press any key to continue..."
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