# IDE Module

The IDE module provides tools for installing and managing Integrated Development Environments (IDEs) with cyberpunk aesthetics.

## Overview

This module helps developers install and configure popular IDEs and code editors, providing an interactive interface for IDE management with ByteBabe's signature cyberpunk theme.

## Commands

### Interactive Mode
- No arguments - Launch interactive IDE selection menu

### Direct Commands
- `install <ide>` - Install specific IDE
- `run <ide>` - Launch specific IDE
- `status <ide>` - Check IDE installation status
- `list` - List installed IDEs

### Help
- `help` or `-h` or `--help` - Show help information

## Supported IDEs

### Code Editors
- `vscode` - Visual Studio Code
- `zed` - Zed Editor
- `sublime` - Sublime Text

### JetBrains IDEs
- `intellij` - IntelliJ IDEA Community
- `pycharm` - PyCharm Community
- `clion` - CLion

### Package Managers
- `toolbox` - JetBrains Toolbox

### Bulk Installation
- `all` - Install all supported IDEs

## Usage Examples

```bash
# Interactive mode
bytebabe ide

# Direct installation
bytebabe ide install vscode
bytebabe ide install intellij
bytebabe ide install all

# Launch IDEs
bytebabe ide run code
bytebabe ide run zed

# Check status
bytebabe ide status vscode
bytebabe ide list

# Get help
bytebabe ide help
```

## Features

### Interactive Interface
- Cyberpunk-themed menu system
- Guided installation process
- Progress indicators
- Confirmation dialogs

### Installation Management
- Platform-specific installation methods
- Dependency resolution
- Error handling
- Installation verification

### IDE Launching
- Direct IDE execution
- Application ID mapping
- Status checking
- Installation validation

### Bulk Operations
- Install all IDEs at once
- Confirmation prompts
- Progress tracking
- Error reporting

## Installation Methods

### Visual Studio Code
- Uses system package manager
- Downloads from official source
- Configures extensions and settings

### Zed Editor
- Downloads from official website
- Platform-specific installation
- Configuration setup

### Sublime Text
- Uses system package manager
- Downloads from official source
- License configuration

### JetBrains IDEs
- Uses JetBrains Toolbox
- Downloads from official source
- License and plugin management

## Platform Support

### Linux
- Package manager integration (apt, dnf, pacman)
- AppImage support
- Snap package support

### macOS
- Homebrew integration
- Direct download installation
- Application bundle management

### Windows
- Chocolatey integration
- Direct download installation
- Registry configuration

## Configuration

### Environment Setup
- PATH configuration
- Desktop integration
- File associations
- Default editor settings

### IDE Settings
- Theme configuration
- Plugin management
- Workspace setup
- Keyboard shortcuts

## Dependencies

- System package manager
- curl for downloads
- Standard Unix tools
- Desktop environment integration 