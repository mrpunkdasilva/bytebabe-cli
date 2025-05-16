# Monitoramento do Firewall

## Dashboard em Tempo Real

```bash
# Iniciar dashboard
bytebabe firewall monitor

# Modo detalhado
bytebabe firewall monitor --detailed
```
 
## Métricas Disponíveis

| Métrica | Descrição |
|---------|-----------|
| Conexões | Conexões ativas |
| Pacotes | Pacotes processados |
| Drops | Conexões bloqueadas |
| Bandwidth | Uso de banda |

## Alertas

Configure alertas para:
- Tentativas de invasão
- Portas não autorizadas
- Tráfego anormal
- Falhas de regras

```yaml
alerts:
  brute_force: true
  port_scan: true
  ddos: true
  threshold: 1000
```

## Logs

```bash
# Ver logs em tempo real
bytebabe firewall log --follow

# Filtrar por tipo
bytebabe firewall log --type blocked

# Exportar relatório
bytebabe firewall report export
```

## Integração

Suporte a exportação para:
- Grafana
- ELK Stack
- Prometheus
- Nagios