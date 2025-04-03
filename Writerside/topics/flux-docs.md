# Documentation Module 📚

## Documentação Automática

```ascii
┌─ API Documentation Generator ─────────────────┐
│ 📁 Users API                                 │
│ ├─ 📘 Authentication                         │
│ │  ├─ POST /auth/login                      │
│ │  └─ POST /auth/refresh                    │
│ │                                           │
│ ├─ 📘 User Management                       │
│ │  ├─ GET /users                           │
│ │  ├─ POST /users                          │
│ │  └─ PUT /users/{id}                      │
└───────────────────────────────────────────────┘
```

## Formatos Suportados

### Export
- OpenAPI/Swagger
- Markdown
- HTML
- PDF
- Postman Collection

### Import
- Swagger/OpenAPI
- Postman Collections
- HAR files
- cURL commands

## Features

### Auto-Documentation
- Request/Response examples
- Schema detection
- Parameter description
- Authentication details

### Markdown Enhancement
```markdown
### Get User [GET /users/{id}]

Parameters:
- id: string (required) - User ID

Response:
```json
{
    "id": "123",
    "name": "John Doe"
}
```
```

### Live Preview
- Real-time rendering
- Syntax highlighting
- Interactive examples
- Search/Filter

## Publicação

### Export Options
- Static site
- Single page
- Dark/Light theme
- Custom branding