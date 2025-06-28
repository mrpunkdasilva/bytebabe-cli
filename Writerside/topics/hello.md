# Hello Command

The Hello command displays a welcome message with cyberpunk aesthetics and random quotes.

## Overview

This command provides a friendly greeting with ByteBabe's signature cyberpunk style, displaying random hacker-themed quotes and ASCII art.

## Usage

```bash
bytebabe hello
```

## Features

### Welcome Message
- Cyberpunk-themed ASCII art header
- ByteBabe branding with stylized text
- Color-coded output using ByteBabe's color scheme

### Random Quotes
The command displays one of 16 random cyberpunk-themed quotes:

1. "Wake up, samurai. We have code to write. 🌆"
2. "In a world of 1's and 0's, be the glitch. ⚡"
3. "Hack the planet! 🌍"
4. "Stay connected, stay dangerous. 💻"
5. "Reality is just another simulation. 🕹️"
6. "Code never dies, it just gets recompiled. 🔄"
7. "Living life in neon dreams. 🌈"
8. "Error 404: Normal life not found. 🚫"
9. "Born to code, forced to adult. 🤖"
10. "Keep coding and carry on. ⌨️"
11. "Time to split some bits. 🎯"
12. "Loading personality... please wait... 📶"
13. "chmod 777 your_mind 🧠"
14. "sudo make me_awesome 🚀"
15. "Coffee.exe has stopped working ☕"
16. "git commit -m \"fixed my life\" 💾"

## Output Format

```
╔════════════════════════════════════════════════╗
║           BYTEBABE SAYS HI! (⌐■_■)           ║
╚════════════════════════════════════════════════╝

[Random cyberpunk quote with emoji]
```

## Use Cases

### Welcome Screen
- Display when starting ByteBabe
- Show system status
- Provide motivation for coding

### Testing
- Verify ByteBabe installation
- Check color scheme display
- Test command execution

### Fun Factor
- Add personality to the CLI
- Provide entertainment
- Create memorable experience

## Integration

### ByteBabe CLI
- Uses shared color definitions
- Follows command structure
- Integrates with help system

### System Integration
- Can be called from scripts
- Works in any terminal
- Compatible with shell aliases

## Customization

### Adding Quotes
To add new quotes, modify the `CYBER_QUOTES` array in the source code:

```bash
# Edit the hello.sh file
bytebabe byteedit commands/hello.sh
```

### Color Scheme
The command uses ByteBabe's standard color scheme:
- `CYBER_PINK` - Header borders
- `CYBER_CYAN` - Header text
- `CYBER_GREEN` - Quote text
- `RESET` - Reset colors

## Examples

### Basic Usage
```bash
$ bytebabe hello
╔════════════════════════════════════════════════╗
║           BYTEBABE SAYS HI! (⌐■_■)           ║
╚════════════════════════════════════════════════╝

Wake up, samurai. We have code to write. 🌆
```

### Script Integration
```bash
#!/bin/bash
# Welcome script
echo "Starting development session..."
bytebabe hello
echo "Ready to code!"
```

### Alias Usage
```bash
# Add to .bashrc or .zshrc
alias hi="bytebabe hello"
alias greet="bytebabe hello"
```

## Technical Details

### Random Generation
- Uses `$RANDOM` for quote selection
- Modulo operation ensures valid array index
- Different quote on each execution

### Color Support
- Uses ANSI color codes
- Compatible with most terminals
- Graceful fallback for unsupported terminals

### Performance
- Fast execution
- Minimal resource usage
- No external dependencies

## Troubleshooting

### Color Display Issues
If colors don't display correctly:
```bash
# Check terminal color support
echo -e "\033[0;31mRed\033[0m"

# Force color output
export FORCE_COLOR=1
```

### Quote Display Issues
If quotes appear incorrectly:
```bash
# Check terminal encoding
echo $LANG

# Set UTF-8 encoding
export LANG=en_US.UTF-8
```

## Related Commands

- `bytebabe init` - Initial setup
- `bytebabe help` - Command help
- `bytebabe --version` - Version information

## Future Enhancements

Potential improvements:
- Time-based greetings
- Weather integration
- System status display
- Custom quote collections
- Interactive mode 