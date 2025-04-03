# Gerenciamento de Regras 📋

## Comandos Básicos

```bash
# Listar regras
bytebabe firewall list

# Adicionar regra
bytebabe firewall add

# Remover regra
bytebabe firewall remove

# Resetar regras
bytebabe firewall reset
```

## Adicionando Regras

### Interface Interativa
```bash
bytebabe firewall add
> Enter port number: 80
> Enter protocol (tcp/udp): tcp
> Enter action (allow/deny): allow
```

### Exemplos Comuns

```bash
# Permitir SSH
Port: 22
Protocol: tcp
Action: allow

# Bloquear porta
Port: 3306
Protocol: tcp
Action: deny
```

## Gerenciamento em Lote

```bash
# Backup de regras
bytebabe firewall backup

# Restaurar regras
bytebabe firewall restore

# Importar regras
bytebabe firewall import rules.conf
```

## Boas Práticas

1. Documente todas as regras
2. Use perfis predefinidos
3. Faça backup regularmente
4. Teste antes de aplicar