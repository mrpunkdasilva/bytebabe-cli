# Frontend Module

The Frontend module provides tools for creating, managing, and developing frontend applications with support for multiple frameworks and features.

## Overview

This module helps developers create and manage frontend projects using popular frameworks like React, Vue, Angular, Next.js, and Svelte, with additional features like Tailwind CSS, Redux, routing, and internationalization.

## Commands

### Project Creation
- `new <framework> <name> [template]` - Create a new frontend project
- `create <framework> <name> [template]` - Alias for new command

### Feature Management
- `add <feature>` - Add features to existing project
- `generate <type> <name>` - Generate components, services, etc.

### Development Commands
- `install [deps|dev]` - Install dependencies
- `test [watch|coverage]` - Run tests
- `build [prod]` - Build project
- `serve [prod]` - Serve development server

## Supported Frameworks

### React Ecosystem
- `react` - React application
- `next` - Next.js application

### Vue Ecosystem
- `vue` - Vue.js application

### Angular Ecosystem
- `angular` - Angular application

### Other Frameworks
- `svelte` - Svelte application

## Supported Features

### Styling
- `tailwind` - Tailwind CSS integration

### State Management
- `redux` - Redux state management

### Routing
- `router` - Client-side routing

### Internationalization
- `i18n` - Internationalization support

## Generation Types

### Components
- `component` or `c` - Generate component files

### Services
- `service` or `s` - Generate service files

### State Management
- `store` - Generate store files (React Context, Vuex)

### React Specific
- `hook` - Generate custom React hooks

### Angular Specific
- `guard` - Generate Angular route guards

## Usage Examples

```bash
# Create new projects
bytebabe frontend new react my-app
bytebabe frontend new vue my-vue-app
bytebabe frontend new angular my-angular-app
bytebabe frontend new next my-next-app
bytebabe frontend new svelte my-svelte-app

# Add features to existing project
bytebabe frontend add tailwind
bytebabe frontend add redux
bytebabe frontend add router
bytebabe frontend add i18n

# Generate files
bytebabe frontend generate component MyComponent
bytebabe frontend generate service ApiService
bytebabe frontend generate store UserStore
bytebabe frontend generate hook useCustomHook
bytebabe frontend generate guard AuthGuard

# Development commands
bytebabe frontend install deps
bytebabe frontend test watch
bytebabe frontend build prod
bytebabe frontend serve
```

## Features

### Project Creation
- Framework-specific project scaffolding
- Template selection
- Automatic dependency installation
- Configuration setup

### Feature Integration
- Automatic framework detection
- Framework-specific implementations
- Configuration file generation
- Dependency management

### Code Generation
- Component templates
- Service patterns
- State management setup
- Framework-specific features

### Development Tools
- Package management
- Testing integration
- Build optimization
- Development server

## Framework Detection

The module automatically detects the current framework by checking for:
- `package.json` dependencies
- Framework-specific configuration files
- Project structure patterns

## Template System

### Default Templates
- Standard project structure
- Basic configuration
- Essential dependencies

### Custom Templates
- Framework-specific optimizations
- Pre-configured features
- Best practices implementation

## Configuration

### Package Management
- npm integration
- Development dependencies
- Production builds

### Build System
- Framework-specific build tools
- Production optimization
- Development server configuration

### Testing Setup
- Framework-specific test runners
- Coverage reporting
- Watch mode support

## Dependencies

- Node.js and npm
- Framework-specific CLI tools
- Standard Unix tools
- Git for version control 