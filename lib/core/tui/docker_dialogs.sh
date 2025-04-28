#!/bin/bash

# Dialog para gerenciamento de containers
show_container_menu() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Container Management ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 7 \
                       "1" "📋 List Containers" \
                       "2" "▶️ Start Container" \
                       "3" "⏹️ Stop Container" \
                       "4" "🔄 Restart Container" \
                       "5" "🗑️ Remove Container" \
                       "6" "📊 Container Stats" \
                       "7" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) list_containers_dialog ;;
            2) start_container_dialog ;;
            3) stop_container_dialog ;;
            4) restart_container_dialog ;;
            5) remove_container_dialog ;;
            6) show_container_stats_dialog ;;
            7) break ;;
            *) break ;;
        esac
    done
}

# Dialog para operações com imagens
show_image_menu() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Image Operations ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 6 \
                       "1" "📋 List Images" \
                       "2" "⬇️ Pull Image" \
                       "3" "⬆️ Push Image" \
                       "4" "🏗️ Build Image" \
                       "5" "🗑️ Remove Image" \
                       "6" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) list_images_dialog ;;
            2) pull_image_dialog ;;
            3) push_image_dialog ;;
            4) build_image_dialog ;;
            5) remove_image_dialog ;;
            6) break ;;
            *) break ;;
        esac
    done
}

# Dialog para volumes
show_volume_menu() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Volume Control ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 5 \
                       "1" "📋 List Volumes" \
                       "2" "➕ Create Volume" \
                       "3" "🗑️ Remove Volume" \
                       "4" "🔍 Inspect Volume" \
                       "5" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) list_volumes_dialog ;;
            2) create_volume_dialog ;;
            3) remove_volume_dialog ;;
            4) inspect_volume_dialog ;;
            5) break ;;
            *) break ;;
        esac
    done
}

# Dialog para operações com Docker Compose
show_compose_menu() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Compose Operations ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 6 \
                       "1" "▶️ Start Stack" \
                       "2" "⏹️ Stop Stack" \
                       "3" "🔄 Restart Stack" \
                       "4" "📊 Stack Status" \
                       "5" "📝 Edit Compose File" \
                       "6" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) start_compose_stack_dialog ;;
            2) stop_compose_stack_dialog ;;
            3) restart_compose_stack_dialog ;;
            4) show_compose_status_dialog ;;
            5) edit_compose_file_dialog ;;
            6) break ;;
            *) break ;;
        esac
    done
}

# Dialog para limpeza do sistema
show_cleanup_menu() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ System Cleanup ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 5 \
                       "1" "🧹 Clean All" \
                       "2" "🗑️ Remove Unused Images" \
                       "3" "🗑️ Remove Unused Volumes" \
                       "4" "🗑️ Remove Unused Networks" \
                       "5" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) clean_all_dialog ;;
            2) remove_unused_images_dialog ;;
            3) remove_unused_volumes_dialog ;;
            4) remove_unused_networks_dialog ;;
            5) break ;;
            *) break ;;
        esac
    done
}

# Dialog para monitoramento
show_monitor_menu() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Resource Monitor ]" \
                       --menu "Select operation:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 4 \
                       "1" "📊 Container Stats" \
                       "2" "💾 Disk Usage" \
                       "3" "🔍 System Info" \
                       "4" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) show_container_stats_live_dialog ;;
            2) show_disk_usage_dialog ;;
            3) show_system_info_dialog ;;
            4) break ;;
            *) break ;;
        esac
    done
}

# Main Docker management dialog
show_docker_management_menu() {
    while true; do
        local choice
        
        choice=$(dialog --clear \
                       --backtitle "$DIALOG_BACKTITLE" \
                       --title "[ Docker Management ]" \
                       --menu "Select category:" \
                       $DIALOG_HEIGHT $DIALOG_WIDTH 7 \
                       "1" "📦 Container Management" \
                       "2" "🏷️ Image Operations" \
                       "3" "💾 Volume Control" \
                       "4" "🔄 Compose Operations" \
                       "5" "🧹 System Cleanup" \
                       "6" "📊 Resource Monitor" \
                       "7" "Back" \
                       2>&1 >/dev/tty)

        case $choice in
            1) show_container_menu ;;
            2) show_image_menu ;;
            3) show_volume_menu ;;
            4) show_compose_menu ;;
            5) show_cleanup_menu ;;
            6) show_monitor_menu ;;
            7) break ;;
            *) break ;;
        esac
    done
}

# Container Dialog Functions
list_containers_dialog() {
    local containers
    containers=$($cmd_docker ps -a --format "{{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}")
    
    if [ -z "$containers" ]; then
        dialog --title "Containers" \
               --msgbox "No containers found" 8 40
        return
    }

    dialog --title "Container List" \
           --textbox <(echo "$containers" | column -t -s $'\t') \
           $DIALOG_HEIGHT $DIALOG_WIDTH
}

