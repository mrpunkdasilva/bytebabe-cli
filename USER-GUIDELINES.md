# ByteBabe CLI - User Guidelines

## Design Philosophy

ByteBabe CLI follows a design philosophy that combines cyberpunk aesthetics with professional functionality. Our goal is to build tools that are not only powerful and efficient, but also visually exciting and enjoyable to use.

## Core Principles

### 1. Cyberpunk Aesthetics with Professional Functionality

- **Visual interfaces**: Use neon colors (blue, pink, green) on dark backgrounds
- **ASCII art**: Incorporate ASCII visual elements in headers and separators
- **Terminology**: Adopt cyberpunk terms without compromising clarity

### 2. Visual and Functional Consistency

- **Color palette**: Keep a consistent palette across all modules
- **Command structure**: Follow consistent patterns for every command
- **Visual feedback**: Provide consistent visual feedback for similar actions

### 3. Developer Experience First

- **Efficiency**: Minimize the number of commands required for common tasks
- **Clarity**: Provide clear, actionable error messages
- **Documentation**: Integrate contextual help at every level

## Code Guidelines

### File Structure

```
bytebabe/
├── bin/                # Main executables
├── commands/           # Command implementations
│   ├── core/           # Essential commands
│   ├── flux/           # API client module
│   └── ...             # Other modules
├── lib/                # Shared libraries
│   ├── core/           # Core functions
│   ├── ui/             # UI components
│   └── utils/          # Utilities
└── docs/               # Documentation
```

### Code Standards

1. **Naming**
   - Functions: `snake_case` (e.g., `parse_json_response`)
   - Variables: `snake_case` (e.g., `response_body`)
   - Constants: `SCREAMING_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`)
   - Files: `kebab-case.sh` (e.g., `http-client.sh`)

2. **Code Documentation**
   ```bash
   # Processes an HTTP response and formats it according to the content type
   #
   # Arguments:
   #   $1 - Response body
   #   $2 - Content type (optional, default: application/json)
   #
   # Returns:
   #   Formatted response
   process_response() {
       local response_body="$1"
       local content_type="${2:-application/json}"
       # ...
   }
   ```

3. **Error Handling**
   ```bash
   if ! command -v jq &> /dev/null; then
       echo -e "${CYBER_RED}Error: jq not found${RESET}"
       echo -e "${CYBER_YELLOW}Install it with: sudo apt install jq${RESET}"
       exit 1
   fi
   ```

## UI/UX Guidelines

### Visual Components

1. **Headers**
   ```
   ╔════════════════════════════════════════════════╗
   ║           BYTEBABE FLUX API CLIENT             ║
   ╚════════════════════════════════════════════════╝
   ```

2. **Menus**
   ```
   1) Send GET request
   2) Send POST request
   3) Configure headers
   4) Save collection
   ```

3. **Feedback**
   ```
   ✓ Request sent successfully (200 OK)
   ✗ Connection failed: Host not found
   ⚠ Warning: Empty response body
   ```

### Color Palette

- **Primary**: Neon cyan (`\033[38;5;51m`) - Titles, success
- **Secondary**: Neon pink (`\033[38;5;198m`) - Highlights, prompts
- **Tertiary**: Neon green (`\033[38;5;46m`) - Confirmations, positive status
- **Warning**: Yellow (`\033[38;5;226m`) - Warnings, attention
- **Error**: Red (`\033[38;5;196m`) - Errors, failures
- **Background**: Deep black (`\033[48;5;0m`) - Default background

### Interaction Flows

1. **Command Flow**
   - Command → Confirmation → Execution → Result → Next steps
   - Always provide a clear exit or path back

2. **Error Flow**
   - Error → Explanation → Suggested solution → Retry/exit option

3. **Configuration Flow**
   - Show current configuration → Change options → Confirmation → Apply

## Documentation Guidelines

### Documentation Structure

1. **Overview**: What it is and what it is for
2. **Installation**: How to install and configure it
3. **Basic Usage**: Essential commands
4. **Advanced Usage**: Advanced features
5. **Reference**: Complete list of commands and options
6. **Troubleshooting**: Common problems and solutions

### Examples

Always include practical, realistic examples:

```bash
# Basic example
bytebabe flux get https://api.example.com/users

# Example with parameters
bytebabe flux get https://api.example.com/users \
  --header "Authorization: Bearer token123" \
  --format json

# Complete workflow example
bytebabe flux collection create my-api
bytebabe flux request add my-api get-users GET https://api.example.com/users
bytebabe flux collection run my-api get-users
```

## Quality Checklist

Before considering a feature complete, verify:

- [ ] The code follows the naming and structure standards
- [ ] Documentation is complete and up to date
- [ ] The user interface is consistent with the rest of the system
- [ ] Error handling is robust and informative
- [ ] Tests cover normal and edge cases
- [ ] The user experience has been considered and optimized
- [ ] The feature preserves the cyberpunk aesthetic without sacrificing usability

## Development Process

1. **Planning**: Define scope, requirements, and acceptance criteria
2. **Design**: Create UI mockups and diagram the architecture
3. **Implementation**: Follow the code and UI guidelines
4. **Testing**: Test manually and with automated scripts
5. **Documentation**: Update the documentation with examples
6. **Review**: Check against the quality checklist
7. **Release**: Integrate into the main system

Remember: ByteBabe CLI is a serious tool with a fun aesthetic. Never sacrifice functionality for style, but do not ignore the positive impact a good visual experience can have on productivity and user satisfaction.
