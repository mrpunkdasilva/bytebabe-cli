#!/bin/bash

# ==================================================
# SONAR MODULE COORDINATOR
# ==================================================

if [ -z "${BASE_DIR:-}" ]; then
    BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fi

source "${BASE_DIR}/lib/core/colors.sh"
source "${BASE_DIR}/lib/core/helpers.sh"

source "${BASE_DIR}/lib/sonar/config.sh"
source "${BASE_DIR}/lib/sonar/projects.sh"
source "${BASE_DIR}/lib/sonar/pulls.sh"
source "${BASE_DIR}/lib/sonar/client.sh"
source "${BASE_DIR}/lib/sonar/render.sh"
source "${BASE_DIR}/lib/sonar/queries.sh"
