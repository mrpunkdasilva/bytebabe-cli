# SSL Configuration 🔒

## Configuração SSL

O suporte SSL está disponível na porta 4430 e pode ser configurado para ambos os servidores.

## Diretório SSL

Os certificados devem ser colocados em:
```
docker/ssl/
```

## Volumes SSL

Os certificados são montados automaticamente:
```yaml
volumes:
  - "./docker/ssl:/ssl"
```

## Próximos Passos

1. Gerar certificados SSL
2. Configurar virtual hosts
3. Testar conexões HTTPS