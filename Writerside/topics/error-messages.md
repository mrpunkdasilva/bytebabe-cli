# Error Messages

## Formato dos Erros

```ascii
┌─ ByteBabe Error ──────────────────────────┐
│ 🔴 ERROR-001: Permission Denied           │
│                                          │
│ Details: Unable to access docker socket   │
│ Location: docker/client.rs:42            │
│ Solution: Add user to docker group        │
└──────────────────────────────────────────┘
```

## Catálogo de Erros

### Docker (DOCK-XXX)
| Código | Mensagem | Solução |
|--------|----------|---------|
| DOCK-001 | Permission denied | Adicionar usuário ao grupo docker |
| DOCK-002 | Port in use | Mudar porta ou parar serviço |
| DOCK-003 | Image not found | Pull da imagem ou verificar nome |

### Git (GIT-XXX)
| Código | Mensagem | Solução |
|--------|----------|---------|
| GIT-001 | Not a git repository | Inicializar repo ou verificar path |
| GIT-002 | Merge conflict | Resolver conflitos manualmente |
| GIT-003 | Branch not found | Verificar nome da branch |

### Database (DB-XXX)
| Código | Mensagem | Solução |
|--------|----------|---------|
| DB-001 | Connection failed | Verificar credenciais e host |
| DB-002 | Backup failed | Checar permissões e espaço |
| DB-003 | Query error | Validar sintaxe SQL |

### Network (NET-XXX)
| Código | Mensagem | Solução |
|--------|----------|---------|
| NET-001 | Port blocked | Verificar firewall |
| NET-002 | SSL error | Renovar certificado |
| NET-003 | DNS error | Verificar resolução |

## Debug Mode

```bash
# Ativar modo debug
bytebabe --debug

# Ver stack trace
bytebabe --trace

# Log detalhado
bytebabe --verbose
```

## Error Reporting

### Automatic Report
```bash
# Enviar relatório
bytebabe report error DOCK-001

# Com detalhes
bytebabe report error DOCK-001 --details
```

### Manual Collection
1. Logs: `~/.bytebabe/logs/`
2. Config: `~/.bytebabe/config/`
3. System info: `bytebabe system info`