start_container_dialog() {
    local containers
    containers=$($cmd_docker ps -a --filter "status=exited" --format "{{.Names}}")
    
    if [ -z "$containers" ]; then
        dialog --title "Start Container" \
               --msgbox "No stopped containers found" 8 40
        return
    }

    local container
    container=$(dialog --title "Start Container" \
                      --menu "Select container to start:" \
                      $DIALOG_HEIGHT $DIALOG_WIDTH 10 \
                      $(echo "$containers" | awk '{print NR, $0}') \
                      2>&1 >/dev/tty)

    if [ $? -eq 0 ]; then
        container_name=$(echo "$containers" | sed -n "${container}p")
        if $cmd_docker start "$container_name"; then
            dialog --title "Success" \
                   --msgbox "Container $container_name started successfully" 8 40
        else
            dialog --title "Error" \
                   --msgbox "Failed to start container $container_name" 8 40
        fi
    fi
}

stop_container_dialog() {
    local containers
    containers=$($cmd_docker ps --format "{{.Names}}")
    
    if [ -z "$containers" ]; then
        dialog --title "Stop Container" \
               --msgbox "No running containers found" 8 40
        return
    }

    local container
    container=$(dialog --title "Stop Container" \
                      --menu "Select container to stop:" \
                      $DIALOG_HEIGHT $DIALOG_WIDTH 10 \
                      $(echo "$containers" | awk '{print NR, $0}') \
                      2>&1 >/dev/tty)

    if [ $? -eq 0 ]; then
        container_name=$(echo "$containers" | sed -n "${container}p")
        if dialog --title "Confirm" \
                 --yesno "Are you sure you want to stop $container_name?" 8 40; then
            if $cmd_docker stop "$container_name"; then
                dialog --title "Success" \
                       --msgbox "Container $container_name stopped successfully" 8 40
            else
                dialog --title "Error" \
                       --msgbox "Failed to stop container $container_name" 8 40
            fi
        fi
    fi
}

restart_container_dialog() {
    local containers
    containers=$($cmd_docker ps --format "{{.Names}}")
    
    if [ -z "$containers" ]; then
        dialog --title "Restart Container" \
               --msgbox "No running containers found" 8 40
        return
    }

    local container
    container=$(dialog --title "Restart Container" \
                      --menu "Select container to restart:" \
                      $DIALOG_HEIGHT $DIALOG_WIDTH 10 \
                      $(echo "$containers" | awk '{print NR, $0}') \
                      2>&1 >/dev/tty)

    if [ $? -eq 0 ]; then
        container_name=$(echo "$containers" | sed -n "${container}p")
        if $cmd_docker restart "$container_name"; then
            dialog --title "Success" \
                   --msgbox "Container $container_name restarted successfully" 8 40
        else
            dialog --title "Error" \
                   --msgbox "Failed to restart container $container_name" 8 40
        fi
    fi
}

remove_container_dialog() {
    local containers
    containers=$($cmd_docker ps -a --format "{{.Names}}")
    
    if [ -z "$containers" ]; then
        dialog --title "Remove Container" \
               --msgbox "No containers found" 8 40
        return
    }

    local container
    container=$(dialog --title "Remove Container" \
                      --menu "Select container to remove:" \
                      $DIALOG_HEIGHT $DIALOG_WIDTH 10 \
                      $(echo "$containers" | awk '{print NR, $0}') \
                      2>&1 >/dev/tty)

    if [ $? -eq 0 ]; then
        container_name=$(echo "$containers" | sed -n "${container}p")
        if dialog --title "Confirm" \
                 --yesno "Are you sure you want to remove $container_name?" 8 40; then
            if $cmd_docker rm -f "$container_name"; then
                dialog --title "Success" \
                       --msgbox "Container $container_name removed successfully" 8 40
            else
                dialog --title "Error" \
                       --msgbox "Failed to remove container $container_name" 8 40
            fi
        fi
    fi
}

show_container_stats_dialog() {
    local containers
    containers=$($cmd_docker ps --format "{{.Names}}")
    
    if [ -z "$containers" ]; then
        dialog --title "Container Stats" \
               --msgbox "No running containers found" 8 40
        return
    }

    local container
    container=$(dialog --title "Container Stats" \
                      --menu "Select container to view stats:" \
                      $DIALOG_HEIGHT $DIALOG_WIDTH 10 \
                      $(echo "$containers" | awk '{print NR, $0}') \
                      2>&1 >/dev/tty)

    if [ $? -eq 0 ]; then
        container_name=$(echo "$containers" | sed -n "${container}p")
        dialog --title "Stats for $container_name" \
               --tailbox <($cmd_docker stats --no-stream "$container_name") \
               $DIALOG_HEIGHT $DIALOG_WIDTH
    fi
}

