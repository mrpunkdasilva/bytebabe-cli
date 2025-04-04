#!/bin/bash

# Cores Cyberpunk
CYBER_PURPLE='\033[38;5;93m'
CYBER_GREEN='\033[38;5;118m'
CYBER_RED='\033[38;5;196m'
CYBER_BLUE='\033[38;5;45m'
CYBER_YELLOW='\033[38;5;227m'
NC='\033[0m'

# Efeitos
FLASH="\033[5m"
BOLD="\033[1m"
RESET="\033[0m"

# ASCII Art Header
show_header() {
  clear
  echo -e "${CYBER_PURPLE}"
  echo -e " █▄▄ █▀█ █▀▀ █▄▀ █▀▀ █▀█ ▄▀█ █▀▀ █▀▀ ▀█▀"
  echo -e " █▄█ █▄█ █▄▄ █░█ ██▄ █▀▄ █▀█ █▄▄ ██▄ ░█░"
  echo -e "${CYBER_BLUE}"
  echo -e "╔════════════════════════════════════════╗"
  echo -e "║   ${CYBER_PURPLE}⚡ ${CYBER_YELLOW}DATA ARCHIVAL v3.0 ${CYBER_BLUE}⚡   ║"
  echo -e "╚════════════════════════════════════════╝${NC}"
  echo
}

# Mostra uso
show_help() {
  echo -e "\n${CYBER_YELLOW}${BOLD}USAGE:${RESET}"
  echo -e "  ${CYBER_GREEN}backup create ${CYBER_BLUE}<source> <destination>"
  echo -e "  ${CYBER_GREEN}backup restore ${CYBER_BLUE}<backup_file> <target>"
  echo -e "  ${CYBER_GREEN}backup list${NC}"
  echo -e "\n${CYBER_YELLOW}${BOLD}EXAMPLES:${RESET}"
  echo -e "  ${CYBER_BLUE}backup create /home/user /mnt/backup"
  echo -e "  ${CYBER_BLUE}backup restore backup_2023.tar.gz /home/user${NC}"
}

# Cria backup
create_backup() {
  local source=$1
  local destination=$2
  local backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"

  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_BLUE}⌛ INITIATING DATA ARCHIVAL SEQUENCE...${NC}"

  if tar -czf "${destination}/${backup_name}" -C "$(dirname "$source")" "$(basename "$source")"; then
    echo -e "\n${CYBER_GREEN}✅ BACKUP SUCCESSFUL!${NC}"
    echo -e "${CYBER_YELLOW}📦 Archive: ${CYBER_BLUE}${destination}/${backup_name}${NC}"
    echo -e "${CYBER_YELLOW}💾 Size: ${CYBER_BLUE}$(du -h "${destination}/${backup_name}" | cut -f1)${NC}"
  else
    echo -e "\n${CYBER_RED}${FLASH}❌ BACKUP FAILED!${NC}${RESET}"
    echo -e "${CYBER_YELLOW}Possible reasons:"
    echo -e " - Source directory doesn't exist"
    echo -e " - No write permissions in destination"
    echo -e " - Not enough disk space${NC}"
  fi

  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Restaura backup
restore_backup() {
  local backup_file=$1
  local target=$2

  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_BLUE}⌛ INITIATING DATA RECOVERY SEQUENCE...${NC}"

  if [ ! -f "$backup_file" ]; then
    echo -e "\n${CYBER_RED}${FLASH}❌ BACKUP FILE NOT FOUND!${NC}${RESET}"
    echo -e "${CYBER_YELLOW}Please verify the path: ${CYBER_BLUE}${backup_file}${NC}"
    return 1
  fi

  if tar -xzf "$backup_file" -C "$target"; then
    echo -e "\n${CYBER_GREEN}✅ RESTORE COMPLETE!${NC}"
    echo -e "${CYBER_YELLOW}🔍 Contents restored to: ${CYBER_BLUE}${target}${NC}"
  else
    echo -e "\n${CYBER_RED}${FLASH}❌ RESTORE FAILED!${NC}${RESET}"
    echo -e "${CYBER_YELLOW}Possible reasons:"
    echo -e " - Invalid backup file"
    echo -e " - No write permissions in target"
    echo -e " - Not enough disk space${NC}"
  fi

  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Lista backups
list_backups() {
  local dir=${1:-.}

  echo -e "\n${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
  echo -e "${CYBER_BLUE}📂 BACKUP ARCHIVES IN: ${CYBER_YELLOW}$(realpath "$dir")${NC}\n"

  find "$dir" -name "backup_*.tar.gz" -printf "%f\t%s\t%Tb %Td %TY %TH:%TM\n" 2>/dev/null | \
  while read -r name size date; do
    printf "${CYBER_GREEN}%-30s ${CYBER_BLUE}%10s ${CYBER_YELLOW}%s${NC}\n" "$name" "$(numfmt --to=iec-i --suffix=B "$size")" "$date"
  done

  echo -e "${CYBER_PURPLE}${BOLD}▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓${NC}"
}

# Função principal
run_backup() {
  show_header

  case "$1" in
    create)
      if [ $# -lt 3 ]; then
        echo -e "${CYBER_RED}${FLASH}❌ MISSING ARGUMENTS!${NC}${RESET}"
        show_help
        return 1
      fi
      create_backup "$2" "$3"
      ;;
    restore)
      if [ $# -lt 3 ]; then
        echo -e "${CYBER_RED}${FLASH}❌ MISSING ARGUMENTS!${NC}${RESET}"
        show_help
        return 1
      fi
      restore_backup "$2" "$3"
      ;;
    list)
      list_backups "${2:-.}"
      ;;
    *)
      show_help
      ;;
  esac
}

# Se executado diretamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_backup "$@"
else
  show_help
fi