# Perfis de Segurança 🔒

## Developer Profile

Ideal para desenvolvimento web local.

```bash
bytebabe firewall setup
> Select profile: 1
```

### Portas Permitidas
- HTTP (80)
- HTTPS (443)
- React/Node (3000-3999)
- Django/Spring (8000-8999)
- Angular (4200)
- Vite (5173)

## DevOps Profile

Configurado para ambientes de DevOps.

```bash
bytebabe firewall setup
> Select profile: 2
```

### Portas Permitidas
- Docker (2375-2377)
- Kubernetes (6443, 10250-10252)
- Jenkins (8080)
- Prometheus (9090)
- Grafana (3000)

## Security Profile

Configuração restritiva para máxima segurança.

```bash
bytebabe firewall setup
> Select profile: 3
```

### Características
- Logging completo
- Deny por padrão
- Rate limiting
- Apenas serviços essenciais
- Monitoramento avançado