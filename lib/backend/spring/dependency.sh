#!/bin/bash

# Lista dependências disponíveis
list_dependencies() {
    echo -e "${CYBER_BLUE}Dependências disponíveis:${RESET}"
    echo -e "  ${CYBER_GREEN}web${RESET}         - Spring Web"
    echo -e "  ${CYBER_GREEN}data-jpa${RESET}    - Spring Data JPA"
    echo -e "  ${CYBER_GREEN}security${RESET}    - Spring Security"
    echo -e "  ${CYBER_GREEN}validation${RESET}  - Validation"
    echo -e "  ${CYBER_GREEN}actuator${RESET}    - Actuator"
    echo -e "  ${CYBER_GREEN}devtools${RESET}    - Developer Tools"
    echo -e "  ${CYBER_GREEN}lombok${RESET}      - Lombok"
}

# Adiciona dependência ao projeto
add_dependency() {
    local dependency="$1"
    local group_id artifact_id version rest block tmp

    if [[ ! -f "pom.xml" ]]; then
        echo -e "${CYBER_RED}✘ Arquivo pom.xml não encontrado${RESET}"
        return 1
    fi

    if [[ "$dependency" != *:* ]]; then
        echo -e "${CYBER_RED}✘ Dependência deve usar o formato grupo:artefato[:versão]${RESET}"
        return 1
    fi

    group_id="${dependency%%:*}"
    rest="${dependency#*:}"
    artifact_id="${rest%%:*}"
    version=""
    if [[ "$rest" == *:* ]]; then
        version="${rest#*:}"
    fi

    if [[ ! "$group_id" =~ ^[A-Za-z0-9_.-]+$ || ! "$artifact_id" =~ ^[A-Za-z0-9_.-]+$ ||
        ( -n "$version" && ! "$version" =~ ^[A-Za-z0-9_.\${}-]+$ ) ]]; then
        echo -e "${CYBER_RED}✘ Coordenadas de dependência inválidas: ${dependency}${RESET}"
        return 1
    fi

    if grep -q "<artifactId>${artifact_id}</artifactId>" pom.xml; then
        echo -e "${CYBER_YELLOW}ℹ Dependência ${artifact_id} já existe${RESET}"
        return 0
    fi

    block="        <dependency>
            <groupId>${group_id}</groupId>
            <artifactId>${artifact_id}</artifactId>"
    if [[ -n "$version" ]]; then
        block="${block}
            <version>${version}</version>"
    fi
    block="${block}
        </dependency>"

    if ! grep -q '</dependencies>' pom.xml; then
        echo -e "${CYBER_RED}✘ Bloco <dependencies> não encontrado em pom.xml${RESET}"
        return 1
    fi

    tmp=$(mktemp)
    awk -v block="$block" '
        !done && /<\/dependencies>/ { print block; done = 1 }
        { print }
    ' pom.xml > "$tmp" || {
        rm -f "$tmp"
        return 1
    }
    mv "$tmp" pom.xml

    echo -e "${CYBER_GREEN}✔ Dependência ${artifact_id} adicionada com sucesso${RESET}"
}

# Remove dependência do projeto
remove_dependency() {
    local dependency="$1"
    local artifact_id rest tmp

    if [[ ! -f "pom.xml" ]]; then
        echo -e "${CYBER_RED}✘ Arquivo pom.xml não encontrado${RESET}"
        return 1
    fi

    if [[ "$dependency" == *:* ]]; then
        rest="${dependency#*:}"
        artifact_id="${rest%%:*}"
    else
        artifact_id="$dependency"
    fi

    if [[ ! "$artifact_id" =~ ^[A-Za-z0-9_.-]+$ ]]; then
        echo -e "${CYBER_RED}✘ Nome de dependência inválido: ${dependency}${RESET}"
        return 1
    fi

    if ! grep -q "<artifactId>${artifact_id}</artifactId>" pom.xml; then
        echo -e "${CYBER_YELLOW}ℹ Dependência ${artifact_id} não encontrada${RESET}"
        return 0
    fi

    tmp=$(mktemp)
    awk -v artifact="$artifact_id" '
        /<dependency>/ { in_dep = 1; found = 0; buffer = $0 ORS; next }
        in_dep {
            buffer = buffer $0 ORS
            if (index($0, "<artifactId>" artifact "</artifactId>")) found = 1
            if (/<\/dependency>/) {
                if (!found) printf "%s", buffer
                in_dep = 0
                buffer = ""
            }
            next
        }
        { print }
    ' pom.xml > "$tmp" || {
        rm -f "$tmp"
        return 1
    }
    mv "$tmp" pom.xml

    echo -e "${CYBER_GREEN}✔ Dependência ${artifact_id} removida com sucesso${RESET}"
}
