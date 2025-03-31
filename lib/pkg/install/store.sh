#!/bin/bash
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

show_store_header() {
  clear
  echo -e "${CYBER_PURPLE}┌─────────────────────────────────────────────────────┐${RESET}"
  echo -e "${CYBER_PURPLE}│  ${CYBER_GREEN} _    _           _   _       ${CYBER_BLUE} _____ _           ${CYBER_PURPLE}│${RESET}"
  echo -e "${CYBER_PURPLE}│  ${CYBER_GREEN}| |  | |         | | | |      ${CYBER_BLUE}/ ____| |          ${CYBER_PURPLE}│${RESET}"
  echo -e "${CYBER_PURPLE}│  ${CYBER_GREEN}| |__| | ___  ___| |_| |__   ${CYBER_BLUE} (___ | |_ ___ _ __ ${CYBER_PURPLE}│${RESET}"
  echo -e "${CYBER_PURPLE}│  ${CYBER_GREEN}|  __  |/ _ \/ __| __| '_ \   ${CYBER_BLUE}\___ \| __/ _ \ '__|${CYBER_PURPLE}│${RESET}"
  echo -e "${CYBER_PURPLE}│  ${CYBER_GREEN}| |  | |  __/\__ \ |_| |_) | ${CYBER_BLUE}____) | ||  __/ |   ${CYBER_PURPLE}│${RESET}"
  echo -e "${CYBER_PURPLE}│  ${CYBER_GREEN}|_|  |_|\___||___/\__|_.__/  ${CYBER_BLUE}_____/ \__\___|_|   ${CYBER_PURPLE}│${RESET}"
  echo -e "${CYBER_PURPLE}├─────────────────────────────────────────────────────┤${RESET}"
  echo -e "${CYBER_PURPLE}│${RESET} ${CYBER_CYAN}» Version: Neon-2.3.5 ${CYBER_PURPLE}»${RESET} ${CYBER_PINK}User: ${USER} ${CYBER_PURPLE}│${RESET}"
  echo -e "${CYBER_PURPLE}└─────────────────────────────────────────────────────┘${RESET}"
}

show_app_card() {
  local id=$1
  local name=$2
  local ver=$3
  local size=$4
  local desc=$5

  echo -e "${CYBER_PURPLE}┌───────┬────────────────────────────────────────────┐${RESET}"
  echo -e "${CYBER_PURPLE}│ ${CYBER_GREEN}ID:${RESET}   ${CYBER_CYAN}#${id}${RESET} ${CYBER_PURPLE}│ ${CYBER_GREEN}${name} ${CYBER_YELLOW}v${ver} ${CYBER_PINK}[${size}]${RESET}       ${CYBER_PURPLE}│${RESET}"
  echo -e "${CYBER_PURPLE}├───────┴────────────────────────────────────────────┤${RESET}"
  echo -e "${CYBER_PURPLE}│ ${CYBER_BLUE}» ${desc}${RESET}"
  echo -e "${CYBER_PURPLE}├───────────────────────────────────────────────────┤${RESET}"
  echo -e "${CYBER_PURPLE}│ ${CYBER_GREEN}[I] Install ${CYBER_PURPLE}│ ${CYBER_YELLOW}[D] Details ${CYBER_PURPLE}│ ${CYBER_PINK}[S] Screenshot ${CYBER_PURPLE}│ ${CYBER_RED}[B] Back ${CYBER_PURPLE}│${RESET}"
  echo -e "${CYBER_PURPLE}└───────────────────────────────────────────────────┘${RESET}"
}

show_category_menu() {
  echo -e "\n${CYBER_BLUE}» Categories:${RESET}"
  echo -e "${CYBER_PURPLE} 1) ${CYBER_GREEN}System Tools${RESET}    ${CYBER_PURPLE}4) ${CYBER_GREEN}Multimedia${RESET}"
  echo -e "${CYBER_PURPLE} 2) ${CYBER_GREEN}Development${RESET}     ${CYBER_PURPLE}5) ${CYBER_GREEN}Games${RESET}"
  echo -e "${CYBER_PURPLE} 3) ${CYBER_GREEN}Productivity${RESET}    ${CYBER_PURPLE}6) ${CYBER_GREEN}Cyberware${RESET}"
  echo -e "${CYBER_PURPLE} 0) ${CYBER_RED}Return${RESET}"
}

browse_store() {
  while true; do
    show_store_header

    # Mock data
    declare -A apps=(
      ["1"]="NeonTerm|1.2.3|15MB|Cyberpunk terminal emulator with glitch effects"
      ["2"]="ByteMonitor|0.9.5|8MB|System monitor with matrix visualization"
      ["3"]="CyberVim|2.1.0|5MB|Vim mod with neon themes and hacker shortcuts"
    )

    echo -e "\n${CYBER_BLUE}» Featured Cyberware:${RESET}"

    for id in "${!apps[@]}"; do
      IFS='|' read -r name ver size desc <<< "${apps[$id]}"
      show_app_card "$id" "$name" "$ver" "$size" "$desc"
    done

    show_category_menu

    echo -e "\n${CYBER_YELLOW}» Navigation: ${CYBER_PURPLE}[1-${#apps[@]}] Select app ${CYBER_PURPLE}| ${CYBER_GREEN}[C] Categories ${CYBER_PURPLE}| ${CYBER_RED}[Q] Quit${RESET}"
    read -p " ${CYBER_BLUE}»»${RESET} " choice

    case $choice in
      [1-9])
        if [[ -n "${apps[$choice]}" ]]; then
          IFS='|' read -r name ver size desc <<< "${apps[$choice]}"
          show_app_detail "$choice" "$name" "$ver" "$size" "$desc"
        fi
        ;;
      c|C) show_category_menu ;;
      q|Q) break ;;
      *) echo -e "${RED}Invalid option${RESET}" ;;
    esac

    sleep 1
  done
}

show_app_detail() {
  local id=$1 name=$2 ver=$3 size=$4 desc=$5

  while true; do
    show_store_header
    show_app_card "$id" "$name" "$ver" "$size" "$desc"

    echo -e "\n${CYBER_BLUE}» Additional Info:${RESET}"
    echo -e "${CYBER_PURPLE} ├─ ${CYBER_CYAN}Author: ${CYBER_GREEN}ByteBabe Collective${RESET}"
    echo -e "${CYBER_PURPLE} ├─ ${CYBER_CYAN}License: ${CYBER_GREEN}Open Source${RESET}"
    echo -e "${CYBER_PURPLE} └─ ${CYBER_CYAN}Compatibility: ${CYBER_PINK}Linux 5.0+${RESET}"

    read -p " ${CYBER_BLUE}»»${RESET} " choice

    case $choice in
      i|I)
        echo -e "${CYBER_GREEN}» Installing ${name}...${RESET}"
        sleep 2
        echo -e "${CYBER_GREEN}✓ Installation complete!${RESET}"
        sleep 1
        break
        ;;
      b|B) break ;;
      *) echo -e "${RED}Invalid option${RESET}" ;;
    esac
  done
}

run_store() {
  ensure_flatpak || return 1
  browse_store
}