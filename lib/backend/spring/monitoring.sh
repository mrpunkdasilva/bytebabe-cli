#!/bin/bash

# Prometheus setup
setup_prometheus_monitoring() {
    echo -e "${CYBER_BLUE}Configurando Prometheus...${RESET}"
    
    # Adicionar dependências
    add_dependency "org.springframework.boot:spring-boot-starter-actuator"
    add_dependency "io.micrometer:micrometer-registry-prometheus"
    
    # Criar configuração do Prometheus
    cat > "prometheus.yml" << EOF
global:
  scrape_interval: 15s
scrape_configs:
  - job_name: 'spring-app'
    metrics_path: '/actuator/prometheus'
    static_configs:
      - targets: ['localhost:8080']
EOF

    # Adicionar ao docker-compose
    cat >> "docker-compose.yml" << EOF
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    depends_on:
      - app
EOF

    echo -e "${CYBER_GREEN}✔ Prometheus configurado${RESET}"
}

# Grafana setup
setup_grafana_dashboard() {
    echo -e "${CYBER_BLUE}Configurando Grafana...${RESET}"
    
    # Adicionar Grafana ao docker-compose
    cat >> "docker-compose.yml" << EOF
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=cyberpunk
    depends_on:
      - prometheus
EOF

    # Criar dashboard padrão
    mkdir -p grafana/dashboards
    generate_default_dashboard

    echo -e "${CYBER_GREEN}✔ Grafana configurado${RESET}"
}

# ELK Stack setup
setup_elk_stack() {
    echo -e "${CYBER_BLUE}Configurando ELK Stack...${RESET}"
    
    # Adicionar dependência do Logstash
    add_dependency "net.logstash.logback:logstash-logback-encoder"
    
    # Configurar logback-spring.xml
    generate_logback_config
    
    # Adicionar ELK ao docker-compose
    cat >> "docker-compose.yml" << EOF
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.15.0
    environment:
      - discovery.type=single-node
    ports:
      - "9200:9200"
    
  logstash:
    image: docker.elastic.co/logstash/logstash:7.15.0
    ports:
      - "5000:5000"
    depends_on:
      - elasticsearch
    
  kibana:
    image: docker.elastic.co/kibana/kibana:7.15.0
    ports:
      - "5601:5601"
    depends_on:
      - elasticsearch
EOF

    echo -e "${CYBER_GREEN}✔ ELK Stack configurado${RESET}"
}

# Metrics management
enable_application_metrics() {
    echo -e "${CYBER_BLUE}Habilitando métricas da aplicação...${RESET}"
    
    # Configurar application.yml
    cat >> "src/main/resources/application.yml" << EOF
management:
  endpoints:
    web:
      exposure:
        include: "*"
  endpoint:
    health:
      show-details: always
    metrics:
      enabled: true
    prometheus:
      enabled: true
EOF

    echo -e "${CYBER_GREEN}✔ Métricas habilitadas${RESET}"
}

add_custom_metrics() {
    local metric_name="$1"
    local metric_type="$2"
    
    echo -e "${CYBER_BLUE}Adicionando métrica customizada: ${metric_name}${RESET}"
    
    # Gerar classe de métrica
    local config_dir="src/main/java/$(get_base_package_path)/metrics"
    mkdir -p "$config_dir"
    
    cat > "$config_dir/${metric_name}Metric.java" << EOF
@Component
public class ${metric_name}Metric {
    private final MeterRegistry registry;

    public ${metric_name}Metric(MeterRegistry registry) {
        this.registry = registry;
    }

    @Scheduled(fixedRate = 60000)
    public void record() {
        // Implementação da métrica
    }
}
EOF

    echo -e "${CYBER_GREEN}✔ Métrica ${metric_name} adicionada${RESET}"
}

# Alert management
setup_alert_rules() {
    echo -e "${CYBER_BLUE}Configurando regras de alerta...${RESET}"
    
    # Criar arquivo de regras do Prometheus
    cat > "alert-rules.yml" << EOF
groups:
  - name: app_alerts
    rules:
      - alert: HighRequestLatency
        expr: http_server_requests_seconds_max > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High request latency detected
EOF

    echo -e "${CYBER_GREEN}✔ Regras de alerta configuradas${RESET}"
}

