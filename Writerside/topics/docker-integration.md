# Docker Integration

## Compose Configuration

O ByteBabe usa Docker Compose para gerenciar os servidores web:

```yaml
services:
  apache:
    image: httpd:latest
    container_name: "bytebabe_servers_apache"
    ports:
      - "8080:80"
    volumes:
      - "./docker/apache:/usr/local/apache2/htdocs"
    networks:
      - bytebabe_net

  nginx:
    image: nginx:latest
    container_name: "bytebabe_servers_nginx"
    ports:
      - "8081:80"
      - "4430:443"
    volumes:
      - "./docker/nginx:/usr/share/nginx/html"
    networks:
      - bytebabe_net

networks:
  bytebabe_net:
    driver: bridge
```

## Recursos Docker

- Containers isolados
- Rede dedicada
- Volumes persistentes
- Health checks
- Restart policies