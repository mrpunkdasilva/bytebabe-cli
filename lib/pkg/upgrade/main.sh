#!/bin/bash
source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

# Error display function
show_error() {
  echo -e "${RED}✖ Error: $1${RESET}" >&2
}

# Easter egg phrases
EASTER_EGGS=(
  "Updating like it's 1999... 📼"
  "01010100 01101000 01100101 00100000 01100010 01111001 01110100 01100101 01110011 00100000 01100001 01110010 01100101 00100000 01100001 01101100 01101001 01110110 01100101 00100001 🔥"
  "Loading cybernetic enhancements... ⚡"
  "ByteBabe is working her magic... ✨"
  "Hacking the mainframe... 💻"
  "Resistance is futile... 🖖"
  "All your packages are belong to us! 🎮"
  "Stay frosty! ❄️"
  "Upgrade in progress... or is it? 🕵️‍♀️"
  "Initiate sequence: Overdrive... 🚀"
  "01000010 01111001 01110100 01100101 01000010 01100001 01100010 01100101 00100000 01110010 01110101 01101100 01100101 01110011 00100001"
)

# Random loading spinner
spinner() {
  local pid=$!
  local delay=0.1
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

# Random Easter egg printer
print_easter_egg() {
  local egg=${EASTER_EGGS[$RANDOM % ${#EASTER_EGGS[@]}]}
  echo -e "${CYBER_PURPLE}${egg}${RESET}"
}

detect_pkg_manager() {
  # 15% chance to show an Easter egg
  if [ $((RANDOM % 7)) -eq 0 ]; then
    print_easter_egg
  fi

  if command -v apt &>/dev/null; then
    echo "apt"
  elif command -v dnf &>/dev/null; then
    echo "dnf"
  elif command -v yum &>/dev/null; then
    echo "yum"
  elif command -v pacman &>/dev/null; then
    echo "pacman"
  else
    echo "unknown"
  fi
}

  # Updates all packages using the detected package manager.
  #
  # This function uses a random Easter egg when updating packages.
  # It also shows a random success message when the update is complete.
  # There is a 5% chance to show a special message after the update.
  #
run_upgrade() {
  echo -e "${CYBER_BLUE}» Checking for updates...${RESET}"

  # Show loading spinner in background
  (sleep 2.5) & spinner

  pkg_manager=$(detect_pkg_manager)

  # Special message for pacman users
  if [ "$pkg_manager" == "pacman" ]; then
    echo -e "${CYBER_YELLOW}Arch user detected! ${CYBER_PINK}BTW...${RESET}"
  fi

  case $pkg_manager in
    apt)
      echo -e "${CYBER_CYAN}Using APT package manager${RESET}"
      sudo apt update && sudo apt upgrade -y
      ;;
    dnf|yum)
      echo -e "${CYBER_CYAN}Using ${pkg_manager^^} package manager${RESET}"
      sudo $pkg_manager upgrade -y
      ;;
    pacman)
      echo -e "${CYBER_CYAN}Using Pacman package manager${RESET}"
      sudo pacman -Syu --noconfirm
      ;;
    *)
      show_error "Unsupported package manager"
      # 50% chance to show encouragement when unsupported package manager
      if [ $((RANDOM % 2)) -eq 0 ]; then
        echo -e "${CYBER_PINK}But don't worry, you're still awesome! 😎${RESET}"
      fi
      return 1
      ;;
  esac

  # Random success message
  SUCCESS_MSGS=(
    "${CYBER_GREEN}✓ Update completed${RESET}"
    "${CYBER_GREEN}✓ System boosted!${RESET}"
    "${CYBER_GREEN}✓ Upgrade successful!${RESET}"
    "${CYBER_GREEN}✓ Ready to hack the planet!${RESET}"
    "${CYBER_GREEN}✓ System at maximum power!${RESET}"
    "${CYBER_GREEN}✓ All systems go!${RESET}"
    "${CYBER_GREEN}✓ Update sequence complete${RESET}"
  )
  echo -e "${SUCCESS_MSGS[$RANDOM % ${#SUCCESS_MSGS[@]}]}"

  # 5% chance to show a special message
  if [ $((RANDOM % 20)) -eq 0 ]; then
    echo -e "${CYBER_PINK}💖 ByteBabe loves you! 💖${RESET}"
    echo -e "${CYBER_BLUE}   Have a byte-tastic day! 🚀${RESET}"
  fi
}