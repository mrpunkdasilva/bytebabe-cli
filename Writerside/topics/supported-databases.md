# Bancos Suportados 📚

## Bancos Disponíveis

### MySQL 8.0
```yaml
Porta: 3306
Usuário: byteuser
Senha: bytepass
Database: bytebabe_db
```

### PostgreSQL 15
```yaml
Porta: 5432
Usuário: byteuser
Senha: bytepass
Database: bytebabe_db
```

### MongoDB 6
```yaml
Porta: 27017
Usuário: root
Senha: example
```

### Redis 7
```yaml
Porta: 6379
```

## Ferramentas de Gestão

ByteBabe oferece integração com várias ferramentas GUI:

- TablePlus
- DBeaver
- MongoDB Compass
- pgAdmin
- MySQL Workbench

## Instalação

```bash
# Instalar banco específico
bytebabe db install mysql

# Instalar múltiplos bancos
bytebabe db setup
```

## Configuração

Cada banco pode ser customizado através do arquivo `config.yaml`:

```yaml
mysql:
  port: 3306
  version: "8.0"
  custom_config: "/path/to/my.cnf"

postgres:
  port: 5432
  version: "15"
  custom_config: "/path/to/postgresql.conf"
```