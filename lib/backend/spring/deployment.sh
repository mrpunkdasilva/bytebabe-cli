#!/bin/bash

# Kubernetes deployment
setup_kubernetes_deployment() {
    echo -e "${CYBER_BLUE}Configurando deployment Kubernetes...${RESET}"
    
    # Criar diretório k8s
    mkdir -p k8s
    
    # Gerar arquivo de deployment
    cat > "k8s/deployment.yml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: spring-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: spring-app
  template:
    metadata:
      labels:
        app: spring-app
    spec:
      containers:
      - name: spring-app
        image: spring-app:latest
        ports:
        - containerPort: 8080
EOF

    # Gerar arquivo de service
    cat > "k8s/service.yml" << EOF
apiVersion: v1
kind: Service
metadata:
  name: spring-app
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: spring-app
EOF

    echo -e "${CYBER_GREEN}✔ Configuração Kubernetes gerada${RESET}"
}

apply_k8s_manifests() {
    echo -e "${CYBER_BLUE}Aplicando manifestos Kubernetes...${RESET}"
    
    kubectl apply -f k8s/
    
    echo -e "${CYBER_GREEN}✔ Manifestos aplicados${RESET}"
}

rollback_deployment() {
    local version="$1"
    
    echo -e "${CYBER_BLUE}Realizando rollback para versão ${version}...${RESET}"
    
    kubectl rollout undo deployment/spring-app --to-revision=$version
    
    echo -e "${CYBER_GREEN}✔ Rollback realizado${RESET}"
}

# Cloud deployment functions
deploy_to_aws() {
    echo -e "${CYBER_BLUE}Realizando deploy para AWS...${RESET}"
    
    # Verificar credenciais AWS
    if ! aws sts get-caller-identity &>/dev/null; then
        echo -e "${CYBER_RED}✘ Credenciais AWS não configuradas${RESET}"
        return 1
    }
    
    # Criar arquivo de configuração do Elastic Beanstalk
    mkdir -p .elasticbeanstalk
    cat > ".elasticbeanstalk/config.yml" << EOF
branch-defaults:
  main:
    environment: spring-app-prod
environment-defaults:
  spring-app-prod:
    branch: null
    repository: null
global:
  application_name: spring-app
  default_ec2_keyname: null
  default_platform: Java 17
  default_region: us-east-1
  include_git_submodules: true
  instance_profile: null
  platform_name: null
  platform_version: null
  profile: null
  sc: git
  workspace_type: Application
EOF

    # Deploy usando Elastic Beanstalk
    eb deploy
    
    echo -e "${CYBER_GREEN}✔ Deploy para AWS concluído${RESET}"
}

deploy_to_gcp() {
    echo -e "${CYBER_BLUE}Realizando deploy para GCP...${RESET}"
    
    # Verificar autenticação GCP
    if ! gcloud auth list &>/dev/null; then
        echo -e "${CYBER_RED}✘ Autenticação GCP não configurada${RESET}"
        return 1
    }
    
    # Gerar arquivo app.yaml para App Engine
    cat > "app.yaml" << EOF
runtime: java17
env: standard
instance_class: F2
handlers:
  - url: /.*
    script: auto
automatic_scaling:
  target_cpu_utilization: 0.65
  min_instances: 1
  max_instances: 10
EOF

    # Deploy usando App Engine
    gcloud app deploy
    
    echo -e "${CYBER_GREEN}✔ Deploy para GCP concluído${RESET}"
}

deploy_to_azure() {
    echo -e "${CYBER_BLUE}Realizando deploy para Azure...${RESET}"
    
    # Verificar login Azure
    if ! az account show &>/dev/null; then
        echo -e "${CYBER_RED}✘ Login Azure não realizado${RESET}"
        return 1
    }
    
    # Deploy usando Azure App Service
    az webapp up \
        --name spring-app \
        --resource-group spring-app-rg \
        --runtime "JAVA:17-java17" \
        --sku B1
    
    echo -e "${CYBER_GREEN}✔ Deploy para Azure concluído${RESET}"
}