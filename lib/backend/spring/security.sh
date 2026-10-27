#!/bin/bash

# Security audit functions
run_security_audit() {
    echo -e "${CYBER_BLUE}Executando auditoria de segurança...${RESET}"
    
    # Verificar dependências vulneráveis
    mvn dependency-check:check
    
    # Executar análise de código estática
    mvn spotbugs:check
    
    # Verificar configurações de segurança
    check_security_configurations
}

fix_security_issues() {
    echo -e "${CYBER_BLUE}Corrigindo problemas de segurança...${RESET}"
    
    # Atualizar dependências vulneráveis
    mvn versions:use-latest-versions
    
    # Aplicar correções automáticas
    apply_security_fixes
}

# Security scan functions
scan_dependencies() {
    echo -e "${CYBER_BLUE}Escaneando dependências...${RESET}"
    
    # Usar OWASP dependency-check
    mvn org.owasp:dependency-check-maven:check
}

scan_code_vulnerabilities() {
    echo -e "${CYBER_BLUE}Escaneando código fonte...${RESET}"
    
    # Executar SonarQube scan
    mvn sonar:sonar
}

# Security setup functions
setup_oauth_security() {
    echo -e "${CYBER_BLUE}Configurando OAuth2...${RESET}"
    
    # Adicionar dependências necessárias
    add_dependency "org.springframework.boot:spring-boot-starter-oauth2-client"
    add_dependency "org.springframework.security:spring-security-oauth2-jose"
    
    # Gerar configurações OAuth2
    generate_oauth2_config
}

setup_jwt_security() {
    echo -e "${CYBER_BLUE}Configurando JWT...${RESET}"
    
    # Adicionar dependências JWT
    add_dependency "io.jsonwebtoken:jjwt-api"
    add_dependency "io.jsonwebtoken:jjwt-impl"
    
    # Gerar classes e configurações JWT
    generate_jwt_config
}

# Funções auxiliares
check_security_configurations() {
    local config_file="src/main/resources/application.yml"
    
    echo -e "${CYBER_YELLOW}Verificando configurações de segurança...${RESET}"
    
    # Verificar HTTPS
    if ! grep -q "server.ssl" "$config_file"; then
        echo -e "${CYBER_RED}✘ HTTPS não configurado${RESET}"
    fi
    
    # Verificar CORS
    if ! grep -q "spring.security.cors" "$config_file"; then
        echo -e "${CYBER_RED}✘ CORS não configurado${RESET}"
    fi
    
    # Verificar headers de segurança
    if ! grep -q "security.headers" "$config_file"; then
        echo -e "${CYBER_RED}✘ Headers de segurança não configurados${RESET}"
    fi
}

generate_oauth2_config() {
    local config_dir="src/main/java/$(get_base_package_path)/config"
    mkdir -p "$config_dir"
    
    # Gerar classe de configuração OAuth2
    cat > "$config_dir/OAuth2Config.java" << EOF
@Configuration
@EnableWebSecurity
public class OAuth2Config extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
            .oauth2Login()
            .and()
            .authorizeRequests()
            .anyRequest().authenticated();
    }
}
EOF

    echo -e "${CYBER_GREEN}✔ Configuração OAuth2 gerada${RESET}"
}

generate_jwt_config() {
    local config_dir="src/main/java/$(get_base_package_path)/config"
    mkdir -p "$config_dir"
    
    # Gerar classe de configuração JWT
    cat > "$config_dir/JwtConfig.java" << EOF
@Configuration
public class JwtConfig {
    @Value("\${jwt.secret}")
    private String jwtSecret;
    
    @Value("\${jwt.expiration}")
    private int jwtExpiration;
    
    // Getters e métodos de utilidade JWT
}
EOF

    echo -e "${CYBER_GREEN}✔ Configuração JWT gerada${RESET}"
}
generate_security_report() {
    local report="${1:-security-report-$(date +%Y%m%d-%H%M%S).md}"
    local config_file="src/main/resources/application.yml"

    {
        echo "# Security Report"
        echo
        echo "Gerado em: $(date)"
        echo
        echo "## Configuração da aplicação"
        if [[ -f "$config_file" ]]; then
            for key in "server.ssl" "spring.security.cors" "security.headers"; do
                if grep -q "$key" "$config_file"; then
                    echo "- ${key}: configurado"
                else
                    echo "- ${key}: ausente"
                fi
            done
        else
            echo "- ${config_file}: não encontrado"
        fi
        echo
        echo "## Dockerfile"
        if [[ -f Dockerfile ]]; then
            echo "- Presente"
        else
            echo "- Ausente"
        fi
    } > "$report"

    echo -e "${CYBER_GREEN}✔ Relatório gerado: ${report}${RESET}"
}

scan_docker_security() {
    local dockerfile="${1:-Dockerfile}"
    local issues=0

    if [[ ! -f "$dockerfile" ]]; then
        echo -e "${CYBER_RED}✘ Dockerfile não encontrado: ${dockerfile}${RESET}"
        return 1
    fi

    echo -e "${CYBER_BLUE}Escaneando ${dockerfile}...${RESET}"

    if grep -qiE '^[[:space:]]*USER[[:space:]]+root' "$dockerfile"; then
        echo -e "${CYBER_RED}✘ Container executa como root${RESET}"
        issues=$((issues + 1))
    fi

    if grep -qE '^[[:space:]]*FROM[[:space:]]+.*:latest' "$dockerfile"; then
        echo -e "${CYBER_RED}✘ Imagem base usa tag latest${RESET}"
        issues=$((issues + 1))
    fi

    if grep -qiE '^[[:space:]]*ENV[[:space:]]+.*(PASSWORD|SECRET|TOKEN)=' "$dockerfile"; then
        echo -e "${CYBER_RED}✘ Possível segredo embutido no Dockerfile${RESET}"
        issues=$((issues + 1))
    fi

    if [[ $issues -eq 0 ]]; then
        echo -e "${CYBER_GREEN}✔ Nenhum problema óbvio encontrado${RESET}"
        return 0
    fi

    echo -e "${CYBER_YELLOW}Total de achados: ${issues}${RESET}"
    return 1
}

setup_keycloak_integration() {
    local config_dir="src/main/resources"

    echo -e "${CYBER_BLUE}Configurando Keycloak...${RESET}"

    add_dependency "org.springframework.boot:spring-boot-starter-oauth2-client" || return $?

    mkdir -p "$config_dir"
    cat > "$config_dir/application-keycloak.yml" << 'EOF'
spring:
  security:
    oauth2:
      client:
        registration:
          keycloak:
            client-id: ${KEYCLOAK_CLIENT_ID}
            client-secret: ${KEYCLOAK_CLIENT_SECRET}
            scope: openid,profile,email
            authorization-grant-type: authorization_code
        provider:
          keycloak:
            issuer-uri: ${KEYCLOAK_ISSUER_URI}
EOF

    echo -e "${CYBER_GREEN}✔ Configuração gerada em ${config_dir}/application-keycloak.yml${RESET}"
    echo -e "${CYBER_YELLOW}Ative o profile keycloak e defina as variáveis KEYCLOAK_*${RESET}"
}

apply_security_fixes() {
    echo -e "${CYBER_YELLOW}Revise os achados da auditoria e atualize dependências/configurações manualmente${RESET}"
}
