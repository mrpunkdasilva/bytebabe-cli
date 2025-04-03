
<div align="center">
  <img height="300" src="https://github.com/user-attachments/assets/924b4161-f63a-4ec3-bebb-00d74eff7b73" />
  <br/>
  <img height="50" src=".github/ByteBabe.svg" />

  <h1>ByteBabe CLI</h1>
  <p>A cyberpunk-themed developer toolkit for supercharged workflows 🚀</p>
</div>

## ⚡ Overview

ByteBabe is a modular CLI toolkit that brings cyberpunk aesthetics to your development workflow. It provides a unified interface for managing development environments, containers, Git operations, and more.

## 🎯 Key Features

- **Docker Management (Poseidon Module)**
  - Container/image/volume management
  - Compose stack handling
  - Visual container stats

- **Development Environment**
  - Frontend tooling (Node.js, React, etc)
  - Backend setup (Python, Java, Go, etc)
  - Database management
  - IDE configuration

- **Git Supercharged**
  - Visual branch navigation
  - Smart commit system
  - Time machine visualization

- **Server Management**
  - Apache/Nginx setup
  - SSL configuration
  - Docker integration

## 🚀 Quick Start

### Prerequisites
- Bash 4+
- Git (optional)
- curl or wget
- Docker (optional)

### Installation

#### Quick Install (Recommended)
```bash
# Using curl
curl -fsSL https://raw.githubusercontent.com/mrpunkdasilva/bytebabe/main/install.sh | bash

# Or using wget
wget -qO- https://raw.githubusercontent.com/mrpunkdasilva/bytebabe/main/install.sh | bash
```

#### Manual Installation
```bash
# Clone the repository (if Git is available)
git clone https://github.com/mrpunkdasilva/bytebabe.git
cd bytebabe

# Or download and extract the release
wget https://github.com/mrpunkdasilva/bytebabe/archive/refs/tags/v1.0.0.tar.gz
tar xzf v1.0.0.tar.gz
cd bytebabe-1.0.0

# Run the installer
./install.sh
```

### Basic Usage

```bash
# Initialize development environment
bytebabe init

# Start Docker containers
bytebabe docker up

# Setup backend environment
bytebabe backend setup

# Configure frontend tools
bytebabe frontend setup
```

## 📦 Module Overview

- `bytebabe init` - First-time setup
- `bytebabe docker` - Container management
- `bytebabe git` - Git operations
- `bytebabe backend` - Backend environment
- `bytebabe frontend` - Frontend tooling
- `bytebabe servers` - Web server management
- `bytebabe db` - Database operations
- `bytebabe ide` - IDE configuration
- `bytebabe devtools` - Development utilities

## 🛠️ Architecture

```
bytebabe/
├── bin/                # Main executable
├── commands/          # Command modules
├── lib/              # Shared libraries
│   ├── core/         # Core functionality
│   ├── docker/       # Docker helpers
│   ├── git/          # Git utilities
│   └── server/       # Server management
├── docs/             # Documentation
└── scripts/          # Utility scripts
```

## 🎨 Customization (Futures Plan)

ByteBabe can be customized through:
- `~/.config/bytebabe/config.json` - General settings
- `~/.config/bytebabe/themes/` - Custom themes
- `~/.config/bytebabe/plugins/` - User plugins

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

## 🌟 Acknowledgments

- Inspired by modern developer workflows
- Built with cyberpunk aesthetics in mind
- Powered by the open source community

---

<div align="center">
  <sub>Built with ❤️ by P</sub>
</div>
