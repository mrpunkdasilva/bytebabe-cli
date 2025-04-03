# Recursos Avançados ⚙️

## Rate Limiting

Controle de taxa de conexões:

```bash
# Configurar rate limit para SSH
bytebabe firewall limit ssh

# Limite personalizado
bytebabe firewall limit 80/tcp --rate 100/min
```

## Port Forwarding

```bash
# Configurar redirecionamento
bytebabe firewall forward
> Source port: 80
> Destination IP: 192.168.1.100
> Destination port: 8080
```

## Bloqueio de IP

```bash
# Bloquear range de IPs
bytebabe firewall block
> Enter IP range: 192.168.1.0/24

# Whitelist
bytebabe firewall allow 10.0.0.0/8
```

## Backup e Restore

```bash
# Backup completo
bytebabe firewall backup rules.conf

# Restore seletivo
bytebabe firewall restore --rules "ssh,http"
```

## Logging Avançado

```bash
# Ativar log detalhado
bytebabe firewall log --level full

# Exportar logs
bytebabe firewall log export
```