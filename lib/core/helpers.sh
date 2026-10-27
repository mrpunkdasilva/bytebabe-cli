#!/bin/bash

# Fachada compatível do core. As implementações canônicas de paths, pacotes,
# feedback, menu e UI vivem nos módulos carregados abaixo.

if [[ -n "${_BYTEBABE_CORE_HELPERS_LOADED:-}" ]]; then
    return 0
fi
_BYTEBABE_CORE_HELPERS_LOADED=1

if [[ "${BASH_SOURCE[0]}" == */* ]]; then
    _bytebabe_core_dir="${BASH_SOURCE[0]%/*}"
else
    _bytebabe_core_dir="."
fi
_bytebabe_core_dir="$(cd -P -- "$_bytebabe_core_dir" && pwd)"

if [ -z "${BASE_DIR:-}" ]; then
    BASE_DIR="$(cd -P -- "$_bytebabe_core_dir/../.." && pwd)"
fi

source "$_bytebabe_core_dir/colors.sh"
source "$_bytebabe_core_dir/paths.sh"
source "$_bytebabe_core_dir/pkg.sh"
source "$_bytebabe_core_dir/feedback.sh"
source "$_bytebabe_core_dir/menu.sh"
source "$_bytebabe_core_dir/ui.sh"

unset _bytebabe_core_dir

# Verifica se é root
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${CYBER_ORANGE}⚠ Comando requer sudo!${RESET}"
        return 1
    fi
}

show_invalid_command_prime() {
  echo -e "${CYBER_RED}"
  cat << "EOF"
  ╔════════════════════════════════════════════╗
  ║      ▓▓▓ INVALID COMMAND DETECTED ▓▓▓      ║
  ╚════════════════════════════════════════════╝
EOF
  echo -e "${RESET}"

  echo -e "${CYBER_YELLOW}⚠️  Unknown command:${RESET} ${CYBER_RED}$1${RESET}"
  echo -e "${CYBER_BLUE}Available commands:${RESET}"

  echo -e "\n${CYBER_GREEN}🛠️  System Commands:${RESET}"
  echo -e "  ${CYBER_CYAN}upgrade    ${CYBER_GRAY}- ${CYBER_PURPLE}System upgrade${RESET}"
  echo -e "  ${CYBER_CYAN}install    ${CYBER_GRAY}- ${CYBER_PURPLE}Install packages${RESET}"
  echo -e "  ${CYBER_CYAN}remove     ${CYBER_GRAY}- ${CYBER_PURPLE}Remove packages${RESET}"

  echo -e "\n${CYBER_RED}🛡️  Security:${RESET}"
  echo -e "  ${CYBER_CYAN}scan       ${CYBER_GRAY}- ${CYBER_PURPLE}Security scan${RESET}"
  echo -e "  ${CYBER_CYAN}firewall   ${CYBER_GRAY}- ${CYBER_PURPLE}Firewall control${RESET}"

  echo -e "\n${CYBER_YELLOW}ℹ️  Try:${RESET}"
  echo -e "  ${CYBER_BLUE}prime help${RESET} for full documentation"
  echo -e "  ${CYBER_BLUE}prime upgrade${RESET} to start system update"

  echo -e "\n${CYBER_PURPLE}╰┈➤ ${CYBER_GRAY}Report bugs at: ${CYBER_CYAN}https://github.com/mrpunkdasilva/bytebabe${RESET}"
}
