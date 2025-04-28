#!/bin/bash

generate_controller() {
    local entity_name="$1"
    local base_path="src/main/java"
    local package_path=$(find_package_path)
    local controller_file="${base_path}/${package_path}/controller/${entity_name}Controller.java"

    mkdir -p "$(dirname "$controller_file")"

    cat > "$controller_file" << EOF
package $(get_package_name).controller;

import $(get_package_name).model.${entity_name};
import $(get_package_name).service.${entity_name}Service;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/${entity_name.toLowerCase()}s")
@RequiredArgsConstructor
@Tag(name = "${entity_name} Controller")
public class ${entity_name}Controller {

    private final ${entity_name}Service service;

    @PostMapping
    @Operation(summary = "Create a new ${entity_name}")
    public ResponseEntity<${entity_name}> create(@RequestBody ${entity_name} entity) {
        return ResponseEntity.ok(service.save(entity));
    }

    @GetMapping
    @Operation(summary = "Get all ${entity_name}s")
    public ResponseEntity<List<${entity_name}>> findAll() {
        return ResponseEntity.ok(service.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get ${entity_name} by ID")
    public ResponseEntity<${entity_name}> findById(@PathVariable Long id) {
        return service.findById(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update ${entity_name}")
    public ResponseEntity<${entity_name}> update(@PathVariable Long id, @RequestBody ${entity_name} entity) {
        return service.findById(id)
            .map(existing -> {
                entity.setId(id);
                return ResponseEntity.ok(service.save(entity));
            })
            .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Delete ${entity_name}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        service.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}
EOF

    echo -e "${CYBER_GREEN}✔ Controller gerado: ${controller_file}${RESET}"
}