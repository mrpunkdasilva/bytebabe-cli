#!/bin/bash

# Arquivo de configuração do projeto frontend
FRONTEND_CONFIG_FILE=".bytebabe/frontend-config.json"

# Inicializa ou lê configuração
init_frontend_config() {
    mkdir -p .bytebabe
    
    if [[ ! -f "$FRONTEND_CONFIG_FILE" ]]; then
        # Detecta framework usado (React, Vue, Angular)
        local framework=""
        
        if [[ -f "package.json" ]]; then
            if grep -q '"react"' package.json; then
                framework="react"
            elif grep -q '"vue"' package.json; then
                framework="vue"
            elif grep -q '"@angular/core"' package.json; then
                framework="angular"
            fi
        fi
        
        # Cria arquivo de configuração
        cat > "$FRONTEND_CONFIG_FILE" << EOF
{
    "framework": "${framework}",
    "defaultPaths": {
        "components": "src/components",
        "pages": "src/pages",
        "services": "src/services",
        "hooks": "src/hooks",
        "styles": "src/styles",
        "tests": "src/tests"
    },
    "styling": "scss",
    "testing": "jest"
}
EOF
    fi
}