# Image Dialog Functions
list_images_dialog() {
    local images
    images=$($cmd_docker images --format "{{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.ID}}")
    
    if [ -z "$images" ]; then
        dialog --title "Images" \
               --msgbox "Nenhuma imagem encontrada" 8 40
        return
    }

    dialog --title "Lista de Imagens" \
           --textbox <(echo "$images" | column -t -s $'\t') \
           $DIALOG_HEIGHT $DIALOG_WIDTH
}

pull_image_dialog() {
    local image_name
    image_name=$(dialog --title "Pull Image" \
                       --inputbox "Digite o nome da imagem (ex: nginx:latest):" \
                       8 50 \
                       2>&1 >/dev/tty)

    if [ $? -eq 0 ] && [ ! -z "$image_name" ]; then
        dialog --title "Downloading" \
               --infobox "Baixando imagem $image_name...\nPor favor, aguarde..." 5 50
        
        if $cmd_docker pull "$image_name" > /dev/null 2>&1; then
            dialog --title "Sucesso" \
                   --msgbox "Imagem $image_name baixada com sucesso" 8 40
        else
            dialog --title "Erro" \
                   --msgbox "Falha ao baixar imagem $image_name" 8 40
        fi
    fi
}

push_image_dialog() {
    local images
    images=$($cmd_docker images --format "{{.Repository}}:{{.Tag}}")
    
    if [ -z "$images" ]; then
        dialog --title "Push Image" \
               --msgbox "Nenhuma imagem local encontrada" 8 40
        return
    }

    local image
    image=$(dialog --title "Push Image" \
                   --menu "Selecione a imagem para push:" \
                   $DIALOG_HEIGHT $DIALOG_WIDTH 10 \
                   $(echo "$images" | awk '{print NR, $0}') \
                   2>&1 >/dev/tty)

    if [ $? -eq 0 ]; then
        image_name=$(echo "$images" | sed -n "${image}p")
        dialog --title "Pushing" \
               --infobox "Fazendo push da imagem $image_name...\nPor favor, aguarde..." 5 50
        
        if $cmd_docker push "$image_name" > /dev/null 2>&1; then
            dialog --title "Sucesso" \
                   --msgbox "Push da imagem $image_name realizado com sucesso" 8 40
        else
            dialog --title "Erro" \
                   --msgbox "Falha ao fazer push da imagem $image_name" 8 40
        fi
    fi
}

build_image_dialog() {
    local dockerfile_path
    dockerfile_path=$(dialog --title "Build Image" \
                            --inputbox "Caminho do Dockerfile:" \
                            8 50 "./Dockerfile" \
                            2>&1 >/dev/tty)

    if [ $? -eq 0 ] && [ ! -z "$dockerfile_path" ]; then
        if [ ! -f "$dockerfile_path" ]; then
            dialog --title "Erro" \
                   --msgbox "Dockerfile não encontrado em: $dockerfile_path" 8 40
            return
        fi

        local tag
        tag=$(dialog --title "Build Image" \
                     --inputbox "Tag para a imagem (ex: myapp:latest):" \
                     8 50 \
                     2>&1 >/dev/tty)

        if [ $? -eq 0 ] && [ ! -z "$tag" ]; then
            dialog --title "Building" \
                   --infobox "Construindo imagem $tag...\nPor favor, aguarde..." 5 50
            
            if $cmd_docker build -t "$tag" -f "$dockerfile_path" . > /dev/null 2>&1; then
                dialog --title "Sucesso" \
                       --msgbox "Imagem $tag construída com sucesso" 8 40
            else
                dialog --title "Erro" \
                       --msgbox "Falha ao construir imagem $tag" 8 40
            fi
        fi
    fi
}

remove_image_dialog() {
    local images
    images=$($cmd_docker images --format "{{.Repository}}:{{.Tag}}\t{{.ID}}\t{{.Size}}")
    
    if [ -z "$images" ]; then
        dialog --title "Remove Image" \
               --msgbox "Nenhuma imagem encontrada" 8 40
        return
    }

    local image
    image=$(dialog --title "Remove Image" \
                   --menu "Selecione a imagem para remover:" \
                   $DIALOG_HEIGHT $DIALOG_WIDTH 10 \
                   $(echo "$images" | awk '{print NR, $0}') \
                   2>&1 >/dev/tty)

    if [ $? -eq 0 ]; then
        image_name=$(echo "$images" | sed -n "${image}p" | awk '{print $1}')
        if dialog --title "Confirmar" \
                 --yesno "Tem certeza que deseja remover $image_name?" 8 40; then
            if $cmd_docker rmi -f "$image_name" > /dev/null 2>&1; then
                dialog --title "Sucesso" \
                       --msgbox "Imagem $image_name removida com sucesso" 8 40
            else
                dialog --title "Erro" \
                       --msgbox "Falha ao remover imagem $image_name" 8 40
            fi
        fi
    fi
}
