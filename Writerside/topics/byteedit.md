# ByteEdit

ByteEdit is a simple text editor utility included with ByteBabe CLI, providing a vim-style interface for quick file editing.

## Overview

ByteEdit offers a lightweight, terminal-based text editor with basic editing capabilities, designed for quick file modifications without leaving the command line.

## Usage

```bash
bytebabe byteedit <filename>
```

## Features

### File Management
- Creates new files if they don't exist
- Loads existing files for editing
- Automatic file saving with confirmation

### Editing Commands
- **Navigation**: Move between lines
- **Editing**: Modify line content
- **Line Operations**: Add and delete lines
- **File Operations**: Save and quit

### Interface
- Line numbers display
- Current line highlighting
- Command prompt
- Status information

## Commands

### Navigation
- `j` or `+` - Move to next line
- `k` or `-` - Move to previous line
- `g` - Go to specific line number

### Editing
- `e` - Edit current line
- `n` - Add new line after current line
- `d` - Delete current line

### File Operations
- `w` - Save file
- `q` - Quit editor (with save prompt if modified)
- `h` - Show help

## Usage Examples

```bash
# Edit existing file
bytebabe byteedit config.txt

# Create and edit new file
bytebabe byteedit newfile.txt

# Edit with full path
bytebabe byteedit /path/to/file.txt
```

## Interface Layout

```
=== ByteEdit - filename.txt (Linhas: 5) ===
Comandos: q (sair), w (salvar), n (nova linha), d (deletar linha), e (editar linha)
          j/+ (baixo), k/- (cima), g (ir para linha), h (ajuda)

1   This is line 1
2 > This is the current line
3   This is line 3
4   This is line 4
5   This is line 5

Linha atual: 2
Comando: 
```

## File Operations

### Creating New Files
If the specified file doesn't exist, ByteEdit will:
1. Create the file
2. Open it in edit mode
3. Allow immediate editing

### Saving Files
- Use `w` command to save
- Modified files show save prompt when quitting
- Files are saved with Unix line endings

### File Format
- Supports plain text files
- UTF-8 encoding
- Unix line endings (LF)

## Editing Workflow

### Basic Editing
1. Navigate to target line using `j`/`k`
2. Use `e` to edit the line
3. Type new content and press Enter
4. Use `w` to save changes

### Adding Content
1. Navigate to desired position
2. Use `n` to add new line
3. Type content for the new line
4. Continue editing as needed

### Removing Content
1. Navigate to target line
2. Use `d` to delete the line
3. Confirm deletion

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `j` | Next line |
| `k` | Previous line |
| `+` | Next line (alternative) |
| `-` | Previous line (alternative) |
| `g` | Go to line number |
| `e` | Edit current line |
| `n` | New line |
| `d` | Delete line |
| `w` | Save file |
| `q` | Quit |
| `h` | Help |

## Error Handling

### File Permission Issues
- Checks file permissions before editing
- Provides clear error messages
- Suggests solutions for permission problems

### Invalid Commands
- Shows error message for unknown commands
- Displays help information
- Continues editing session

### File Save Issues
- Warns about unsaved changes
- Provides save confirmation
- Handles write permission errors

## Limitations

### File Size
- Best for small to medium text files
- Large files may impact performance
- No binary file support

### Features
- Basic text editing only
- No syntax highlighting
- No search and replace
- No undo/redo functionality

## Use Cases

### Configuration Files
- Edit system configuration files
- Modify application settings
- Update script parameters

### Quick Notes
- Create temporary notes
- Edit documentation
- Write simple scripts

### File Inspection
- View file contents
- Make quick modifications
- Check file structure

## Alternatives

For more advanced editing needs, consider:
- `nano` - Simple terminal editor
- `vim` - Advanced text editor
- `emacs` - Extensible editor
- `code` - VS Code command line

## Integration

ByteEdit integrates with ByteBabe CLI:
- Consistent command structure
- Shared configuration
- Error handling patterns
- Documentation system 