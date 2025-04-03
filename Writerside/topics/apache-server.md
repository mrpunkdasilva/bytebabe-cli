# Apache Server 🚀

## Configuração

O servidor Apache é configurado automaticamente com as seguintes especificações:

```yaml
apache:
  image: httpd:latest
  ports:
    - "8080:80"
  volumes:
    - "./docker/apache:/usr/local/apache2/htdocs"
    - "./docker/ssl:/ssl"
```

## Comandos

```bash
# Iniciar Apache
bytebabe servers up apache

# Parar Apache
bytebabe servers down apache

# Ver status
bytebabe servers status apache
```

## Diretório de Conteúdo

O conteúdo web deve ser colocado em:
```
docker/apache/
```