# Flux - Terminal API Studio

> Em desenvolvimento 🚧

> "Seu estúdio de APIs direto no terminal. Simples. Poderoso. Cyberpunk."

## Visão Geral

Flux é um estúdio de APIs completo em interface terminal, combinando a velocidade da CLI com a intuitividade de ferramentas GUI como Insomnia e Postman.

## Quick Start

```bash
# Iniciar interface Flux
bytebabe flux

# Modo rápido com último workspace
bytebabe flux quick

# Abrir workspace específico
bytebabe flux open my-api
```

## Interface Principal

```ascii
┌─ 🌊 FLUX API STUDIO ──────────────────────────┐
│ [1] Collections  [2] Environment  [3] Console  │
├────────────────────────────────────────────────┤
│ GET  https://api.example.com/users            │
│ Headers                                       │
│ Authorization: Bearer {{token}}               │
│                                              │
│ Body                                         │
│ {                                            │
│   "name": "{{user.name}}"                    │
│ }                                            │
├────────────────────────────────────────────────┤
│ Response: 200 OK (45ms)                       │
└────────────────────────────────────────────────┘
```

## Características Principais

### 🗂️ Organização
- Collections em árvore
- Ambientes múltiplos
- Variáveis globais/locais
- Tags e favoritos

### ⚡ Edição Rápida
- Atalhos vim-style
- Autocompleção inteligente
- Syntax highlighting
- Formatação automática

### 🔄 Requests
- REST/GraphQL/gRPC
- WebSocket/SSE
- Autenticação múltipla
- Chain de requests

### 🎨 Visual
- Temas cyberpunk
- Cores customizáveis
- Layouts flexíveis
- Modo compacto

## Atalhos do Teclado

| Atalho | Ação |
|--------|------|
| `Ctrl+S` | Salvar request |
| `Ctrl+Space` | Autocompletar |
| `Ctrl+Enter` | Enviar request |
| `Ctrl+/` | Busca global |
| `F5` | Recarregar |
| `Esc` | Menu principal |

## Modos de Visualização

| Modo | Descrição | Atalho |
|------|-----------|--------|
| Split | Editor + Response | `F2` |
| Editor | Apenas editor | `F3` |
| Preview | Visualização | `F4` |
| Console | Debug mode | `F5` |

## Próximos Passos

- [🧪 Testing](flux-testing.md)
- [📚 Documentation](flux-docs.md)
- [📊 Monitoring](flux-monitor.md)
- [🔒 Security](flux-security.md)