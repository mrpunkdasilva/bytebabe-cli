#!/bin/bash

generate_repository() {
    local entity_name="$1"
    local base_path="src/main/java"
    local package_path=$(find_package_path)
    local repo_file="${base_path}/${package_path}/repository/${entity_name}Repository.java"

    mkdir -p "$(dirname "$repo_file")"

    cat > "$repo_file" << EOF
package $(get_package_name).repository;

import $(get_package_name).model.${entity_name};
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ${entity_name}Repository extends JpaRepository<${entity_name}, Long> {
    // TODO: Adicione queries customizadas aqui
}
EOF

    echo -e "${CYBER_GREEN}✔ Repository gerado: ${repo_file}${RESET}"
}