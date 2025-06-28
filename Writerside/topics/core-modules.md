# Core Modules

ByteBabe is organized into several core modules, each providing specific functionality for development tasks.

## Main Modules

### Development Environment
- **[Backend Module](backend-module.md)** - Backend runtime and framework management
- **[Frontend Module](frontend-module.md)** - Frontend framework and project management
- **[Database Module](database-module.md)** - Database management and tools
- **[Docker Module](docker-module.md)** - Container management and orchestration

### Development Tools
- **[Git Module](git-module.md)** - Git workflow and repository management
- **[GitHub Module](github-module.md)** - GitHub CLI integration and automation
- **[IDE Module](ide-module.md)** - IDE installation and management
- **[Development Tools](dev-tools.md)** - Development utilities and services

### Infrastructure
- **[Server Management](servers.md)** - Web server configuration and management
- **[Package Management](pkg.md)** - System package management and security
- **[Flux Module](flux.md)** - API testing and development

### Utilities
- **[Init Command](init.md)** - Initial system setup and configuration
- **[ByteEdit](byteedit.md)** - Simple text editor utility
- **[Hello Command](hello.md)** - Welcome message and system greeting

## Module Status

| Module | Status | Description |
|--------|--------|-------------|
| Backend | ✅ Complete | Runtime and framework installation |
| Frontend | ✅ Complete | Framework project management |
| Database | ✅ Complete | Database tools and management |
| Docker | ✅ Complete | Container management |
| Git | ✅ Complete | Git workflow tools |
| GitHub | ✅ Complete | GitHub CLI integration |
| IDE | ✅ Complete | IDE installation |
| Dev Tools | ✅ Complete | Development utilities |
| Servers | ✅ Complete | Server management |
| Package | ✅ Complete | System package management |
| Flux | ✅ Complete | API testing tools |
| Init | ✅ Complete | System initialization |
| ByteEdit | ✅ Complete | Text editor utility |
| Hello | ✅ Complete | Welcome utility |

## Getting Started

### First Time Setup
```bash
# Initialize ByteBabe
bytebabe init

# Say hello
bytebabe hello
```

### Development Environment
```bash
# Setup backend environment
bytebabe backend setup

# Setup frontend environment
bytebabe frontend new react my-app

# Setup database tools
bytebabe db setup
```

### Container Management
```bash
# Docker operations
bytebabe docker ps
bytebabe docker compose up

# Package management
bytebabe pkg install <package>
```

## Module Integration

All modules are designed to work together seamlessly:
- Backend and Frontend modules integrate with Database module
- Git and GitHub modules work with all development modules
- Docker module supports all application types
- Package management integrates with system tools

## Configuration

Each module maintains its own configuration while sharing common settings:
- Global ByteBabe configuration
- Module-specific settings
- Environment-specific configurations
- User preferences and aliases
