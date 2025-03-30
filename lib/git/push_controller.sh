#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/ui.sh"

show_push_dashboard() {
    clear
    echo "${BOLD}${CYBER_PURPLE}${CYBER_CYAN}
    PPPPPP  UU   UU  SSSSS  HH   HH   CCCCC   OOOOO  NN   NN TTTTTTT RRRRRR   OOOOO  LL      LL      EEEEEEE RRRRRR  
    PP   PP UU   UU SS      HH   HH  CC    C OO   OO NNN  NN   TTT   RR   RR OO   OO LL      LL      EE      RR   RR 
    PPPPPP  UU   UU  SSSSS  HHHHHHH  CC      OO   OO NN N NN   TTT   RRRRRR  OO   OO LL      LL      EEEEE   RRRRRR  
    PP      UU   UU      SS HH   HH  CC    C OO   OO NN  NNN   TTT   RR  RR  OO   OO LL      LL      EE      RR  RR  
    PP       UUUUU   SSSSS  HH   HH   CCCCC   OOOO0  NN   NN   TTT   RR   RR  OOOO0  LLLLLLL LLLLLLL EEEEEEE RR   RR 
                                                                                                                     
    ${CYBER_PURPLE}${RESET}"

    local current_branch=$(git branch --show-current)
    local remote_status=$(git remote show origin 2>/dev/null)
    local push_status=$(git cherry -v 2>/dev/null | wc -l)

    # Current branch info
    echo "${CYBER_BLUE}  🚀 Current Branch: ${BOLD}${CYBER_GREEN}$current_branch${RESET}"

    # Remote connection status
    if [ -n "$remote_status" ]; then
        echo "${CYBER_YELLOW}  🌐 Remote: ${BOLD}${CYBER_CYAN}Connected to origin${RESET}"
    else
        echo "${CYBER_RED}  🌐 Remote: ${BOLD}Not connected${RESET}"
    fi

    # Changes to push
    if [ "$push_status" -gt 0 ]; then
        echo "${CYBER_GREEN}  ▲ Unpushed commits: ${BOLD}$push_status${RESET}"
    else
        echo "${CYBER_YELLOW}  ◍ No unpushed commits${RESET}"
    fi
    echo

    # Commit differences
    echo "${CYBER_YELLOW}  ⎇ Commit Differences:${RESET}"
    git --no-pager log --graph --left-right --boundary --pretty=format:"${CYBER_GREEN}%h${RESET} - ${CYBER_CYAN}%s${RESET} (${CYBER_YELLOW}%cr${RESET})" \
        "$current_branch...origin/$current_branch" 2>/dev/null ||
        echo "  ${CYBER_RED}No remote tracking branch set up${RESET}"
    echo
}

push_actions_menu() {
    local current_branch=$(git branch --show-current)
    local actions=(
        "${CYBER_GREEN}1) Standard Push         ${CYBER_YELLOW}» Safe push to remote branch"
        "${CYBER_CYAN}2) Force Push           ${CYBER_YELLOW}» Overwrite remote history (caution!)"
        "${CYBER_BLUE}3) Push with Tags       ${CYBER_YELLOW}» Push commits and all tags"
        "${CYBER_PURPLE}4) Push to New Branch   ${CYBER_YELLOW}» Create and push to new remote branch"
        "${CYBER_WHITE}5) Set Upstream        ${CYBER_YELLOW}» Configure tracking branch"
        "${CYBER_RED}0) Back to Main Menu   ${CYBER_YELLOW}» Return to dashboard"
    )

    choose_from_menu "Select push operation:" selected_action "${actions[@]}"

    case $selected_action in
        *"Standard Push"*)
            show_spinner "  🚀 Pushing to origin/$current_branch" &
            if git push origin "$current_branch"; then
                echo "${CYBER_GREEN}  ✔ Successfully pushed to origin/$current_branch${RESET}"
            else
                echo "${CYBER_RED}  ✖ Push failed${RESET}"
            fi
            ;;

        *"Force Push"*)
            echo "${CYBER_RED}  ⚠️ WARNING: Force pushing will overwrite remote history${RESET}"
            echo "${CYBER_YELLOW}  Only use this if you're absolutely sure!${RESET}"
            read -p "  ${CYBER_BLUE}Type 'CONFIRM' to proceed: ${RESET}" confirmation
            if [ "$confirmation" = "CONFIRM" ]; then
                show_spinner "  💥 Force pushing to origin/$current_branch" &
                if git push --force-with-lease origin "$current_branch"; then
                    echo "${CYBER_GREEN}  ✔ Successfully force pushed${RESET}"
                else
                    echo "${CYBER_RED}  ✖ Force push failed${RESET}"
                fi
            else
                echo "${CYBER_YELLOW}  Force push canceled${RESET}"
            fi
            ;;

        *"Push with Tags"*)
            show_spinner "  🏷️  Pushing commits and tags to origin" &
            if git push --tags origin "$current_branch"; then
                echo "${CYBER_GREEN}  ✔ Successfully pushed commits and tags${RESET}"
            else
                echo "${CYBER_RED}  ✖ Push failed${RESET}"
            fi
            ;;

        *"Push to New Branch"*)
            echo -n "${CYBER_BLUE}  Enter new remote branch name: ${RESET}"
            read new_branch
            show_spinner "  🌱 Creating and pushing to origin/$new_branch" &
            if git push origin "$current_branch:$new_branch"; then
                echo "${CYBER_GREEN}  ✔ Successfully pushed to new branch origin/$new_branch${RESET}"
                read -p "  ${CYBER_BLUE}Set as upstream? (Y/n): ${RESET}" set_upstream
                if [[ ! "$set_upstream" =~ ^[Nn]$ ]]; then
                    git branch --set-upstream-to=origin/"$new_branch" "$current_branch"
                    echo "${CYBER_GREEN}  ✔ Upstream branch set${RESET}"
                fi
            else
                echo "${CYBER_RED}  ✖ Failed to push to new branch${RESET}"
            fi
            ;;

        *"Set Upstream"*)
            show_spinner "  🔄 Setting upstream tracking" &
            if git push --set-upstream origin "$current_branch"; then
                echo "${CYBER_GREEN}  ✔ Successfully set upstream branch${RESET}"
            else
                echo "${CYBER_RED}  ✖ Failed to set upstream${RESET}"
            fi
            ;;

        *"Back to Main Menu"*)
            return 0
            ;;
    esac

    echo
    read -p "${CYBER_BLUE}  Press Enter to continue...${RESET}" -n 1
    return 1
}

show_push_controller() {
    while true; do
        clear
        show_push_dashboard
        if ! push_actions_menu; then
            # Only prompt to refresh if staying in push controller
            read -p "${CYBER_BLUE}  Press Enter to refresh...${RESET}" -n 1
        else
            # Return to main menu
            return
        fi
    done
}