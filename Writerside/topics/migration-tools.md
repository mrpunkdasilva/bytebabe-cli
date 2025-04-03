# Ferramentas de Migração 🔄

## Visão Geral

ByteBabe oferece ferramentas para:
- Migração de esquema
- Migração de dados
- Versionamento de banco
- Rollback seguro

## Comandos Básicos

```bash
# Criar nova migração
bytebabe db migrate create "add_users_table"

# Executar migrações pendentes
bytebabe db migrate up

# Reverter última migração
bytebabe db migrate down

# Ver status
bytebabe db migrate status
```

## Estrutura de Migrações

```sql
-- 20231225120000_add_users_table.sql
-- Up
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Down
DROP TABLE users;
```

## Boas Práticas

1. Uma mudança por migração
2. Sempre inclua `down` migration
3. Use timestamps consistentes
4. Teste migrações em ambiente de dev
5. Faça backup antes de migrar