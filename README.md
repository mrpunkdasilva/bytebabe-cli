<div align="center">
  <img height="300" src="https://github.com/user-attachments/assets/924b4161-f63a-4ec3-bebb-00d74eff7b73" />
  <br/>
  <img height="50" src=".github/ByteBabe.svg" />

  <h1>ByteBabe CLI</h1>
  <p>A cyberpunk-themed developer toolkit for supercharged workflows 🚀</p>

  <p>
    <a href="#installation">Installation</a> •
    <a href="#key-features">Features</a> •
    <a href="#usage">Usage</a> •
    <a href="#contributing">Contributing</a> •
    <a href="#support">Support</a>
  </p>
</div>

## ⚡ Overview

ByteBabe is a modular CLI toolkit that brings cyberpunk aesthetics to your development workflow. It provides a unified interface for managing development environments, containers, Git operations, databases, and more - all with a unique cyberpunk twist.

## 🎯 Key Features

### 🐳 Docker Management (Poseidon Module)
- Container/image/volume management
- Compose stack handling
- Visual container stats
- Resource monitoring
- Supports both verbose and short command styles

### 🗄️ Database Operations (Oracle Module)
- Support for MySQL, PostgreSQL, MongoDB, Redis
- Backup/restore operations
- Migration tools
- GUI tool integration (TablePlus, DBeaver, etc.)

### 🔧 Git & GitHub Operations (Neo Module)
- Interactive Git interface
- Repository management
- Branch operations
- Semantic commit handling
- GitHub CLI integration
- Pull requests and issues management

### 🛠️ Development Tools (Matrix Module)
- Terminal tools (Zsh + plugins)
- Database management GUIs
- API testing tools
- Browser tools
- IDE configuration and management

### ⚙️ System Management (Prime Module)
- Package management (install, upgrade, remove)
- Security tools (firewall, scan, quarantine)
- System utilities (clean, backup, network)
- Service control and monitoring
- System information and stats

### 🌐 Backend Development
- Multi-language runtime support (Node.js, Python, Java, Go, Rust, PHP)
- Framework installation (Spring Boot, Express, Django, Flask, NestJS, Laravel)
- Universal package manager detection
- Development environment setup

### 🎨 Frontend Development
- Framework support (React, Vue, Angular, Next.js)
- Package manager installation (npm, yarn, pnpm, bun)
- Project scaffolding and generation
- Development server management

### 🔌 API Development (Flux Module)
- REST API client with HTTP verbs (GET, POST, PUT, DELETE)
- JSON server integration
- Request history and management
- Interactive API testing

### 💻 IDE Management
- Multiple IDE support (VS Code, Zed, Sublime, JetBrains)
- Installation and configuration
- Status monitoring
- Quick launch capabilities

### 🚀 Server Management
- Docker-based server orchestration
- Multi-service management
- Status monitoring
- Automated setup and configuration

## 🚀 Installation

### Prerequisites
- 🐧 Linux/Unix (sorry Windows-chan)
- 🐚 Bash 4+
- 📦 Git
- 🌐 curl or wget
- 🐳 Docker (optional)

### Quick Install
```bash
# Using curl
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe/main/install.sh | bash

# Or using wget
wget -qO- https://raw.githubusercontent.com/mrpunkdasilva/bytebabe/main/install.sh | bash
```

### Manual Installation
```bash
# Clone the repository
git clone https://github.com/mrpunkdasilva/bytebabe.git
cd bytebabe

# Run the installer
./install.sh
```

## 💻 Usage

### 🐳 Docker Operations
```bash
# Verbose style
bytebabe docker containers list --all
bytebabe docker images pull nginx

# Short style (cyberpunk)
bytebabe docker c ls -a
bytebabe docker i p nginx
```

### 🗄️ Database Operations
```bash
# Setup database environment
bytebabe db setup

# Start specific database
bytebabe db start postgres

# Check database status
bytebabe db status
```

### 🔧 Git & GitHub Operations
```bash
# Interactive git status
bytebabe git status

# GitHub repository operations
bytebabe gh clone username/repo
bytebabe gh create my-new-repo
bytebabe gh pr create
```

### 🛠️ Development Tools
```bash
# Install terminal tools
bytebabe devtools terminal all

# Install database tools
bytebabe devtools database dbeaver

# Install API tools
bytebabe devtools api --test
```

### ⚙️ System Management
```bash
# Package management
bytebabe prime install package-name
bytebabe prime upgrade
bytebabe prime remove package-name

# Security tools
bytebabe prime firewall status
bytebabe prime scan system

# System utilities
bytebabe prime clean temp
bytebabe prime backup create
```

### 🌐 Backend Development
```bash
# Install runtime
bytebabe backend install node
bytebabe backend install python
bytebabe backend install java

# Setup framework
bytebabe backend spring setup
bytebabe backend express setup
```

### 🎨 Frontend Development
```bash
# Setup frontend environment
bytebabe frontend setup

# Create new project
bytebabe frontend new react my-app
bytebabe frontend new vue my-app
```

### 🔌 API Development
```bash
# Start JSON server
bytebabe flux server

# Make API requests
bytebabe flux get users
bytebabe flux post users '{"name": "John"}'
bytebabe flux put users/1 '{"name": "Jane"}'
bytebabe flux delete users/1
```

