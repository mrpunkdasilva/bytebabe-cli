# ByteBabe CLI - User Guidelines

## Filosofia de Design

O ByteBabe CLI segue uma filosofia de design que combina estética cyberpunk com funcionalidade profissional. Nosso objetivo é criar ferramentas que sejam não apenas poderosas e eficientes, mas também visualmente estimulantes e agradáveis de usar.

## Princípios Fundamentais

### 1. Estética Cyberpunk com Funcionalidade Profissional

- **Interfaces visuais**: Use cores neon (azul, rosa, verde) sobre fundos escuros
- **ASCII art**: Incorpore elementos visuais em ASCII para headers e separadores
- **Terminologia**: Adote termos do universo cyberpunk sem comprometer a clareza

### 2. Consistência Visual e Funcional

- **Paleta de cores**: Mantenha uma paleta consistente em todos os módulos
- **Estrutura de comandos**: Siga padrões consistentes para todos os comandos
- **Feedback visual**: Forneça feedback visual consistente para ações similares

### 3. Experiência do Desenvolvedor em Primeiro Lugar

- **Eficiência**: Minimize o número de comandos necessários para tarefas comuns
- **Clareza**: Forneça mensagens de erro claras e acionáveis
- **Documentação**: Integre ajuda contextual em todos os níveis

## Diretrizes de Código

### Estrutura de Arquivos

```
bytebabe/
├── bin/                # Executáveis principais
├── commands/           # Implementação de comandos
│   ├── core/           # Comandos essenciais
│   ├── flux/           # Módulo API client
│   └── ...             # Outros módulos
├── lib/                # Bibliotecas compartilhadas
│   ├── core/           # Funções core
│   ├── ui/             # Componentes de UI
│   └── utils/          # Utilitários
└── docs/               # Documentação
```

### Padrões de Código

1. **Nomenclatura**
   - Funções: `snake_case` (ex: `parse_json_response`)
   - Variáveis: `snake_case` (ex: `response_body`)
   - Constantes: `SCREAMING_SNAKE_CASE` (ex: `MAX_RETRY_COUNT`)
   - Arquivos: `kebab-case.sh` (ex: `http-client.sh`)

2. **Documentação de Código**
   ```bash
   # Processa uma resposta HTTP e formata de acordo com o tipo de conteúdo
   #
   # Argumentos:
   #   $1 - Corpo da resposta
   #   $2 - Tipo de conteúdo (opcional, padrão: application/json)
   #
   # Retorna:
   #   Resposta formatada
   process_response() {
       local response_body="$1"
       local content_type="${2:-application/json}"
       # ...
   }
   ```

3. **Tratamento de Erros**
   ```bash
   if ! command -v jq &> /dev/null; then
       echo -e "${CYBER_RED}Erro: jq não encontrado${RESET}"
       echo -e "${CYBER_YELLOW}Instale com: sudo apt install jq${RESET}"
       exit 1
   fi
   ```

## Diretrizes de UI/UX

### Componentes Visuais

1. **Headers**
   ```
   ╔════════════════════════════════════════════════╗
   ║           BYTEBABE FLUX API CLIENT             ║
   ╚════════════════════════════════════════════════╝
   ```

2. **Menus**
   ```
   1) Enviar GET request
   2) Enviar POST request
   3) Configurar headers
   4) Salvar coleção
   ```

3. **Feedback**
   ```
   ✓ Request enviado com sucesso (200 OK)
   ✗ Falha na conexão: Host não encontrado
   ⚠ Aviso: Resposta sem conteúdo
   ```

### Paleta de Cores

- **Primária**: Ciano neon (`\033[38;5;51m`) - Títulos, sucesso
- **Secundária**: Rosa neon (`\033[38;5;198m`) - Destaques, prompts
- **Terciária**: Verde neon (`\033[38;5;46m`) - Confirmações, status positivo
- **Alerta**: Amarelo (`\033[38;5;226m`) - Avisos, atenção
- **Erro**: Vermelho (`\033[38;5;196m`) - Erros, falhas
- **Fundo**: Preto profundo (`\033[48;5;0m`) - Fundo padrão

### Fluxos de Interação

1. **Fluxo de Comando**
   - Comando → Confirmação → Execução → Resultado → Próximos passos
   - Sempre ofereça uma saída clara ou caminho de volta

2. **Fluxo de Erro**
   - Erro → Explicação → Solução sugerida → Opção de retry/exit

3. **Fluxo de Configuração**
   - Mostrar configuração atual → Opções de mudança → Confirmação → Aplicação

## Diretrizes de Documentação

### Estrutura de Documentação

1. **Visão Geral**: O que é e para que serve
2. **Instalação**: Como instalar e configurar
3. **Uso Básico**: Comandos essenciais
4. **Uso Avançado**: Recursos avançados
5. **Referência**: Lista completa de comandos e opções
6. **Troubleshooting**: Problemas comuns e soluções

### Exemplos

Sempre inclua exemplos práticos e realistas:

```bash
# Exemplo básico
bytebabe flux get https://api.exemplo.com/users

# Exemplo com parâmetros
bytebabe flux get https://api.exemplo.com/users \
  --header "Authorization: Bearer token123" \
  --format json

# Exemplo de fluxo completo
bytebabe flux collection create minha-api
bytebabe flux request add minha-api get-users GET https://api.exemplo.com/users
bytebabe flux collection run minha-api get-users
```

## Checklist de Qualidade

Antes de considerar um recurso como concluído, verifique:

- [ ] O código segue os padrões de nomenclatura e estrutura
- [ ] A documentação está completa e atualizada
- [ ] A interface do usuário é consistente com o resto do sistema
- [ ] O tratamento de erros é robusto e informativo
- [ ] Os testes cobrem casos de uso normais e de borda
- [ ] A experiência do usuário foi considerada e otimizada
- [ ] O recurso mantém a estética cyberpunk sem sacrificar usabilidade

## Processo de Desenvolvimento

1. **Planejamento**: Defina escopo, requisitos e critérios de aceitação
2. **Design**: Crie mockups de UI e diagrame a arquitetura
3. **Implementação**: Siga as diretrizes de código e UI
4. **Teste**: Teste manualmente e com scripts automatizados
5. **Documentação**: Atualize a documentação com exemplos
6. **Revisão**: Verifique contra a checklist de qualidade
7. **Lançamento**: Integre ao sistema principal

Lembre-se: O ByteBabe CLI é uma ferramenta séria com uma estética divertida. Nunca sacrifique funcionalidade por estilo, mas também não ignore o impacto positivo que uma boa experiência visual pode ter na produtividade e satisfação do usuário.