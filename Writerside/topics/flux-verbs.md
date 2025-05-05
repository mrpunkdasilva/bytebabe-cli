# Flux HTTP Verbs

## Verbos Suportados

O Flux suporta os principais verbos HTTP para interação com APIs REST:

### GET

Utilizado para recuperar recursos do servidor.

```bash
flux get https://api.example.com/users
```

Opções específicas:
- `-q, --query` - Adicionar parâmetros de consulta

### POST

Utilizado para criar novos recursos no servidor.

```bash
flux post https://api.example.com/users -d '{"name":"John"}'
```

Opções específicas:
- `-d, --data` - Dados a serem enviados no corpo da requisição
- `-f, --form` - Enviar dados como form-data

### PUT

Utilizado para atualizar recursos existentes no servidor.

```bash
flux put https://api.example.com/users/123 -d '{"name":"Jane"}'
```

Opções específicas:
- `-d, --data` - Dados a serem enviados no corpo da requisição

### DELETE

Utilizado para remover recursos do servidor.

```bash
flux delete https://api.example.com/users/123
```

## Opções Comuns

Todas as operações de verbo suportam as seguintes opções:

- `-H, --header` - Adicionar cabeçalho personalizado
- `--json` - Adicionar cabeçalho Accept para JSON
- `-h, --help` - Mostrar ajuda para o verbo específico