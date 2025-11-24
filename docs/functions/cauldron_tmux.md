# cauldron_tmux

Manage TMUX installation and configuration through Cauldron.

## Synopsis

```fish
cauldron_tmux [OPTIONS]
cauldron --tmux[=ACTION]
```

## Description

The `cauldron_tmux` function provides a comprehensive interface for managing TMUX (Terminal Multiplexer) installations, configurations, and backups. It can be called directly or through the main `cauldron` command.

## Options

### Direct Function Options

- `-h, --help` - Show help message
- `-v, --version` - Show version number
- `-i, --install` - Install TMUX and TPM (TMUX Plugin Manager)
- `-m, --modify` - Modify TMUX configuration interactively
- `-r, --remove` - Remove TMUX, config files, and plugins
- `-b, --backup` - Backup current TMUX configuration
- `-R, --restore` - Restore TMUX configuration from backup
- `-l, --list-backups` - List available TMUX configuration backups

### Via Main Cauldron Command

```fish
cauldron --tmux=install   # Install TMUX
cauldron --tmux=modify    # Modify configuration
cauldron --tmux=remove    # Remove TMUX
cauldron --tmux=backup    # Backup configuration
cauldron --tmux=restore   # Restore from backup
cauldron --tmux=list      # List backups
cauldron --tmux          # Interactive menu
```

## Features

### Installation

The installation feature:
- Detects your OS (macOS/Linux) and installs TMUX via Homebrew or apt
- Creates a default configuration with sensible defaults
- Installs TPM (TMUX Plugin Manager) automatically
- Sets up useful plugins (tmux-sensible, tmux-resurrect)
- Backs up existing configurations before replacing

**Default Configuration Includes:**
- Prefix key: `Ctrl-Space` (instead of `Ctrl-b`)
- Mouse support enabled
- History limit: 10,000 lines
- Auto-renumber windows
- Split panes with `|` and `-`
- Reload config with `Ctrl-Space + r`

### Modification

Interactive modification options:
- **Change prefix key** - Switch between `C-Space`, `C-a`, `C-b`, or `C-x`
- **Toggle mouse support** - Enable/disable mouse support
- **Edit config file** - Open configuration in your editor
- **Add plugins** - Easily add new TMUX plugins

All modifications automatically create a backup before making changes.

### Backup & Restore

The backup system:
- Creates timestamped backups in `~/.config/cauldron/backups/tmux/`
- Backs up both configuration file and plugins directory
- Lists all available backups with dates and sizes
- Restores complete configurations including plugins
- Always creates a pre-restore backup for safety

### Removal

Safe removal process:
- Backs up configuration before removal
- Removes `~/.tmux.conf` and `~/.tmux/` directory
- Optionally uninstalls TMUX package
- Preserves backups even after removal
- Requires confirmation before proceeding

## Examples

### Install TMUX with default configuration

```fish
cauldron_tmux --install
# or
cauldron --tmux=install
```

### Modify TMUX configuration interactively

```fish
cauldron_tmux --modify
# or
cauldron --tmux=modify
```

### Backup current configuration

```fish
cauldron_tmux --backup
# or
cauldron --tmux=backup
```

### List all backups

```fish
cauldron_tmux --list-backups
# or
cauldron --tmux=list
```

### Restore from backup

```fish
cauldron_tmux --restore
# or
cauldron --tmux=restore
```

### Remove TMUX completely

```fish
cauldron_tmux --remove
# or
cauldron --tmux=remove
```

### Interactive menu (no arguments)

```fish
cauldron_tmux
# or
cauldron --tmux
```

## Requirements

- **Fish Shell** - Required for running the function
- **gum** - Optional, enables interactive menus (installed by Cauldron)
- **git** - Required for TPM installation
- **Homebrew** (macOS) or **apt** (Linux) - For installing TMUX

## Files

- `~/.tmux.conf` - Main TMUX configuration file
- `~/.tmux/plugins/` - TMUX plugins directory
- `~/.config/cauldron/backups/tmux/` - Backup storage location

## After Installation

Once TMUX is installed:

1. Start TMUX:
   ```fish
   tmux
   ```

2. Install plugins (inside TMUX):
   ```
   Ctrl-Space + I
   ```

3. Reload configuration (inside TMUX):
   ```
   Ctrl-Space + r
   ```

4. Common TMUX commands:
   - `Ctrl-Space + c` - New window
   - `Ctrl-Space + |` - Split horizontally
   - `Ctrl-Space + -` - Split vertically
   - `Ctrl-Space + d` - Detach session
   - `tmux attach` - Reattach to session

## Notes

- All modifications automatically create backups
- Backups are never deleted, even when removing TMUX
- The interactive menu requires `gum` (installed by Cauldron)
- TPM (TMUX Plugin Manager) is included for easy plugin management

## See Also

- [TMUX Official Documentation](https://github.com/tmux/tmux/wiki)
- [TPM (TMUX Plugin Manager)](https://github.com/tmux-plugins/tpm)
- [Awesome TMUX](https://github.com/rothgar/awesome-tmux)

## Version

1.0.0

## Category

Functions
