# Testing Module 🧪

## Test Runner

```ascii
┌─ Test Suite: Users API ──────────────────────┐
│ ✓ Should authenticate user                   │
│ ✓ Should list all users                      │
│ ✓ Should create new user                     │
│ ✗ Should validate email format               │
│   Error: Invalid email format                │
└───────────────────────────────────────────────┘
```

## Testes Automatizados

### Sintaxe de Teste
```javascript
test("Create user", async () => {
    // Setup
    const userData = {
        name: "John Doe",
        email: "john@cyber.net"
    };

    // Execute
    const response = await request("POST", "/users")
        .withJson(userData)
        .expectStatus(201);

    // Validate
    expect(response.data.id).toBeDefined();
    expect(response.data.name).toBe(userData.name);
});
```

### Assertions Disponíveis
- Status code
- Response body
- Headers
- Response time
- JSON schema
- Custom validations

## Test Collections

### Organização
- Suites de teste
- Casos de teste
- Setup/Teardown
- Dados de teste

### Execução
```bash
# Rodar todos os testes
flux test run

# Rodar suite específica
flux test run users-api

# Modo watch
flux test watch
```

## Relatórios

### Formatos
- CLI Summary
- HTML Report
- JSON Export
- JUnit XML

### Métricas
- Success rate
- Response times
- Coverage
- Trends