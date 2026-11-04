#!/bin/bash

# ==================================================
# AZURE DEVOPS MODULE COORDINATOR
# ==================================================

if [ -z "${BASE_DIR:-}" ]; then
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

source "${BASE_DIR}/lib/azure/helpers.sh"
source "${BASE_DIR}/lib/azure/render.sh"
source "${BASE_DIR}/lib/azure/install.sh"
source "${BASE_DIR}/lib/azure/pr_render.sh"
source "${BASE_DIR}/lib/azure/prs.sh"
source "${BASE_DIR}/lib/azure/repos.sh"
source "${BASE_DIR}/lib/azure/help.sh"
