# Guia de Instalação: ByteBabe CLI

![ByteBabe Logo](https://github.com/user-attachments/assets/924b4161-f63a-4ec3-bebb-00d74eff7b73)

## 1. Introdução

### 1.1 O que é o ByteBabe CLI?

ByteBabe é uma assistente de linha de comando (CLI) com tema cyberpunk desenvolvida para programadores. Ela transforma tarefas rotineiras de desenvolvimento em interações mais agradáveis e eficientes, sem comprometer a funcionalidade profissional. Com uma interface estilizada e recursos poderosos, o ByteBabe torna o trabalho no terminal mais produtivo e divertido.

A ferramenta foi projetada para desenvolvedores que passam muito tempo no terminal e desejam uma experiência mais moderna e agradável, sem perder a eficiência que as interfaces de linha de comando proporcionam.

### 1.2 Principais recursos

- **Interface cyberpunk estilizada**: Visual moderno e atraente para seu terminal
- **Automação inteligente de tarefas**: Simplifica fluxos de trabalho comuns
- **Gerenciamento Docker simplificado**: Facilita operações com containers
- **Ferramentas de desenvolvimento integradas**: Tudo que você precisa em um só lugar
- **Experiência única de usuário**: Torna o trabalho no terminal mais agradável
- **Módulos especializados**: Git, Docker, servidores web, bancos de dados e mais
- **Personalização avançada**: Adapte a ferramenta ao seu fluxo de trabalho
- **Suporte a scripts e automação**: Crie seus próprios comandos e fluxos

### 1.3 Requisitos do sistema

Antes de iniciar a instalação, certifique-se de que seu sistema atende aos seguintes requisitos:

- Sistema operacional Linux/Unix ou macOS (não compatível com Windows)
- Bash 4 ou superior
- Git (recomendado)
- curl ou wget
- Docker (opcional, mas recomendado para recursos avançados)
- Terminal com suporte a cores
- Permissões de sudo (quando necessário)
- Conexão com internet
- Mínimo de 100MB de espaço em disco
- 512MB de RAM disponível (para operações com Docker)

## 2. Instalação

O ByteBabe CLI pode ser instalado de duas maneiras: através do script de instalação automática ou manualmente. Ambos os métodos são detalhados abaixo.

### 2.1 Instalação automática (recomendada)

A maneira mais rápida e fácil de instalar o ByteBabe é usando o script de instalação automática.

1. Abra seu terminal
2. Execute o seguinte comando:

```bash
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe/main/install.sh | bash
```

![Instalação Automática](https://exemplo.com/imagens/instalacao-automatica.png)

O script detectará automaticamente seu sistema operacional e instalará todas as dependências necessárias. Durante o processo, você poderá ver uma saída semelhante a esta:

```
🔮 ByteBabe CLI Installer 🔮
------------------------------
✓ Verificando sistema operacional: Ubuntu 22.04
✓ Verificando dependências...
✓ Baixando arquivos necessários...
✓ Instalando ByteBabe CLI...
✓ Configurando ambiente...
✓ Adicionando ao PATH...

🎉 Instalação concluída! 🎉
Digite 'bytebabe --help' para começar.
```

O processo de instalação automática realiza as seguintes etapas:

1. Verifica a compatibilidade do sistema operacional
2. Instala dependências necessárias (se faltantes)
3. Baixa os arquivos do ByteBabe
4. Configura o ambiente e variáveis de sistema
5. Adiciona o ByteBabe ao PATH do sistema

### 2.2 Instalação manual

Se preferir ter mais controle sobre o processo de instalação, você pode optar pelo método manual:

1. Clone o repositório do GitHub:
```bash
git clone https://github.com/mrpunkdasilva/bytebabe.git
```

2. Navegue até o diretório do projeto:
```bash
cd bytebabe
```

3. Execute o script de instalação:
```bash
./install.sh
```

![Instalação Manual](https://exemplo.com/imagens/instalacao-manual.png)

A instalação manual oferece algumas vantagens:
- Controle total sobre o processo de instalação
- Possibilidade de examinar o código antes da execução
- Opção de modificar parâmetros de instalação
- Facilidade para contribuir com o desenvolvimento

Durante a instalação manual, você pode ser solicitado a fornecer informações adicionais, como o diretório de instalação preferido ou configurações específicas para seu ambiente.

### 2.3 Instalação para ambientes específicos

#### 2.3.1 Ubuntu/Debian

Para sistemas baseados em Debian, você pode precisar instalar algumas dependências adicionais:

```bash
sudo apt update
sudo apt install -y git curl wget jq
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe/main/install.sh | bash
```

#### 2.3.2 macOS

No macOS, recomendamos usar o Homebrew para gerenciar dependências:

```bash
# Instalar Homebrew (se ainda não tiver)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalar dependências
brew install git curl jq

# Instalar ByteBabe
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe/main/install.sh | bash
```

#### 2.3.3 Fedora/RHEL/CentOS

Para sistemas baseados em Red Hat:

```bash
sudo dnf install -y git curl wget jq
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe/main/install.sh | bash
```

### 2.4 Verificando a instalação

Para confirmar que o ByteBabe foi instalado corretamente, execute:

```bash
bytebabe --version
```

Se a instalação foi bem-sucedida, você verá uma mensagem como:
```
ByteBabe CLI v1.0.0 (⌐■_■)
```

![Verificação da Instalação](https://exemplo.com/imagens/verificacao-instalacao.png)

Você também pode verificar se todos os componentes foram instalados corretamente com:

```bash
bytebabe doctor
```

Este comando realizará uma verificação completa do sistema e mostrará um relatório detalhado:

```
🩺 ByteBabe System Check 🩺
---------------------------
✓ Versão do ByteBabe: v1.0.0
✓ Sistema operacional: Ubuntu 22.04
✓ Bash: 5.1.16
✓ Git: 2.34.1
✓ Docker: 24.0.5
✓ Permissões: OK
✓ Configuração: OK
✓ Dependências: Todas instaladas

Diagnóstico: Sistema saudável! 
```

## 3. Configuração inicial

Após a instalação, é recomendável executar a configuração inicial para personalizar o ByteBabe de acordo com suas preferências.

### 3.1 Executando a configuração inicial

Execute o comando:

```bash
bytebabe init
```

Este comando iniciará um assistente interativo que guiará você pelas opções de configuração.

![Configuração Inicial](https://exemplo.com/imagens/configuracao-inicial.png)

O assistente de configuração permite personalizar:

- Tema visual (Cyberpunk, Synthwave, Matrix, Minimal)
- Aliases personalizados para comandos frequentes
- Integração com ferramentas de desenvolvimento
- Configurações de Docker e containers
- Preferências de terminal e shell

Exemplo de interação com o assistente:

```
🌟 ByteBabe Setup Wizard 🌟
--------------------------
Vamos personalizar sua experiência!

Selecione um tema visual:
1) Cyberpunk (padrão)
2) Synthwave
3) Matrix
4) Minimal
> 1

Configurar integração com Git? [S/n] S
✓ Integração Git configurada!

Configurar Docker? [S/n] S
✓ Integração Docker configurada!

Instalar ferramentas de desenvolvimento? [S/n] S
Selecione as ferramentas:
[x] Zsh + Oh My Zsh
[x] Docker tools
[ ] Database tools
[x] API tools
[ ] Browser tools
> Confirmar

Configuração concluída! 🎉
```

### 3.2 Configurando ferramentas de desenvolvimento

O ByteBabe oferece um conjunto de ferramentas de desenvolvimento que podem ser instaladas e configuradas automaticamente:

```bash
bytebabe devtools
```

Este comando abrirá um menu interativo onde você poderá selecionar as ferramentas que deseja instalar.

![Ferramentas de Desenvolvimento](https://exemplo.com/imagens/ferramentas-desenvolvimento.png)

As ferramentas disponíveis incluem:

#### 3.2.1 Terminal Tools
- Zsh + Oh My Zsh
- Spaceship Prompt
- Plugins (autosuggestions, syntax highlighting, etc)

#### 3.2.2 Database Tools
- TablePlus
- DBeaver
- MongoDB Compass
- pgAdmin
- MySQL Workbench

#### 3.2.3 API Tools
- Ferramentas de Teste (curl, httpie, jq, yq)
- Documentação (Swagger CLI, OpenAPI Generator)
- Proxy/Debug (mitmproxy, ngrok)
- GUI (Postman, Insomnia)

#### 3.2.4 Browser Tools
- Google Chrome
- Firefox
- Brave
- Microsoft Edge

### 3.3 Configuração de ambiente Docker

Se você planeja usar o ByteBabe com Docker, pode configurar ambientes pré-definidos:

```bash
bytebabe docker setup
```

Este comando permite configurar:
- Imagens Docker pré-configuradas
- Redes Docker personalizadas
- Volumes persistentes
- Configurações de proxy e rede

## 4. Primeiros passos

Após a instalação e configuração, você pode começar a usar o ByteBabe com alguns comandos básicos.

### 4.1 Comandos essenciais

```bash
# Ver todos os comandos disponíveis
bytebabe --help

# Verificar status do sistema
bytebabe status

# Iniciar interface interativa
bytebabe shell
```

### 4.2 Módulo Git

O ByteBabe oferece uma interface aprimorada para Git:

```bash
# Status do repositório
bytebabe git status

# Commit interativo
bytebabe git commit

# Visualização de branches
bytebabe git branches
```

### 4.3 Módulo Docker

Gerencie containers Docker com facilidade:

```bash
# Listar containers
bytebabe docker ps

# Iniciar ambiente de desenvolvimento
bytebabe docker up

# Visualizar logs
bytebabe docker logs
```

### 4.4 Servidores de desenvolvimento

Inicie servidores locais rapidamente:

```bash
# Servidor web simples
bytebabe server start

# Proxy reverso
bytebabe server proxy

# Servidor de arquivos
bytebabe server files
```

## 5. Perguntas Frequentes (FAQ)

### 5.1 Problemas comuns de instalação

| Problema | Solução |
|----------|---------|
| `Command not found` | Adicione `~/.bytebabe/bin` ao seu PATH |
| `Permission denied` | Execute com `sudo` ou verifique permissões |
| `Dependencies missing` | Execute `bytebabe doctor` para verificar |
| `Docker not available` | Instale o Docker ou desative recursos relacionados |
| `Network error` | Verifique sua conexão com a internet |
| `Conflict with existing tools` | Use `bytebabe install --no-conflict` |

### 5.2 Como atualizar o ByteBabe?

Para atualizar o ByteBabe para a versão mais recente, execute:

```bash
bytebabe self-update
```

O processo de atualização preserva suas configurações e personalizações. Se preferir uma atualização limpa:

```bash
bytebabe self-update --clean
```

### 5.3 Onde ficam os arquivos de configuração?

Os arquivos de configuração do ByteBabe estão localizados em:

```bash
~/.bytebabe/config/
```

Os principais arquivos são:
- `config.yaml`: Configurações gerais
- `themes/`: Temas visuais
- `modules/`: Configurações de módulos específicos
- `aliases.yaml`: Aliases personalizados

### 5.4 Como gerar um relatório de diagnóstico?

Se estiver enfrentando problemas, você pode gerar um relatório de diagnóstico com:

```bash
bytebabe doctor --report
```

Este comando criará um arquivo ZIP com informações detalhadas sobre seu sistema e configuração, que pode ser compartilhado com a equipe de suporte.

### 5.5 O ByteBabe é compatível com meu terminal?

O ByteBabe é compatível com a maioria dos terminais modernos em sistemas Linux e macOS, incluindo:
- Terminal padrão do Ubuntu/Debian
- Terminal padrão do macOS
- iTerm2
- Terminator
- Konsole
- GNOME Terminal
- Alacritty
- Kitty
- Hyper

Para verificar a compatibilidade com seu terminal específico:

```bash
bytebabe terminal check
```

### 5.6 Como desinstalar o ByteBabe?

Para desinstalar completamente o ByteBabe, execute:

```bash
bytebabe uninstall
```

Este comando removerá todos os arquivos e configurações. Se desejar manter suas configurações:

```bash
bytebabe uninstall --keep-config
```

### 5.7 O ByteBabe funciona no Windows?

Atualmente, o ByteBabe não oferece suporte nativo ao Windows. No entanto, você pode usá-lo através do Windows Subsystem for Linux (WSL2) ou do Git Bash, com algumas limitações.

Para mais informações sobre o uso no Windows, consulte nossa [documentação específica para Windows](windows-support.md).

### 5.8 Posso usar o ByteBabe em ambientes corporativos?

Sim! O ByteBabe foi projetado para funcionar bem em ambientes corporativos. Para configurações específicas:

```bash
bytebabe init --corporate
```

Este modo inclui:
- Configurações de proxy corporativo
- Integração com ferramentas empresariais
- Políticas de segurança aprimoradas
- Suporte a VPNs e redes restritas

## 6. Recursos adicionais

### 6.1 Documentação oficial

Para informações mais detalhadas, consulte a documentação oficial:
- [Guia de Início Rápido](https://bytebabe.dev/quick-start)
- [Documentação Completa](https://bytebabe.dev/docs)
- [Referência de API](https://bytebabe.dev/api)
- [Tutoriais em Vídeo](https://bytebabe.dev/videos)


### 6.2 Licença

ByteBabe CLI é distribuído sob a licença MIT.

## 7. Apêndice

### 7.1 Glossário de termos

| Termo | Definição |
|-------|-----------|
| CLI | Command Line Interface (Interface de Linha de Comando) |
| Container | Unidade padronizada de software que empacota código e dependências |
| Docker | Plataforma para desenvolvimento, envio e execução de aplicações em containers |
| Git | Sistema de controle de versão distribuído |
| Terminal | Interface de texto para inserir comandos |
| Shell | Programa que processa comandos e retorna saída |

### 7.2 Tabela de compatibilidade

| Sistema Operacional | Versão | Compatibilidade |
|---------------------|--------|----------------|
| Ubuntu | 20.04+ | Completa ✓ |
| Debian | 10+ | Completa ✓ |
| Fedora | 34+ | Completa ✓ |
| CentOS | 8+ | Parcial ⚠️ |
| macOS | 11+ | Completa ✓ |
| Windows | 10/11 | Via WSL2 ⚠️ |

## 8. Conclusão

O ByteBabe CLI representa uma evolução na experiência de linha de comando para desenvolvedores, combinando funcionalidade profissional com uma interface moderna e agradável. Através deste guia, você aprendeu como instalar, configurar e utilizar esta ferramenta para otimizar seu fluxo de trabalho diário.

A instalação do ByteBabe é simples e direta, seja pelo método automático ou manual, e sua configuração flexível permite adaptá-lo às suas necessidades específicas. Com seus diversos módulos especializados, o ByteBabe simplifica tarefas comuns de desenvolvimento, desde operações Git até gerenciamento de containers Docker.

Ao adotar o ByteBabe em seu ambiente de desenvolvimento, você não apenas ganha produtividade, mas também torna a experiência no terminal mais agradável. A ferramenta continua em constante evolução, com novas funcionalidades sendo adicionadas regularmente para atender às necessidades da comunidade de desenvolvedores.

Recomendamos explorar os diversos módulos e recursos do ByteBabe para descobrir como ele pode se integrar melhor ao seu fluxo de trabalho específico. A documentação oficial e os canais de suporte estão disponíveis para ajudá-lo a aproveitar ao máximo esta ferramenta inovadora.

Agradecemos por escolher o ByteBabe CLI e esperamos que ele torne seu trabalho de desenvolvimento mais eficiente e agradável.
