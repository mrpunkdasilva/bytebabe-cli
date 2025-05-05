# Documentation Guidelines

## Estrutura da Documentação

### 1. Headers de Script
```bash
#!/bin/bash
#
# ByteBabe - Terminal Tools
# 
# Descrição:
#   Implementa comandos para configuração do terminal
#
# Uso:
#   bytebabe terminal [comando]
#
# Comandos:
#   zsh       - Instala e configura Zsh
#   ohmyzsh   - Instala Oh My Zsh
#   all       - Instala tudo
```

### 2. Funções
```bash
# Instala e configura o Zsh
#
# Argumentos:
#   Nenhum
#
# Retorna:
#   0 se sucesso, 1 se erro
install_zsh() {
    echo "Instalando Zsh..."
}
```

## Markdown Guidelines

### Headers
```markdown
# Título Principal
## Seção Secundária
### Subseção
```

### Code Blocks
```markdown
\```bash
./bytebabe hello
\```
```

### Lists
```markdown
- Item 1
  - Subitem 1.1
  - Subitem 1.2
- Item 2
```

## Exemplos {id="exemplos_1"}

### 1. Documentação de Comando
```markdown
# Comando Hello

Exibe uma mensagem de boas-vindas personalizada.

## Uso
```bash
bytebabe hello [nome]
```

## Argumentos
- `nome`: Nome do usuário (opcional)

## Exemplos

```bash
bytebabe hello
bytebabe hello João
```

### 2. Documentação de Erro

## Mensagens de Erro

- "Comando não encontrado": Verifique a instalação
- "Permissão negada": Execute com sudo

## Best Practices

### 1. Clareza
- Use linguagem simples
- Forneça exemplos práticos
- Documente casos de uso comuns

### 2. Completude
- Documente todos os comandos
- Explique todas as opções
- Liste mensagens de erro

### 3. Manutenção
- Mantenha docs atualizadas
- Verifique exemplos
- Atualize screenshots