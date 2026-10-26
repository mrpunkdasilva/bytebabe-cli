# PRD — ByteBabe CLI

| Campo | Valor |
|-------|-------|
| Produto | ByteBabe CLI |
| Versão de referência | `1.4.0` |
| Data | 2026-10-26 |
| Responsável | Mr Punk da Silva |
| Repositório | https://github.com/mrpunkdasilva/bytebabe-cli |

## 1. Problema

Desenvolvedores precisam alternar entre dezenas de ferramentas para configurar ambientes, instalar runtimes, gerenciar containers, bancos, IDEs e operações Git. Cada distribuição Linux usa um gerenciador de pacotes diferente, e o onboarding em WSL, Fedora, Ubuntu, Arch e derivados é fragmentado.

## 2. Visão

Ser um toolkit de terminal unificado e modular que configure e opere o ambiente de desenvolvimento com uma interface consistente, segura e com identidade cyberpunk.

## 3. Personas

| Persona | Necessidade |
|---------|-------------|
| Desenvolvedor iniciante | Configurar ambiente completo com poucos comandos |
| Desenvolvedor experiente | Automatizar tarefas repetitivas sem sair do terminal |
| Instrutor/mentor | Padronizar ambientes de aula e projetos |
| Mantenedor | Adicionar módulos sem quebrar a CLI principal |

## 4. Objetivos

- Instalar e atualizar o CLI de forma reproduzível em Linux e WSL.
- Detectar a distribuição e usar o gerenciador de pacotes correto.
- Oferecer menus interativos e comandos diretos para automação.
- Manter módulos desacoplados com especificação e testes.
- Publicar releases com tarball versionado e instalação via `curl`.

### Não objetivos

- Substituir gerenciadores de pacotes, Docker ou Git.
- Oferecer interface gráfica.
- Suportar macOS e Windows nativos na versão atual.
- Executar comandos destrutivos sem confirmação do usuário.

## 5. Escopo atual

| Domínio | Módulos |
|---------|---------|
| Núcleo | `hello`, `init`, `edit`/`byteedit`, `alias`, `help` |
| Desenvolvimento | `frontend`, `backend`, `spring`, `ide` |
| Ferramentas | `devtools` (terminal, database, browser, api) |
| Infraestrutura | `docker`, `db`, `datavision`/`dv`, `servers` |
| Versionamento | `git`, `gh`/`github` |
| API | `flux` |
| Sistema | `prime`/`pm` |

## 6. Requisitos funcionais

| ID | Requisito | Prioridade |
|----|-----------|------------|
| F-01 | Instalar o CLI em `/opt/bytebabe` e expor `bytebabe` em `/usr/local/bin` | MUST |
| F-02 | Funcionar quando invocado por symlink | MUST |
| F-03 | Detectar `apt`, `dnf`, `yum`, `pacman`, `zypper` e `apk` | MUST |
| F-04 | Exibir ajuda global com todos os comandos disponíveis | MUST |
| F-05 | Permitir aliases globais e aliases do usuário | MUST |
| F-06 | Configurar Zsh, Oh My Zsh, Spaceship e Atuin | SHOULD |
| F-07 | Criar projetos e gerar artefatos frontend | SHOULD |
| F-08 | Instalar runtimes e frameworks backend | SHOULD |
| F-09 | Instalar e executar IDEs suportadas | SHOULD |
| F-10 | Gerenciar containers, imagens e compose via Docker | SHOULD |
| F-11 | Configurar e operar bancos via Docker Compose | SHOULD |
| F-12 | Gerenciar conexões no DataVision | MAY |
| F-13 | Executar operações Git e GitHub assistidas | SHOULD |
| F-14 | Servir APIs de teste com Flux | MAY |
| F-15 | Gerenciar pacotes, segurança e utilitários do sistema via Prime | MAY |

## 7. Requisitos não funcionais

| ID | Requisito |
|----|-----------|
| NF-01 | Código em Bash 4+ compatível com Linux e WSL |
| NF-02 | Nenhum segredo em log, saída ou repositório |
| NF-03 | Operações privilegiadas MUST usar `sudo` apenas quando necessário |
| NF-04 | Mensagens de erro MUST indicar causa provável e próximo passo |
| NF-05 | Testes unitários MUST rodar com `bash tests/scripts/run_unit_tests.sh` |
| NF-06 | Instalação MUST ser idempotente e substituir versão anterior |
| NF-07 | Comandos interativos MUST aceitar modo direto quando possível |
| NF-08 | Mudanças de comportamento MUST atualizar `spec/` e docs |

## 8. Métricas de sucesso

- Instalação completa em menos de 2 minutos em conexão estável.
- `bytebabe --version`, `bytebabe help` e `bytebabe init` funcionando após instalação.
- Suíte unitária com 100% de aprovação no release.
- Nenhum comando crítico executado sem confirmação.

## 9. Roadmap

| Versão | Tema | Estado |
|--------|------|--------|
| `1.0.0` | Fundação e módulos principais | Concluído |
| `1.4.0` | Multi-distro, Atuin, instalação e help | Concluído |
| `1.5.0` | Flux estável, DevTools e UX | Em andamento |
| `2.0.0` | Segurança, firewall e scanning | Planejado |
| `2.5.0` | Monitoramento e cloud | Planejado |

## 10. Riscos

| Risco | Impacto | Mitigação |
|-------|---------|-----------|
| Diferenças entre distros | Alto | Detecção de gerenciador e fallback |
| Flatpak ausente em WSL | Médio | Detectar `code`/Flatpak antes de instalar |
| Dependências interativas | Médio | Modo direto + validação de argumentos |
| Comandos destrutivos | Alto | Confirmação explícita e escopo restrito |

## 11. Questões abertas

- Qual estratégia de instalação de IDEs será padrão no WSL: Flatpak, repositório nativo ou integração com o Windows?
- O Flux deve continuar como cliente próprio ou integrar com `curl`/`httpie`?
- Qual o formato oficial de plugins de terceiros?
