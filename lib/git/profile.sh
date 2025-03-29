#!/bin/bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$(dirname "${BASH_SOURCE[0]}")/ui.sh"

show_profile_header() {
    echo ""
    echo "${BOLD}${CYBER_PURPLE}  ╔══════════════════════════════════════════════╗"
    echo "  ║               ${CYBER_CYAN}▓ PROFILE DASHBOARD ${CYBER_PURPLE}▓              "
    echo "  ╚══════════════════════════════════════════════╝${RESET}"
}

show_user_info() {
    local user_name=$(git config user.name)
    local user_email=$(git config user.email)
    local git_version=$(git --version | cut -d' ' -f3)

    echo ""
    echo "${BOLD}${CYBER_GREEN}  ╔════════════════════════════════╗"
    echo "  ║       ${CYBER_CYAN}USER IDENTITY${CYBER_GREEN}       "
    echo "  ╚════════════════════════════════╝${RESET}"
    echo "  ${CYBER_YELLOW}👤 Name:${RESET} ${user_name}"
    echo "  ${CYBER_YELLOW}📧 Email:${RESET} ${user_email}"
    echo "  ${CYBER_YELLOW}🛠️ Git Version:${RESET} ${git_version}"
}

show_repo_stats() {
    local total_commits=$(git rev-list --count --all 2>/dev/null || echo "0")
    local total_branches=$(git branch -a | wc -l | tr -d ' ')
    local active_branch=$(git branch --show-current)
    local last_commit=$(git log -1 --format="%cr" 2>/dev/null || echo "Never")
    local total_files=$(git ls-files | wc -l | tr -d ' ')

    # Cálculo do tamanho do repositório melhorado
    local repo_size=""
    if [ -d BASE_DIR ]; then
        if command -v du >/dev/null 2>&1; then
            repo_size=$(du -sh BASE_DIR 2>/dev/null | cut -f1)
            [ -z "$repo_size" ] && repo_size=$(du -sh BASE_DIR 2>/dev/null | cut -f1)
        fi
    fi

    echo ""
    echo "${BOLD}${CYBER_GREEN}  ╔════════════════════════════════╗"
    echo "  ║       ${CYBER_CYAN}REPOSITORY STATS${CYBER_GREEN}    ║"
    echo "  ╚════════════════════════════════╝${RESET}"
    echo "  ${CYBER_YELLOW}🌿 Active Branch:${RESET} ${active_branch}"
    echo "  ${CYBER_YELLOW}🕒 Last Commit:${RESET} ${last_commit}"
    echo "  ${CYBER_YELLOW}📊 Total Commits:${RESET} ${total_commits}"
    echo "  ${CYBER_YELLOW}🌳 Total Branches:${RESET} ${total_branches}"
    echo "  ${CYBER_YELLOW}📂 Total Tracked Files:${RESET} ${total_files}"
    echo "  ${CYBER_YELLOW}📦 Repo Size:${RESET} ${repo_size:-"Not available"}"
}

generate_custom_graph() {
    local active_branch=$(git branch --show-current)
    # Get last 5 commits (hash, message and relative date)
    local commit_data=$(git log -n 5 --pretty=format:"%h|%s|%cr" 2>/dev/null)
    local branches=($(git branch --format="%(refname:short)" | head -5))

    echo ""
    echo "${BOLD}${CYBER_GREEN}  ╔════════════════════════════════╗"
    echo "  ║       ${CYBER_CYAN}RECENT ACTIVITY${CYBER_GREEN}     ║"
    echo "  ╚════════════════════════════════╝${RESET}"
    echo "${CYBER_YELLOW}"

    if [ -z "$commit_data" ]; then
        echo "  No commits yet"
    else
        # Display graph with messages and dates
        local first_line=true
        while IFS='|' read -r hash message date; do
            if [ "$first_line" = true ]; then
                echo "  ┌─ ${CYBER_CYAN}${hash}${CYBER_YELLOW} (${active_branch})"
                echo "  │   ${message}"
                echo "  │   ${CYBER_PURPLE}⏱️ ${date}${CYBER_YELLOW}"
                first_line=false
            else
                echo "  │"
                echo "  ├─ ${CYBER_CYAN}${hash}${CYBER_YELLOW}"
                echo "  │   ${message}"
                echo "  │   ${CYBER_PURPLE}⏱️ ${date}${CYBER_YELLOW}"
            fi
        done <<< "$commit_data"

        # Show recent branches
        if [ ${#branches[@]} -gt 0 ]; then
            echo ""
            echo "  ${CYBER_CYAN}Recent Branches:${RESET}"
            for branch in "${branches[@]}"; do
                if [ "$branch" != "$active_branch" ]; then
                    echo "  - ${branch}"
                fi
            done
        fi
    fi

    echo "${RESET}"
}

show_edit_options() {
    echo ""
    echo "${BOLD}${CYBER_GREEN}  ╔════════════════════════════════╗"
    echo "  ║       ${CYBER_CYAN}EDIT PROFILE${CYBER_GREEN}        ║"
    echo "  ╚════════════════════════════════╝${RESET}"
    echo "  ${CYBER_YELLOW}1) Change Name"
    echo "  2) Change Email"
    echo "  3) Back to Main Menu${RESET}"
}

edit_profile() {
    while true; do
        show_profile_header
        show_user_info
        show_edit_options

        read -p "${BOLD}${CYBER_PURPLE}  ⌘ Select option (1-3): ${RESET}" choice

        case $choice in
            1)
                read -p "${CYBER_BLUE}  Enter new name: ${RESET}" new_name
                git config user.name "$new_name"
                echo "${CYBER_GREEN}  ✔ Name updated successfully${RESET}"
                sleep 1
                ;;
            2)
                read -p "${CYBER_BLUE}  Enter new email: ${RESET}" new_email
                git config user.email "$new_email"
                echo "${CYBER_GREEN}  ✔ Email updated successfully${RESET}"
                sleep 1
                ;;
            3)
                return 0
                ;;
            *)
                echo "${CYBER_RED}  ✖ Invalid option${RESET}"
                sleep 1
                ;;
        esac
    done
}

profile_dashboard() {
    while true; do
        show_profile_header
        show_user_info
        show_repo_stats
        generate_custom_graph

        read -p "${BOLD}${CYBER_PURPLE}  ⌘ Press [e] to edit, [h] for help or [q] to quit: ${RESET}" choice

        case $choice in
            e|E)
                edit_profile
                ;;
            h|H)
                echo ""
                echo "${CYBER_CYAN}  Help:"
                echo "  [e] Edit profile"
                echo "  [q] Return to main menu"
                echo "  [h] Show this help${RESET}"
                read -p "${CYBER_BLUE}  Press Enter to continue...${RESET}"
                ;;
            q|Q)
                return 0
                ;;
            *)
                echo "${CYBER_RED}  ✖ Invalid option${RESET}"
                sleep 1
                ;;
        esac
    done
}