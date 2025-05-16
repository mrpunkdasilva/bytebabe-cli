# Firewall Module

> "Segurança com estilo cyberpunk"

## Visão Geral

O módulo Firewall do ByteBabe oferece uma interface intuitiva para gerenciar o UFW (Uncomplicated Firewall) com perfis predefinidos e monitoramento em tempo real.

## Comandos Principais

```bash
# Ver status do firewall
bytebabe firewall status

# Ativar firewall
bytebabe firewall enable

# Configurar perfil
bytebabe firewall setup

# Adicionar regra
bytebabe firewall add
```

## Recursos Principais

- Perfis predefinidos (Dev, DevOps, Security)
- Gerenciamento visual de regras
- Monitoramento em tempo real
- Backup e restore de configurações
- Interface CLI intuitiva

## Perfis Disponíveis

| Perfil | Descrição |
|--------|-----------|
| Developer | Portas para desenvolvimento web |
| DevOps | Configuração para Docker, K8s, etc |
| Security | Regras restritas de segurança |

## Próximos Passos

- [🔒 Perfis de Segurança](security-profiles.md)
- [📋 Gerenciamento de Regras](rule-management.md)
- [⚙️ Recursos Avançados](advanced-features.md)
- [📊 Monitoramento](firewall-monitoring.md)