#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

# Carrega módulos Docker
source "${BASE_DIR}/lib/docker/ui.sh"
source "${BASE_DIR}/lib/docker/helpers.sh"
source "${BASE_DIR}/lib/docker/containers.sh"
source "${BASE_DIR}/lib/docker/images.sh"
source "${BASE_DIR}/lib/docker/volumes.sh"
source "${BASE_DIR}/lib/docker/compose.sh"
source "${BASE_DIR}/lib/docker/utils.sh"

# Função de ajuda melhorada
show_docker_help() {
    echo -e "${CYBER_PURPLE}"
    echo "  ╔════════════════════════════════════════════════════════════╗"
    echo "  ║  ▓▓▓ BYTEBABE DOCKER MANAGER - HELP ▓▓▓                   ║"
    echo "  ║                                                           ║"
    echo "  ║  ${CYBER_CYAN}Gerencie containers, imagens e volumes Docker${CYBER_PURPLE}         ║"
    echo "  ╚════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"

    echo -e "${BOLD}${CYBER_GREEN}USO:${RESET}"
    echo -e "  bytebabe docker ${CYBER_YELLOW}[comando] [opções]${RESET}"
    echo

    echo -e "${BOLD}${CYBER_GREEN}COMANDOS DISPONÍVEIS:${RESET}"
    echo -e "  ${CYBER_GREEN}containers${RESET}    🐳  Gerenciar containers (start/stop/restart)"
    echo -e "  ${CYBER_GREEN}images${RESET}       📦  Gerenciar imagens Docker"
    echo -e "  ${CYBER_GREEN}volumes${RESET}      💾  Gerenciar volumes de dados"
    echo -e "  ${CYBER_GREEN}compose${RESET}      🚢  Gerenciar stacks Docker Compose"
    echo -e "  ${CYBER_GREEN}clean${RESET}        🧹  Limpar recursos não utilizados"
    echo -e "  ${CYBER_GREEN}stats${RESET}        📊  Monitorar recursos em tempo real"
    echo -e "  ${CYBER_GREEN}help${RESET}         ❓  Mostrar esta ajuda"
    echo

    echo -e "${BOLD}${CYBER_GREEN}EXEMPLOS:${RESET}"
    echo -e "  ${CYBER_YELLOW}bytebabe docker containers${RESET}        # Menu interativo de containers"
    echo -e "  ${CYBER_YELLOW}bytebabe docker images --prune${RESET}   # Remover imagens não utilizadas"
    echo -e "  ${CYBER_YELLOW}bytebabe docker compose up${RESET}       # Iniciar serviços compose"
    echo -e "  ${CYBER_YELLOW}bytebabe docker stats${RESET}           # Monitorar recursos"
    echo

    echo -e "${BOLD}${CYBER_GREEN}DICAS:${RESET}"
    echo -e "  ${CYBER_BLUE}•${RESET} Use ${CYBER_YELLOW}TAB${RESET} para autocompletar comandos"
    echo -e "  ${CYBER_BLUE}•${RESET} Pressione ${CYBER_YELLOW}Ctrl+C${RESET} para sair de telas de monitoramento"
    echo -e "  ${CYBER_BLUE}•${RESET} Adicione ${CYBER_YELLOW}--help${RESET} a qualquer comando para ajuda específica"
    echo -e "  ${CYBER_BLUE}•${RESET} Comandos destrutivos pedirão confirmação"
}

# Verifica se Docker está instalado e rodando
check_docker_daemon

# Processa subcomandos
case $1 in
    containers|cont*)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            echo -e "${CYBER_PURPLE}CONTAINER COMMANDER HELP${RESET}"
            echo -e "Gerenciamento interativo de containers Docker"
            echo -e "Opções disponíveis:"
            echo -e "  ${CYBER_YELLOW}--all${RESET}      Mostrar todos containers (incluindo parados)"
            echo -e "  ${CYBER_YELLOW}--filter${RESET}   Filtrar por status (running, exited, etc)"
            echo -e "Exemplo: ${CYBER_YELLOW}bytebabe docker containers --filter running${RESET}"
        else
            container_commander "${@:2}"
        fi
        ;;
    images|img*)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            echo -e "${CYBER_PURPLE}IMAGE HARBOR HELP${RESET}"
            echo -e "Gerenciamento de imagens Docker"
            echo -e "Opções disponíveis:"
            echo -e "  ${CYBER_YELLOW}--prune${RESET}    Remover imagens não utilizadas"
            echo -e "  ${CYBER_YELLOW}--all${RESET}      Listar todas imagens (incluindo intermediárias)"
            echo -e "Exemplo: ${CYBER_YELLOW}bytebabe docker images --prune${RESET}"
        else
            image_harbor "${@:2}"
        fi
        ;;
    volumes|vol*)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            echo -e "${CYBER_PURPLE}VOLUME BAY HELP${RESET}"
            echo -e "Gerenciamento de volumes Docker"
            echo -e "Opções disponíveis:"
            echo -e "  ${CYBER_YELLOW}--prune${RESET}    Remover volumes não utilizados"
            echo -e "  ${CYBER_YELLOW}--size${RESET}     Mostrar uso de espaço"
            echo -e "Exemplo: ${CYBER_YELLOW}bytebabe docker volumes --prune${RESET}"
        else
            volume_bay "${@:2}"
        fi
        ;;
    compose|comp*)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            echo -e "${CYBER_PURPLE}COMPOSE CAPTAIN HELP${RESET}"
            echo -e "Gerenciamento de Docker Compose"
            echo -e "Subcomandos disponíveis:"
            echo -e "  ${CYBER_YELLOW}up${RESET}       Iniciar serviços"
            echo -e "  ${CYBER_YELLOW}down${RESET}     Parar serviços"
            echo -e "  ${CYBER_YELLOW}logs${RESET}     Ver logs"
            echo -e "Exemplo: ${CYBER_YELLOW}bytebabe docker compose up${RESET}"
        else
            compose_captain "${@:2}"
        fi
        ;;
    clean|cls*)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            echo -e "${CYBER_PURPLE}SYSTEM CLEANER HELP${RESET}"
            echo -e "Limpeza de recursos Docker"
            echo -e "Opções disponíveis:"
            echo -e "  ${CYBER_YELLOW}--all${RESET}      Limpar tudo (containers, imagens, volumes)"
            echo -e "  ${CYBER_YELLOW}--images${RESET}   Limpar apenas imagens"
            echo -e "Exemplo: ${CYBER_YELLOW}bytebabe docker clean --all${RESET}"
        else
            system_cleaner "${@:2}"
        fi
        ;;
    stats|stat*)
        if [[ "$2" == "--help" || "$2" == "-h" ]]; then
            echo -e "${CYBER_PURPLE}DOCKER STATS HELP${RESET}"
            echo -e "Monitoramento de recursos Docker"
            echo -e "Opções disponíveis:"
            echo -e "  ${CYBER_YELLOW}--live${RESET}    Monitoramento contínuo (padrão)"
            echo -e "  ${CYBER_YELLOW}--snap${RESET}    Captura única"
            echo -e "Exemplo: ${CYBER_YELLOW}bytebabe docker stats --snap${RESET}"
        else
            docker_stats "${@:2}"
        fi
        ;;
    help|-h|--help|"")
        show_docker_help
        ;;
    *)
        echo -e "${CYBER_RED}Comando desconhecido: $1${RESET}"
        echo
        show_docker_help
        exit 1
        ;;
esac