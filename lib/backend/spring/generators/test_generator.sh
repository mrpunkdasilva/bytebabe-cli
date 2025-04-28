#!/bin/bash

# Gera teste unitário para Service
generate_service_test() {
    local service_name="$1"
    local base_path="src/test/java"
    local package_path=$(find_package_path)
    local test_file="${base_path}/${package_path}/service/${service_name}ServiceTest.java"

    mkdir -p "$(dirname "$test_file")"

    cat > "$test_file" << EOF
package $(get_package_name).service;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

class ${service_name}ServiceTest {

    @InjectMocks
    private ${service_name}Service service;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void contextLoads() {
        // TODO: Implement tests
    }
}
EOF

    echo -e "${CYBER_GREEN}✔ Teste gerado: ${test_file}${RESET}"
}

# Gera teste de integração para Controller
generate_controller_test() {
    local controller_name="$1"
    local base_path="src/test/java"
    local package_path=$(find_package_path)
    local test_file="${base_path}/${package_path}/controller/${controller_name}ControllerTest.java"

    mkdir -p "$(dirname "$test_file")"

    cat > "$test_file" << EOF
package $(get_package_name).controller;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest
@AutoConfigureMockMvc
class ${controller_name}ControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void contextLoads() {
        // TODO: Implement integration tests
    }
}
EOF

    echo -e "${CYBER_GREEN}✔ Teste de integração gerado: ${test_file}${RESET}"
}