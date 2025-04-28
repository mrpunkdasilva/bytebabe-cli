#!/bin/bash

# Configura Swagger/OpenAPI
setup_swagger() {
    # Adiciona dependência do SpringDoc OpenAPI
    add_dependency "org.springdoc:springdoc-openapi-starter-webmvc-ui:2.3.0"

    # Cria arquivo de configuração do Swagger
    local config_file="src/main/java/$(find_package_path)/config/SwaggerConfig.java"
    
    mkdir -p "$(dirname "$config_file")"

    cat > "$config_file" << EOF
package $(get_package_name).config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI springShopOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("$(get_project_name) API")
                .description("API Documentation")
                .version("1.0.0"));
    }
}
EOF

    # Adiciona propriedades do Swagger
    echo "springdoc.swagger-ui.path=/swagger-ui.html" >> src/main/resources/application.properties
    echo "springdoc.api-docs.path=/api-docs" >> src/main/resources/application.properties

    echo -e "${CYBER_GREEN}✔ Swagger configurado com sucesso${RESET}"
    echo -e "${CYBER_BLUE}Acesse a documentação em: http://localhost:8080/swagger-ui.html${RESET}"
}