add_custom_alert() {
    local alert_name="$1"
    local condition="$2"
    local threshold="$3"
    
    echo -e "${CYBER_BLUE}Adicionando alerta: ${alert_name}${RESET}"
    
    # Adicionar nova regra ao arquivo de alertas
    cat >> "alert-rules.yml" << EOF
      - alert: ${alert_name}
        expr: ${condition} > ${threshold}
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: ${alert_name} threshold exceeded
EOF

    echo -e "${CYBER_GREEN}✔ Alerta ${alert_name} adicionado${RESET}"
}
generate_default_dashboard() {
    local dashboard_dir="grafana/dashboards"

    mkdir -p "$dashboard_dir"
    cat > "${dashboard_dir}/spring-app.json" << 'EOF'
{
  "title": "Spring App",
  "panels": [
    {
      "type": "timeseries",
      "title": "Requisições por segundo",
      "targets": [
        {
          "expr": "rate(http_server_requests_seconds_count[1m])"
        }
      ]
    },
    {
      "type": "timeseries",
      "title": "Latência média",
      "targets": [
        {
          "expr": "rate(http_server_requests_seconds_sum[1m]) / rate(http_server_requests_seconds_count[1m])"
        }
      ]
    }
  ]
}
EOF

    echo -e "${CYBER_GREEN}✔ Dashboard padrão criado em ${dashboard_dir}/spring-app.json${RESET}"
}

generate_logback_config() {
    local resources_dir="src/main/resources"

    mkdir -p "$resources_dir"
    cat > "${resources_dir}/logback-spring.xml" << 'EOF'
<configuration>
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/application.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/application.%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} %-5level [%thread] %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>

    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="FILE"/>
    </root>
</configuration>
EOF

    echo -e "${CYBER_GREEN}✔ Configuração de logs criada em ${resources_dir}/logback-spring.xml${RESET}"
}

export_metrics_data() {
    local url="${SPRING_ACTUATOR_URL:-http://localhost:8080/actuator/metrics}"
    local output="${1:-metrics-export-$(date +%Y%m%d-%H%M%S).json}"

    if ! command -v curl &>/dev/null; then
        echo -e "${CYBER_RED}✘ curl não encontrado${RESET}"
        return 1
    fi

    if ! curl -fsS "$url" -o "$output"; then
        echo -e "${CYBER_RED}✘ Não foi possível exportar métricas de ${url}${RESET}"
        rm -f "$output"
        return 1
    fi

    echo -e "${CYBER_GREEN}✔ Métricas exportadas para ${output}${RESET}"
}

setup_log_aggregation() {
    generate_logback_config
    echo -e "${CYBER_YELLOW}Envie logs/application.log para o agregador configurado${RESET}"
}

analyze_log_patterns() {
    local log_dir="${1:-logs}"
    local errors warnings

    if [[ ! -d "$log_dir" ]]; then
        echo -e "${CYBER_RED}✘ Diretório de logs não encontrado: ${log_dir}${RESET}"
        return 1
    fi

    errors=$(grep -RhiE 'ERROR|Exception' "$log_dir" 2>/dev/null | wc -l)
    warnings=$(grep -RhiE 'WARN' "$log_dir" 2>/dev/null | wc -l)

    echo -e "${CYBER_BLUE}Análise de logs em ${log_dir}${RESET}"
    echo -e "  ${CYBER_RED}Erros: ${errors}${RESET}"
    echo -e "  ${CYBER_YELLOW}Alertas: ${warnings}${RESET}"
}

export_log_data() {
    local log_dir="${1:-logs}"
    local output="${2:-logs-export-$(date +%Y%m%d-%H%M%S).tar.gz}"

    if [[ ! -d "$log_dir" ]]; then
        echo -e "${CYBER_RED}✘ Diretório de logs não encontrado: ${log_dir}${RESET}"
        return 1
    fi

    if ! tar -czf "$output" -C "$log_dir" .; then
        echo -e "${CYBER_RED}✘ Falha ao exportar logs${RESET}"
        return 1
    fi

    echo -e "${CYBER_GREEN}✔ Logs exportados para ${output}${RESET}"
}

list_alert_rules() {
    local rules_file="alert-rules.yml"

    if [[ ! -f "$rules_file" ]]; then
        echo -e "${CYBER_RED}✘ Arquivo de regras não encontrado: ${rules_file}${RESET}"
        return 1
    fi

    grep -E '^[[:space:]]*- alert:' "$rules_file" | sed 's/^[[:space:]]*- alert:[[:space:]]*//'
}
