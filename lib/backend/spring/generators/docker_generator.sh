#!/bin/bash

# Gera arquivos Docker
generate_docker_files() {
    # Gera Dockerfile
    cat > "Dockerfile" << EOF
FROM eclipse-temurin:17-jdk-alpine
VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
EOF

    # Gera docker-compose.yml
    cat > "docker-compose.yml" << EOF
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - SPRING_PROFILES_ACTIVE=docker
    depends_on:
      - db
  
  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=appdb
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=apppass
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
EOF

    # Gera .dockerignore
    cat > ".dockerignore" << EOF
.git
.gitignore
README.md
HELP.md
target/
!target/*.jar
EOF

    echo -e "${CYBER_GREEN}✔ Arquivos Docker gerados com sucesso${RESET}"
}