# Development Tools 🛠️

O módulo DevTools do ByteBabe oferece instalação e configuração automatizada de ferramentas essenciais para desenvolvimento.

## Categorias de Ferramentas

### Terminal Tools
- Zsh + Oh My Zsh
- Spaceship Prompt
- Plugins (autosuggestions, syntax highlighting, etc)

### Database Tools
- TablePlus
- DBeaver
- MongoDB Compass
- pgAdmin
- MySQL Workbench

### API Tools
- Ferramentas de Teste (curl, httpie, jq, yq, grpcurl, websocat)
- Documentação (Swagger CLI, OpenAPI Generator, Redoc CLI, Spectral)
- Proxy/Debug (mitmproxy, ngrok, wireshark)
- GUI (Postman, Insomnia, Bruno)

### Browser Tools
- Google Chrome
- Firefox
- Brave
- Microsoft Edge
- Vivaldi

## Uso

```bash
# Modo interativo
bytebabe devtools

# Instalação direta
bytebabe devtools [categoria] [ferramenta]

# Exemplos:
bytebabe devtools terminal all      # Instala todas as ferramentas de terminal
bytebabe devtools database dbeaver  # Instala apenas o DBeaver
bytebabe devtools api --test        # Instala ferramentas de teste de API
```

## Características

- Instalação automatizada
- Detecção do gerenciador de pacotes (apt, dnf, pacman)
- Configuração pré-otimizada
- Interface cyberpunk interativa