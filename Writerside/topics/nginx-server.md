# Nginx Server 🔄

## Configuração

O Nginx é configurado com as seguintes especificações:

```yaml
nginx:
  image: nginx:latest
  ports:
    - "8081:80"
    - "4430:443"
  volumes:
    - "./docker/nginx:/usr/share/nginx/html"
    - "./docker/ssl:/ssl"
    - "./docker/nginx/nginx.conf:/etc/nginx/nginx.conf:ro"
```

## Comandos

```bash
# Iniciar Nginx
bytebabe servers up nginx

# Parar Nginx
bytebabe servers down nginx

# Ver status
bytebabe servers status nginx
```

## Arquivo de Configuração

O Nginx usa uma configuração padrão otimizada que inclui:
- Worker processes automáticos
- Buffer sizes otimizados
- Configuração de logs
- Timeouts adequados