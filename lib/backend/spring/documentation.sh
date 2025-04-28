#!/bin/bash

# Configuração do Swagger/OpenAPI
setup_swagger() {
    echo -e "${CYBER_BLUE}Configurando Swagger/OpenAPI...${RESET}"
    
    # Adicionar dependência
    add_dependency "org.springdoc:springdoc-openapi-starter-webmvc-ui"
    
    # Configurar application.yml
    cat >> "src/main/resources/application.yml" << EOF
springdoc:
  api-docs:
    path: /api-docs
  swagger-ui:
    path: /swagger-ui.html
    operationsSorter: method
    tagsSorter: alpha
EOF

    # Criar configuração do OpenAPI
    local config_dir="src/main/java/$(get_base_package_path)/config"
    mkdir -p "$config_dir"
    
    cat > "$config_dir/OpenApiConfig.java" << EOF
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {
    
    @Bean
    public OpenAPI springShopOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("Spring API")
                .description("Spring application API documentation")
                .version("v1.0.0"));
    }
}
EOF

    echo -e "${CYBER_GREEN}✔ Swagger configurado${RESET}"
}

# Geração de documentação técnica
generate_technical_docs() {
    echo -e "${CYBER_BLUE}Gerando documentação técnica...${RESET}"
    
    # Criar diretório de documentação
    mkdir -p "docs/technical"
    
    # Gerar arquivo principal
    cat > "docs/technical/README.md" << EOF
# Documentação Técnica

## Arquitetura

### Visão Geral
Este projeto segue uma arquitetura em camadas:
- Controllers (API REST)
- Services (Lógica de Negócio)
- Repositories (Acesso a Dados)

### Tecnologias
- Spring Boot
- Spring Data JPA
- Spring Security
- PostgreSQL

## Setup do Projeto

### Requisitos
- Java 17+
- Maven
- Docker

### Configuração
1. Clone o repositório
2. Configure as variáveis de ambiente
3. Execute \`mvn clean install\`

## Desenvolvimento

### Convenções de Código
- Seguimos o Google Java Style Guide
- Utilizamos Lombok para redução de boilerplate
- Documentação obrigatória para APIs públicas

### Fluxo de Trabalho
1. Criar branch feature/
2. Desenvolver e testar
3. Criar Pull Request
4. Code Review
5. Merge após aprovação
EOF

    echo -e "${CYBER_GREEN}✔ Documentação técnica gerada${RESET}"
}

# Geração de documentação de API
generate_api_docs() {
    echo -e "${CYBER_BLUE}Gerando documentação de API...${RESET}"
    
    # Criar diretório para documentação de API
    mkdir -p "docs/api"
    
    # Gerar arquivo principal
    cat > "docs/api/README.md" << EOF
# Documentação da API

## Endpoints

### Autenticação
\`\`\`
POST /api/auth/login
POST /api/auth/refresh
POST /api/auth/logout
\`\`\`

### Usuários
\`\`\`
GET    /api/users
POST   /api/users
PUT    /api/users/{id}
DELETE /api/users/{id}
\`\`\`

## Autenticação

### JWT
Todas as requisições devem incluir o header:
\`Authorization: Bearer {token}\`

## Erros
- 400: Bad Request
- 401: Unauthorized
- 403: Forbidden
- 404: Not Found
- 500: Internal Server Error
EOF

    echo -e "${CYBER_GREEN}✔ Documentação de API gerada${RESET}"
}

# Geração de changelog
generate_changelog() {
    echo -e "${CYBER_BLUE}Gerando changelog...${RESET}"
    
    # Criar arquivo de changelog
    cat > "CHANGELOG.md" << EOF
# Changelog

## [Unreleased]

## [1.0.0] - $(date +%Y-%m-%d)
### Added
- Funcionalidade inicial
- Autenticação JWT
- CRUD básico

### Changed
- Atualização de dependências
- Melhorias de performance

### Fixed
- Correções de bugs
EOF

    echo -e "${CYBER_GREEN}✔ Changelog gerado${RESET}"
}

# Atualização de documentação
update_docs() {
    echo -e "${CYBER_BLUE}Atualizando documentação...${RESET}"
    
    # Atualizar documentação técnica
    generate_technical_docs
    
    # Atualizar documentação de API
    generate_api_docs
    
    # Atualizar changelog
    generate_changelog
    
    echo -e "${CYBER_GREEN}✔ Documentação atualizada${RESET}"
}