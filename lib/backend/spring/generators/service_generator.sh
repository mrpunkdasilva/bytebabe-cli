#!/bin/bash

generate_service() {
    local entity_name="$1"
    local base_path="src/main/java"
    local package_path=$(find_package_path)
    local service_file="${base_path}/${package_path}/service/${entity_name}Service.java"
    local service_impl_file="${base_path}/${package_path}/service/impl/${entity_name}ServiceImpl.java"

    # Gera interface do Service
    mkdir -p "$(dirname "$service_file")"
    cat > "$service_file" << EOF
package $(get_package_name).service;

import $(get_package_name).model.${entity_name};
import java.util.List;
import java.util.Optional;

public interface ${entity_name}Service {
    ${entity_name} save(${entity_name} entity);
    List<${entity_name}> findAll();
    Optional<${entity_name}> findById(Long id);
    void deleteById(Long id);
}
EOF

    # Gera implementação do Service
    mkdir -p "$(dirname "$service_impl_file")"
    cat > "$service_impl_file" << EOF
package $(get_package_name).service.impl;

import $(get_package_name).model.${entity_name};
import $(get_package_name).repository.${entity_name}Repository;
import $(get_package_name).service.${entity_name}Service;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ${entity_name}ServiceImpl implements ${entity_name}Service {
    
    private final ${entity_name}Repository repository;

    @Override
    public ${entity_name} save(${entity_name} entity) {
        return repository.save(entity);
    }

    @Override
    public List<${entity_name}> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<${entity_name}> findById(Long id) {
        return repository.findById(id);
    }

    @Override
    public void deleteById(Long id) {
        repository.deleteById(id);
    }
}
EOF

    echo -e "${CYBER_GREEN}✔ Service gerado: ${service_file}${RESET}"
    echo -e "${CYBER_GREEN}✔ ServiceImpl gerado: ${service_impl_file}${RESET}"
}