### 💻 IDE Management
```bash
# Install IDE
bytebabe ide vscode
bytebabe ide zed

# Run IDE
bytebabe ide run code
bytebabe ide status zed
```

### 🚀 Server Management
```bash
# Start servers
bytebabe servers up

# Check status
bytebabe servers status

# Stop servers
bytebabe servers down
```

### 🛠️ Utilities
```bash
# Initialize environment
bytebabe init

# Simple text editor
bytebabe edit file.txt

# Greeting message
bytebabe hello
```

## 📦 Module Overview

| Module | Description | Commands | Test Status |
|--------|-------------|----------|-------------|
| `docker` | Container management | `containers`, `images`, `volumes`, `compose` | ✅ 10/10 |
| `db` | Database operations | `setup`, `start`, `stop`, `status` | ✅ 10/10 |
| `git` | Git operations | `status`, `stage`, `commit`, `push` | 🔄 Pending |
| `gh` | GitHub operations | `clone`, `create`, `pr`, `issues` | 🔄 Pending |
| `devtools` | Development tools | `terminal`, `database`, `api`, `browser` | 🔄 Pending |
| `prime` | System management | `install`, `upgrade`, `firewall`, `scan` | 🔄 Pending |
| `backend` | Backend development | `install`, `setup`, `generate` | ⚠️ 9/10 |
| `frontend` | Frontend development | `setup`, `new`, `generate` | ✅ 10/10 |
| `flux` | API development | `get`, `post`, `put`, `delete`, `server` | 🔄 Pending |
| `ide` | IDE management | `vscode`, `zed`, `sublime`, `run` | 🔄 Pending |
| `servers` | Server management | `up`, `down`, `status`, `setup` | 🔄 Pending |
| `init` | Environment setup | Complete development environment | ✅ 10/10 |
| `edit` | Text editor | Simple file editing | ✅ 10/10 |
| `hello` | Greeting | Cyberpunk welcome message | ✅ 10/10 |

## 🛠️ Configuration

ByteBabe can be customized through:
- `~/.config/bytebabe/config.json` - General settings
- `~/.config/bytebabe/themes/` - Custom themes
- `~/.config/bytebabe/plugins/` - User plugins

## 🧪 Testing

ByteBabe includes a comprehensive testing framework to ensure code quality and reliability:

### Unit Tests
```bash
# Run individual command tests
bash tests/unit/commands/hello.test.sh
bash tests/unit/commands/init.test.sh
bash tests/unit/commands/backend.test.sh
bash tests/unit/commands/frontend.test.sh
bash tests/unit/commands/byteedit.test.sh
bash tests/unit/commands/db.test.sh
bash tests/unit/commands/docker.test.sh

# Run all tests
for test_file in tests/unit/commands/*.test.sh; do
    echo "Executando: $test_file"
    bash "$test_file"
    echo "---"
done
```

### Test Coverage
- ✅ **hello** - 10/10 tests passing
- ✅ **init** - 10/10 tests passing  
- ✅ **backend** - 9/10 tests passing
- ✅ **frontend** - 10/10 tests passing
- ✅ **byteedit** - 10/10 tests passing
- ✅ **db** - 10/10 tests passing
- ✅ **docker** - 10/10 tests passing

### Test Structure
Each test follows a consistent pattern:
- **Setup**: Creates temporary environment
- **Structural Tests**: Verifies file existence, executability, functions, imports
- **Functional Tests**: Checks command-specific features
- **Cleanup**: Removes temporary files
- **Reporting**: Shows pass/fail summary

### Testing Documentation
For detailed testing information, see [tests/README.md](tests/README.md).

## 🤝 Contributing

### Development Setup
```bash
# Clone and setup
git clone https://github.com/mrpunkdasilva/bytebabe.git
cd bytebabe

# Run tests before making changes
for test_file in tests/unit/commands/*.test.sh; do
    bash "$test_file"
done

# Make your changes and add tests
# Follow Conventional Commits for commit messages
git commit -m "feat: add new feature"
git commit -m "fix: resolve bug in module"
git commit -m "test: add unit tests for command"

# Run tests again
for test_file in tests/unit/commands/*.test.sh; do
    bash "$test_file"
done
```

### Commit Guidelines
We follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` - New features
- `fix:` - Bug fixes
- `test:` - Adding or updating tests
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `style:` - Code style changes
- `perf:` - Performance improvements

### Testing Requirements
- All new features must include unit tests
- Maintain test coverage above 80%
- Run tests before submitting PRs
- Follow existing test patterns

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

## 💬 Support

- 📖 [Documentation](docs/)
- 🧪 [Testing Guide](tests/README.md)
- 🐛 [Issues](https://github.com/mrpunkdasilva/bytebabe/issues)
- 💡 [Discussions](https://github.com/mrpunkdasilva/bytebabe/discussions)

## 🌟 Acknowledgments

- Built with cyberpunk aesthetics in mind
- Powered by the open source community
- Inspired by modern developer workflows
- Quality-driven development with comprehensive testing

---

<div align="center">
  <sub>Built with ❤️ by Mr Punk da Silva</sub>
</div>