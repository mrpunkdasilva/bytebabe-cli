#!/bin/bash

source ../core/colors.sh

show_cyberpunk_header() {
    clear
    echo -e "${CYBER_PINK}"
    cat <<"EOF"

888888b.          888           888888b.          888              
888  "88b         888           888  "88b         888              
888  .88P         888           888  .88P         888              
8888888K. 888  888888888 .d88b. 8888888K.  8888b. 88888b.  .d88b.  
888  "Y88b888  888888   d8P  Y8b888  "Y88b    "88b888 "88bd8P  Y8b 
888    888888  888888   88888888888    888.d888888888  88888888888 
888   d88PY88b 888Y88b. Y8b.    888   d88P888  888888 d88PY8b.     
8888888P"  "Y88888 "Y888 "Y8888 8888888P" "Y88888888888P"  "Y8888  
               888                                                 
          Y8b d88P                                                 
           "Y88P"                                                  


EOF
    echo -e "${CYBER_BLUE}"
    cat <<"EOF"
                           ╱|、
                          (˚ˎ 。7  
                           |、˜〵          
                           じしˍ,)ノ
EOF
    echo -e "${RESET}"
}

show_section_header() {
    local title=$1
    echo -e "\n${CYBER_PINK}⚡ ${title} ⚡${RESET}"
}
