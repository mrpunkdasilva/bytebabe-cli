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
- Terminal tools (Zsh, Oh My Zsh, Spaceship, Atuin)
- Database management GUIs
- API testing tools
- Browser tools
- IDE configuration and management
- Quick aliases: `dev`, `dt`, `term`, `atuin`

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
- 🐧 Linux/Unix or WSL (Windows Subsystem for Linux)
- 🐚 Bash 4+
- 📦 Git
- 🌐 curl or wget
- 🐳 Docker (optional)

### Quick Install (release v1.4.0)
```bash
# Using curl
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe-cli/main/install.sh | bash

# Or using wget
wget -qO- https://raw.githubusercontent.com/mrpunkdasilva/bytebabe-cli/main/install.sh | bash
```

### Manual Installation (recommended for development)
```bash
# Clone the repository
git clone https://github.com/mrpunkdasilva/bytebabe-cli.git
cd bytebabe-cli

# Run the installer
./install.sh
```

The installer copies the CLI to `/opt/bytebabe` and creates the global symlink at
`/usr/local/bin/bytebabe`. When run inside the clone, it installs the local code
instead of downloading the release.

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
# Install terminal tools (including Atuin)
bytebabe devtools terminal all
bytebabe devtools terminal atuin

# Install database tools
bytebabe devtools database dbeaver

# Install API tools
bytebabe devtools api --test

# Short aliases
bytebabe devtools t all      # terminal
bytebabe devtools d dbeaver  # database
bytebabe devtools b chrome   # browser
bytebabe devtools a --test   # api
bytebabe dt at               # devtools terminal atuin
bytebabe atuin               # install Atuin
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

### ❓ Help & Version
```bash
# General help (also accepts -h and --help)
bytebabe help

# Detailed help for a command
bytebabe devtools --help
bytebabe frontend --help

# CLI version
bytebabe --version
```

## 📦 Module Overview

| Module | Description | Commands | Test Status |
|--------|-------------|----------|-------------|
| `docker` | Container management | `containers`, `images`, `volumes`, `compose` | ✅ 10/10 |
| `db` | Database operations | `setup`, `start`, `stop`, `status` | ✅ 10/10 |
| `git` | Git operations | `status`, `stage`, `commit`, `push` | ✅ 12/12 |
| `gh` | GitHub operations | `clone`, `create`, `pr`, `issues` | 🔄 Pending |
| `devtools` | Development tools | `terminal`, `database`, `api`, `browser` | 🔄 Pending |
| `prime` | System management | `install`, `upgrade`, `firewall`, `scan` | ✅ 12/12 |
| `backend` | Backend development | `install`, `setup`, `generate` | ✅ 14/14 |
| `frontend` | Frontend development | `setup`, `new`, `generate` | ✅ 15/15 |
| `flux` | API development | `get`, `post`, `put`, `delete`, `server` | 🔄 Pending |
| `ide` | IDE management | `vscode`, `zed`, `sublime`, `run` | 🔄 Pending |
| `servers` | Server management | `up`, `down`, `status`, `setup` | 🔄 Pending |
| `init` | Environment setup | Complete development environment | ✅ 8/8 |
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
# Run the complete suite (240 tests)
bash tests/scripts/run_unit_tests.sh

# Run a specific module
bash tests/scripts/run_unit_tests.sh --test hello
bash tests/scripts/run_unit_tests.sh --test prime

# List available tests
bash tests/scripts/run_unit_tests.sh --list

# Run a single test file directly
bash tests/unit/commands/git.test.sh
```

### Test Coverage
- ✅ **240/240 testes passando** em 19 arquivos.
- **101 testes estruturais** em `tests/unit/commands/`.
- **139 testes de caracterização** em `tests/unit/lib/` (core, entrypoint, Flux, Docker, Spring, Frontend e source-safety).
- CI executa `bash -n` e a suíte completa em push e pull request.

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
git clone https://github.com/mrpunkdasilva/bytebabe-cli.git
cd bytebabe-cli

# Run tests before making changes
bash tests/scripts/run_unit_tests.sh

# Make your changes and add tests
# Follow Conventional Commits for commit messages
git commit -m "feat: add new feature"
git commit -m "fix: resolve bug in module"
git commit -m "test: add unit tests for command"

# Run tests again
bash tests/scripts/run_unit_tests.sh
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

- 📐 [Product & Module Specs](spec/README.md)
- 🧪 [Testing Guide](tests/README.md)
- 🐛 [Issues](https://github.com/mrpunkdasilva/bytebabe-cli/issues)
- 💡 [Discussions](https://github.com/mrpunkdasilva/bytebabe-cli/discussions)

## 🌟 Acknowledgments

- Built with cyberpunk aesthetics in mind
- Powered by the open source community
- Inspired by modern developer workflows
- Quality-driven development with comprehensive testing

---

<div align="center">
  <sub>Built with ❤️ by Mr Punk da Silva</sub>
</div>