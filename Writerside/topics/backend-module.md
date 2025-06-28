# Backend Module

The Backend module provides tools for setting up and managing backend development environments with support for multiple runtimes and frameworks.

## Overview

This module helps developers install and configure various backend technologies including runtimes (Node.js, Python, PHP, Java, Go, Rust, Elixir) and frameworks (Express.js, Django, Flask, Spring Boot, NestJS, Laravel, Phoenix).

## Commands

### Setup Commands

#### Interactive Setup
- `setup` - Interactive setup wizard for backend environment

#### Direct Installation
- `install <technology>` - Install specific runtime or framework

#### Information
- `list` - List all supported technologies
- `help` - Show help information

## Supported Technologies

### Runtimes
- `node` - Node.js runtime
- `php` - PHP runtime
- `python` - Python runtime
- `java` - Java runtime (via SDKMAN)
- `go` - Go runtime
- `rust` - Rust runtime
- `elixir` - Elixir runtime

### Frameworks
- `express` - Express.js framework
- `django` - Django framework
- `flask` - Flask framework
- `spring` - Spring Boot framework
- `nestjs` - NestJS framework
- `laravel` - Laravel framework
- `phoenix` - Phoenix framework

## Usage Examples

```bash
# Interactive setup
bytebabe backend setup

# Install specific technologies
bytebabe backend install node express
bytebabe backend install python django flask
bytebabe backend install php laravel

# List supported technologies
bytebabe backend list

# Get help
bytebabe backend help
```

## Features

### Interactive Setup
- Guided installation process
- Multiple technology selection
- Runtime and framework installation
- Progress indicators with cyberpunk theme

### Direct Installation
- Command-line installation of specific technologies
- Batch installation of multiple technologies
- Error handling and validation

### Technology Management
- Support for 7 different runtimes
- Support for 7 different frameworks
- Automatic dependency resolution
- Platform-specific installation methods

## Installation Methods

### Node.js
- Uses Node Version Manager (nvm)
- Installs latest LTS version
- Configures npm and global packages

### Python
- Uses pyenv for version management
- Installs latest stable version
- Configures pip and virtual environments

### PHP
- Uses system package manager
- Installs latest stable version
- Configures Composer package manager

### Java
- Uses SDKMAN for version management
- Installs OpenJDK
- Configures Maven and Gradle

### Go
- Downloads from official source
- Installs latest stable version
- Configures GOPATH and modules

### Rust
- Uses rustup installer
- Installs latest stable version
- Configures Cargo package manager

### Elixir
- Uses system package manager
- Installs latest stable version
- Configures Mix build tool

## Framework Installation

### Node.js Frameworks
- Express.js: `npm install -g express-generator`
- NestJS: `npm install -g @nestjs/cli`

### Python Frameworks
- Django: `pip install django`
- Flask: `pip install flask`

### PHP Frameworks
- Laravel: `composer global require laravel/installer`

### Java Frameworks
- Spring Boot: Uses Spring Initializr

### Elixir Frameworks
- Phoenix: `mix archive.install hex phx_new`

## Configuration

The module automatically configures:
- Environment variables
- PATH settings
- Package managers
- Development tools

## Dependencies

- System package manager (apt, yum, brew)
- curl for downloads
- git for version control
- Standard Unix tools 