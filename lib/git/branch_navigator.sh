#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/ui.sh"

show_branch_graph() {
    local branches=()
    local current_branch=$(git branch --show-current)
    local max_length=0

    # Get all branches and determine max length for alignment
    while IFS= read -r branch; do
        branch=${branch#\* }  # Remove current branch marker
        branch=${branch// /}  # Remove spaces
        [ ${#branch} -gt $max_length ] && max_length=${#branch}
        branches+=("$branch")
    done < <(git branch --list --all | cut -c 3-)

    # Display branch visualization
    echo "${BOLD}${CYBER_PURPLE}${CYBER_CYAN}
     ______   ______ _______ __   _ _______ _     _
     |_____] |_____/ |_____| | \  | |       |_____|
     |_____] |    \_ |     | |  \_| |_____  |     |
                                                   
     __   _ _______ _    _ _____  ______ _______ _______  _____   ______
     | \  | |_____|  \  /    |   |  ____ |_____|    |    |     | |_____/
     |  \_| |     |   \/   __|__ |_____| |     |    |    |_____| |    \_
                                                                        
    ${RESET}"
    echo "${CYBER_BLUE}  🌿 Current Branch: ${BOLD}${CYBER_GREEN}$current_branch${RESET}"
    echo

    # Show branch graph with proper color substitution
    echo "${CYBER_YELLOW}  ⎇ Branch Tree:${RESET}"
    git log --graph --abbrev-commit --decorate --format=format:'%h %s %ar' --all --color=always |
        head -n 5 |
        while IFS= read -r line; do
            # Replace graph characters with colored versions
            line=${line//\*/${CYBER_GREEN}*${RESET}}
            line=${line//\|/${CYBER_BLUE}|${RESET}}
            line=${line//\\/${CYBER_BLUE}\\${RESET}}
            line=${line//\//${CYBER_BLUE}\/${RESET}}
            echo "  $line"
        done
    echo

    # Branch list with highlighting
    echo "${CYBER_YELLOW}  ⎇ Available Branches:${RESET}"
    for branch in "${branches[@]}"; do
        if [ "$branch" == "$current_branch" ]; then
            printf "  ${BOLD}${CYBER_GREEN}➤ %-${max_length}s${RESET} ${CYBER_CYAN}(current)${RESET}\n" "$branch"
        elif [[ "$branch" == *"main"* ]] || [[ "$branch" == *"master"* ]]; then
            printf "  ${BOLD}${CYBER_PURPLE}  %-${max_length}s${RESET} ${CYBER_YELLOW}(primary)${RESET}\n" "$branch"
        else
            printf "  ${CYBER_BLUE}  %-${max_length}s${RESET}\n" "$branch"
        fi
    done
}

branch_actions_menu() {
    local current_branch=$(git branch --show-current)
    local actions=(
        "${CYBER_GREEN}1) Switch Branch        ${CYBER_YELLOW}» Checkout different branch"
        "${CYBER_CYAN}2) Create Branch       ${CYBER_YELLOW}» Start new feature branch"
        "${CYBER_BLUE}3) Merge Branch        ${CYBER_YELLOW}» Combine branches"
        "${CYBER_PURPLE}4) Delete Branch       ${CYBER_YELLOW}» Remove local branch"
        "${CYBER_RED}0) Back to Main Menu   ${CYBER_YELLOW}» Return to dashboard"
    )

    echo
    choose_from_menu "Select action:" selected_action "${actions[@]}"

    case $selected_action in
        *"Switch Branch"*)
            echo -n "${CYBER_BLUE}  Enter branch name to switch to: ${RESET}"
            read branch_name
            if git show-ref --verify --quiet refs/heads/"$branch_name"; then
                show_loading "  🌱 Switching to $branch_name"
                git checkout "$branch_name"
                echo "${CYBER_GREEN}  ✔ Switched to branch: $branch_name${RESET}"
            else
                echo "${CYBER_RED}  ✖ Branch $branch_name doesn't exist${RESET}"
            fi
            return 1  # Continue in branch navigator
            ;;
        *"Create Branch"*)
            echo -n "${CYBER_BLUE}  Enter new branch name: ${RESET}"
            read new_branch
            show_loading "  🌿 Creating branch $new_branch"
            git checkout -b "$new_branch"
            echo "${CYBER_GREEN}  ✔ Created and switched to branch: $new_branch${RESET}"
            return 1  # Continue in branch navigator
            ;;
        *"Merge Branch"*)
            echo -n "${CYBER_BLUE}  Enter branch to merge into $current_branch: ${RESET}"
            read merge_branch
            show_loading "  🌀 Merging $merge_branch into $current_branch"
            git merge "$merge_branch"
            return 1  # Continue in branch navigator
            ;;
        *"Delete Branch"*)
            echo -n "${CYBER_BLUE}  Enter branch to delete: ${RESET}"
            read delete_branch
            if [ "$delete_branch" == "$current_branch" ]; then
                echo "${CYBER_RED}  ✖ Cannot delete current branch${RESET}"
            else
                show_loading "  🗑️ Deleting branch $delete_branch"
                git branch -d "$delete_branch"
                echo "${CYBER_GREEN}  ✔ Deleted branch: $delete_branch${RESET}"
            fi
            return 1  # Continue in branch navigator
            ;;
        *"Back to Main Menu"*)
            return 0  # Return to main menu
            ;;
        *)
            return 1  # Continue in branch navigator
            ;;
    esac
    sleep 1
}

show_branch_navigator() {
    while true; do
        clear
        show_branch_graph
        if ! branch_actions_menu; then
            # Only prompt to refresh if we're staying in branch navigator
            read -p "${CYBER_BLUE}  Press Enter to refresh...${RESET}" -n 1
        else
            # Return to main menu
            return
        fi
    done
}