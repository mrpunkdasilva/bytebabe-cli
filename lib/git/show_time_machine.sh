#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/ui.sh"

show_time_machine_header() {
    clear
    echo "${BOLD}${CYBER_PURPLE}"
    echo "    TTTTTT IIIII MM    MM EEEEEEE   MM    MM  AAA   CCCCC HH   HH IIIII NN   NN EEEEEEE "
    echo "      TT     I   MMM  MMM EE        MMM  MMM A   A CC    C HH   HH   I   NNN  NN EE      "
    echo "      TT     I   MM MM MM EEEEE     MM MM MM AAAAA CC      HHHHHHH   I   NN N NN EEEEE   "
    echo "      TT     I   MM    MM EE        MM    MM A   A CC    C HH   HH   I   NN  NNN EE      "
    echo "      TT   IIIII MM    MM EEEEEEE   MM    MM A   A  CCCCC  HH   HH IIIII NN   NN EEEEEEE "
    echo "${RESET}"
    echo "${BOLD}${CYBER_PURPLE}  ══════════════════════════════════════════════${RESET}"
    echo
}

show_commit_graph() {
    local limit=$1
    local offset=$2
    echo "${CYBER_YELLOW}  ⎇ Commit History Graph (last ${limit} commits, offset ${offset}):${RESET}"
    git --no-pager log --graph --pretty=format:"${CYBER_GREEN}%h${RESET} - ${CYBER_CYAN}%s${RESET} (${CYBER_BLUE}%cr${RESET})" --abbrev-commit -n $limit --skip=$offset
    echo
}

show_commit_details() {
    local commit_hash=$1
    echo "${CYBER_YELLOW}  ⎇ Commit Details:${RESET}"
    git --no-pager show --stat --pretty=format:"${CYBER_GREEN}%h${RESET} - ${CYBER_CYAN}%s${RESET}
Author: ${CYBER_BLUE}%an${RESET} <%ae>
Date:   ${CYBER_PURPLE}%ad${RESET}

${CYBER_WHITE}%b${RESET}" $commit_hash
    echo
}

time_machine_actions() {
    local commit_hash=$1
    local actions=(
        "${CYBER_GREEN}1) View Full Changes       ${CYBER_YELLOW}» See complete diff"
        "${CYBER_CYAN}2) Checkout This Commit   ${CYBER_YELLOW}» Temporarily switch to this version"
        "${CYBER_BLUE}3) Create Branch Here    ${CYBER_YELLOW}» Start new branch from this commit"
        "${CYBER_PURPLE}4) Cherry-pick Commit    ${CYBER_YELLOW}» Apply this commit to current branch"
        "${CYBER_WHITE}5) View File Changes     ${CYBER_YELLOW}» Browse changed files"
        "${CYBER_RED}0) Back to History       ${CYBER_YELLOW}» Return to commit list"
    )

    choose_from_menu "Select action:" selected_action "${actions[@]}"

    case $selected_action in
        *"View Full Changes"*)
            clear
            echo "${CYBER_YELLOW}  ⎇ Full Diff for ${commit_hash}:${RESET}"
            git --no-pager diff ${commit_hash}^! --color=always | less -R
            ;;

        *"Checkout This Commit"*)
            echo "${CYBER_YELLOW}  ⚠️ You're in 'detached HEAD' state${RESET}"
            show_spinner "  ⏳ Checking out commit ${commit_hash}" &
            git checkout $commit_hash
            echo "${CYBER_GREEN}  ✔ Checked out commit ${commit_hash}"
            echo "  ${CYBER_YELLOW}Remember to checkout a branch when done${RESET}"
            read -p "${CYBER_BLUE}  Press Enter to continue...${RESET}" -n 1
            return 0
            ;;

        *"Create Branch Here"*)
            echo -n "${CYBER_BLUE}  Enter new branch name: ${RESET}"
            read branch_name
            show_spinner "  🌿 Creating branch ${branch_name}" &
            git checkout -b $branch_name $commit_hash
            echo "${CYBER_GREEN}  ✔ Created branch ${branch_name} at ${commit_hash}${RESET}"
            sleep 1
            return 0
            ;;

        *"Cherry-pick Commit"*)
            show_spinner "  🍒 Applying commit ${commit_hash}" &
            if git cherry-pick $commit_hash; then
                echo "${CYBER_GREEN}  ✔ Successfully cherry-picked ${commit_hash}${RESET}"
            else
                echo "${CYBER_RED}  ✖ Cherry-pick failed${RESET}"
            fi
            sleep 1
            ;;

        *"View File Changes"*)
            show_file_changes $commit_hash
            ;;

        *"Back to History"*)
            return 1
            ;;
    esac
    return 2
}

