#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/ui.sh"

show_repo_settings() {
    while true; do
        clear
        echo "${BOLD}${CYBER_PURPLE}"
        echo "    RRRRRR  EEEEEEE PPPPPPP   OOOOO   SSSSS  IIIII TTTTTTT  OOOOO  RRRRRR  YY   YY "
        echo "    RR   RR EE      PP   PP OO   OO SS       III     TTT   OO   OO RR   RR YY   YY "
        echo "    RRRRRR  EEEEE   PPPPPP  OO   OO  SSSSS   III     TTT   OO   OO RRRRRR   YYYYY  "
        echo "    RR  RR  EE      PP      OO   OO      SS  III     TTT   OO   OO RR  RR     YY    "
        echo "    RR   RR EEEEEEE PP       OOOOO   SSSSS  IIIII    TTT    OOOOO  RR   RR    YY    "
        echo "${RESET}"
        echo "${BOLD}${CYBER_PURPLE}  ══════════════════════════════════════════════${RESET}"
        echo

        # Show repository info
        local repo_name=$(basename -s .git $(git config --get remote.origin.url 2>/dev/null) || echo "None")
        local branch=$(git branch --show-current)

        echo "${CYBER_YELLOW}  ⎇ Repository Overview:${RESET}"
        echo "  ${CYBER_BLUE}► Name:${RESET} ${BOLD}${CYBER_CYAN}$repo_name${RESET}"
        echo "  ${CYBER_BLUE}► Branch:${RESET} ${BOLD}${CYBER_GREEN}$branch${RESET}"
        echo

        # Show configuration options
        local actions=(
            "${CYBER_GREEN}1) View Config          ${CYBER_YELLOW}» Show all git settings"
            "${CYBER_CYAN}2) Change User Info     ${CYBER_YELLOW}» Update name/email"
            "${CYBER_BLUE}3) Manage Remotes       ${CYBER_YELLOW}» Add/remove repositories"
            "${CYBER_PURPLE}4) Repository Cleanup   ${CYBER_YELLOW}» Optimize and clean"
            "${CYBER_RED}0) Back to Main Menu    ${CYBER_YELLOW}» Return to dashboard"
        )

        choose_from_menu "Select action:" selected_action "${actions[@]}"

        case $selected_action in
            *"View Config"*)
                clear
                echo "${CYBER_YELLOW}  ⎇ Git Configuration:${RESET}"
                git config --list | awk -F= '{
                    printf "  %s%s%s=%s%s%s\n",
                    "'${CYBER_BLUE}'", $1, "'${RESET}'",
                    "'${BOLD}${CYBER_CYAN}'", $2, "'${RESET}'"
                }' | column -t -s=
                echo
                read -p "${CYBER_BLUE}  Press Enter to continue...${RESET}" -n 1
                ;;

            *"Change User Info"*)
                clear
                echo "${CYBER_YELLOW}  ⎇ Current Identity:${RESET}"
                echo "  ${CYBER_BLUE}► Name:${RESET}  $(git config user.name)"
                echo "  ${CYBER_BLUE}► Email:${RESET} $(git config user.email)"
                echo

                read -p "${CYBER_BLUE}  Enter new name: ${RESET}" name
                read -p "${CYBER_BLUE}  Enter new email: ${RESET}" email

                if [ -n "$name" ]; then
                    git config user.name "$name"
                    echo "${CYBER_GREEN}  ✔ Updated user name${RESET}"
                fi

                if [ -n "$email" ]; then
                    git config user.email "$email"
                    echo "${CYBER_GREEN}  ✔ Updated user email${RESET}"
                fi
                sleep 1
                ;;

            *"Manage Remotes"*)
                clear
                echo "${CYBER_YELLOW}  ⎇ Current Remotes:${RESET}"
                git remote -v
                echo

                local remote_actions=(
                    "${CYBER_GREEN}1) Add Remote       ${CYBER_YELLOW}» Connect new repository"
                    "${CYBER_CYAN}2) Remove Remote    ${CYBER_YELLOW}» Disconnect repository"
                    "${CYBER_RED}0) Back           ${CYBER_YELLOW}» Return to settings"
                )

                choose_from_menu "Select remote action:" remote_action "${remote_actions[@]}"

                case $remote_action in
                    *"Add Remote"*)
                        echo -n "${CYBER_BLUE}  Enter remote name (default: origin): ${RESET}"
                        read remote_name
                        remote_name=${remote_name:-origin}
                        echo -n "${CYBER_BLUE}  Enter remote URL: ${RESET}"
                        read remote_url
                        git remote add "$remote_name" "$remote_url"
                        echo "${CYBER_GREEN}  ✔ Added remote $remote_name${RESET}"
                        sleep 1
                        ;;
                    *"Remove Remote"*)
                        echo -n "${CYBER_BLUE}  Enter remote name to remove: ${RESET}"
                        read remote_name
                        git remote remove "$remote_name"
                        echo "${CYBER_GREEN}  ✔ Removed remote $remote_name${RESET}"
                        sleep 1
                        ;;
                esac
                ;;

            *"Repository Cleanup"*)
                clear
                echo "${CYBER_YELLOW}  ⎇ Cleanup Options:${RESET}"
                local cleanup_actions=(
                    "${CYBER_GREEN}1) Prune Branches     ${CYBER_YELLOW}» Remove stale branches"
                    "${CYBER_CYAN}2) Optimize Repo     ${CYBER_YELLOW}» Run garbage collection"
                    "${CYBER_RED}0) Back            ${CYBER_YELLOW}» Return to settings"
                )

                choose_from_menu "Select cleanup action:" cleanup_action "${cleanup_actions[@]}"

                case $cleanup_action in
                    *"Prune Branches"*)
                        show_spinner "  🧹 Pruning remote branches" &
                        git remote prune origin
                        echo "${CYBER_GREEN}  ✔ Remote branches pruned${RESET}"
                        ;;
                    *"Optimize Repo"*)
                        show_spinner "  ♻️  Optimizing repository" &
                        git gc
                        echo "${CYBER_GREEN}  ✔ Repository optimized${RESET}"
                        ;;
                esac
                sleep 1
                ;;

            *"Back to Main Menu"*)
                return
                ;;
        esac
    done
}