show_file_changes() {
    local commit_hash=$1
    local files=($(git diff-tree --no-commit-id --name-only -r $commit_hash))
    local current=0

    while true; do
        clear
        echo "${CYBER_YELLOW}  ⎇ Changed Files in ${commit_hash}:${RESET}"

        for i in "${!files[@]}"; do
            if [ $i -eq $current ]; then
                echo "  ${CYBER_GREEN}➤ ${files[i]}${RESET}"
            else
                echo "    ${files[i]}"
            fi
        done

        echo
        echo "${CYBER_YELLOW}  Use: ↑/↓ to navigate, Enter to view, q to return${RESET}"

        # Read key with proper escape sequence handling
        IFS= read -rsn1 key
        if [[ "$key" == $'\e' ]]; then
            read -rsn2 -t 0.1 key
        fi

        case "$key" in
            '[A') # Up arrow
                ((current > 0)) && ((current--))
                ;;
            '[B') # Down arrow
                ((current < ${#files[@]}-1)) && ((current++))
                ;;
            '') # Enter
                clear
                git --no-pager diff ${commit_hash}^! --color=always -- "${files[current]}" | less -R
                ;;
            q|Q)
                return
                ;;
        esac
    done
}

show_time_machine() {
    local limit=15
    local offset=0
    local commit_hash=""
    local total_commits=$(git rev-list --count HEAD)

    while true; do
        show_time_machine_header
        show_commit_graph $limit $offset

        echo "${CYBER_YELLOW}  ⎇ Navigation:${RESET}"
        echo "  ${CYBER_GREEN}↑${RESET} - Scroll up (earlier commits)"
        echo "  ${CYBER_GREEN}↓${RESET} - Scroll down (newer commits)"
        echo "  ${CYBER_GREEN}Enter${RESET} - Select commit"
        echo "  ${CYBER_GREEN}+/-${RESET} - Increase/decrease history limit"
        echo "  ${CYBER_RED}q${RESET} - Quit to main menu"
        echo

        # Read key with proper escape sequence handling
        IFS= read -rsn1 key
        if [[ "$key" == $'\e' ]]; then
            read -rsn2 -t 0.1 key
        fi

        case "$key" in
            '[A') # Up arrow - earlier commits
                ((offset += limit))
                ((offset > total_commits - limit)) && offset=$((total_commits - limit))
                ;;
            '[B') # Down arrow - newer commits
                ((offset -= limit))
                ((offset < 0)) && offset=0
                ;;
            '+')
                ((limit += 5))
                ((limit > 100)) && limit=100
                ;;
            '-')
                ((limit -= 5))
                ((limit < 5)) && limit=5
                ;;
            '') # Enter
                echo -n "${CYBER_BLUE}  Enter commit hash: ${RESET}"
                read commit_hash
                while true; do
                    show_time_machine_header
                    show_commit_details $commit_hash
                    time_machine_actions $commit_hash
                    case $? in
                        0) return;; # Back to main
                        1) break;; # Back to list
                        2) continue;; # Continue actions
                    esac
                done
                ;;
            q|Q)
                return
                ;;
        esac
    done
}