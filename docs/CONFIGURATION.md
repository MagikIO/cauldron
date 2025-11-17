# Configuration Guide

This guide explains how to configure and customize Cauldron to suit your needs.

## Table of Contents

- [Environment Variables](#environment-variables)
- [Color Palettes](#color-palettes)
- [Spinner Customization](#spinner-customization)
- [Familiar Configuration](#familiar-configuration)
- [Package Manager Preferences](#package-manager-preferences)
- [Database Configuration](#database-configuration)
- [Fish Shell Integration](#fish-shell-integration)
- [Advanced Configuration](#advanced-configuration)

---

## Environment Variables

Cauldron uses several environment variables for configuration. These are set as universal Fish variables (persistent across sessions).

### Core Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `CAULDRON_PATH` | Base installation directory | `~/.config/cauldron` |
| `CAULDRON_DATABASE` | SQLite database file | `$CAULDRON_PATH/data/cauldron.db` |
| `CAULDRON_PALETTES` | Color palette definitions | `$CAULDRON_PATH/data/palettes.json` |
| `CAULDRON_SPINNERS` | Spinner animation data | `$CAULDRON_PATH/data/spinners.json` |
| `CAULDRON_INTERNAL_TOOLS` | Internal tools directory | `$CAULDRON_PATH/tools` |

### Viewing Current Configuration

```bash
# View all Cauldron variables
env | grep CAULDRON

# View specific variable
echo $CAULDRON_PATH
```

### Modifying Variables

```bash
# Change a variable (universal, persists across sessions)
set -Ux CAULDRON_PATH /new/path/to/cauldron

# Reset to default
set -e CAULDRON_PATH
set -Ux CAULDRON_PATH $HOME/.config/cauldron
```

### Re-initializing Variables

If variables become corrupted or missing:

```bash
$CAULDRON_INTERNAL_TOOLS/__init_cauldron_vars.fish
```

---

## Color Palettes

Cauldron includes pre-defined color palettes for UI components.

### Available Palettes

Located in `$CAULDRON_PALETTES` (default: `~/.config/cauldron/data/palettes.json`)

```json
{
  "berry": {
    "primary": "#8B5CF6",
    "secondary": "#EC4899",
    "accent": "#F472B6",
    "background": "#1F1B24",
    "text": "#E5E5E5"
  },
  "malory": {
    "primary": "#10B981",
    "secondary": "#3B82F6",
    "accent": "#06B6D4",
    "background": "#111827",
    "text": "#F9FAFB"
  },
  "neodutch": {
    "primary": "#F59E0B",
    "secondary": "#EF4444",
    "accent": "#F97316",
    "background": "#292524",
    "text": "#FEF3C7"
  }
}
```

### Creating a Custom Palette

1. Edit the palettes file:
   ```bash
   $EDITOR $CAULDRON_PALETTES
   ```

2. Add your palette:
   ```json
   {
     "my_palette": {
       "primary": "#YOUR_COLOR",
       "secondary": "#YOUR_COLOR",
       "accent": "#YOUR_COLOR",
       "background": "#YOUR_COLOR",
       "text": "#YOUR_COLOR"
     }
   }
   ```

3. Use in your scripts:
   ```fish
   palette my_palette primary
   ```

### Using Palettes in Functions

```fish
# Get a color from palette
set color (palette berry primary)

# Apply to output
set_color $color
echo "Colored text"
set_color normal
```

---

## Spinner Customization

Spinners provide visual feedback during long operations.

### Default Spinners

Located in `$CAULDRON_SPINNERS` (default: `~/.config/cauldron/data/spinners.json`)

```json
{
  "dots": {
    "frames": ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"],
    "interval": 80
  },
  "line": {
    "frames": ["-", "\\", "|", "/"],
    "interval": 130
  },
  "arc": {
    "frames": ["◜", "◠", "◝", "◞", "◡", "◟"],
    "interval": 100
  }
}
```

### Adding Custom Spinners

1. Edit the spinners file:
   ```bash
   $EDITOR $CAULDRON_SPINNERS
   ```

2. Add your spinner:
   ```json
   {
     "my_spinner": {
       "frames": ["🌑", "🌒", "🌓", "🌔", "🌕", "🌖", "🌗", "🌘"],
       "interval": 120
     }
   }
   ```

### Using Spinners

```fish
# Start a spinner
spin "Loading..." dots

# Custom spinner
spin "Processing..." my_spinner
```

---

## Familiar Configuration

Your AI familiar can be customized in several ways.

### Choosing a Familiar Character

Available cowsay characters:

- `trogdor` - The Burninator
- `vault-boy` - Fallout mascot
- `wheatley` - Portal 2 AI
- `wilfred` - Dog character
- `woodstock` - Peanuts bird
- `yoda` - Star Wars master

```bash
# List available familiars
__list_familiars

# Use a specific familiar
familiar "Message" --yoda
```

### Familiar Emotions

Set the mood of your familiar's response:

```bash
# Available emotions
familiar "I'm feeling..." --borg      # Robotic (= =)
familiar "I'm feeling..." --dead      # X_X
familiar "I'm feeling..." --stoned    # Relaxed
familiar "I'm feeling..." --paranoid  # Nervous
familiar "I'm feeling..." --drunk     # Slurred
familiar "I'm feeling..." --greedy    # $$
```

### Creating Custom Cow Files

1. Create a new `.cow` file:
   ```bash
   $EDITOR $CAULDRON_PATH/data/my_character.cow
   ```

2. Follow cowsay format:
   ```
   $the_cow = <<"EOC";
           $thoughts
            $thoughts
             (  )
              ^^
   EOC
   ```

3. Use in familiar:
   ```bash
   familiar "Hello!" --my_character
   ```

### AI Model Configuration

For the `ask` function, configure Ollama:

```bash
# Check available models
ollama list

# Pull a different model
ollama pull mistral

# Use in ask (modify ask.fish if needed)
# Default is llama3.2
```

---

## Package Manager Preferences

Configure which package manager Cauldron prefers.

### Setting Preference

```bash
# Interactive selection
choose_packman
```

This will prompt you to choose between:
- APT (Ubuntu/Debian)
- Homebrew (macOS/Linux)
- Snap

### Manual Configuration

The preference is stored in the database. To check:

```bash
sqlite3 $CAULDRON_DATABASE "SELECT * FROM preferences WHERE key='package_manager';"
```

### Package Sources

Edit `$CAULDRON_PATH/dependencies.json` to modify available packages:

```json
{
  "apt": ["bat", "cowsay", "fzf"],
  "brew": ["glow", "lsd", "navi"],
  "snap": ["lolcat-c"]
}
```

---

## Database Configuration

Cauldron uses SQLite for data storage.

### Database Location

Default: `~/.config/cauldron/data/cauldron.db`

### Schema

View the database schema:

```bash
sqlite3 $CAULDRON_DATABASE ".schema"
```

Main tables:
- `dependencies` - Installed packages
- `preferences` - User preferences
- `metadata` - System information

### Database Operations

```bash
# View all tables
sqlite3 $CAULDRON_DATABASE ".tables"

# Query data
sqlite3 $CAULDRON_DATABASE "SELECT * FROM dependencies;"

# Export data
sqlite3 $CAULDRON_DATABASE ".dump" > backup.sql
```

### Re-initializing Database

If the database becomes corrupted:

```bash
# Backup existing
cp $CAULDRON_DATABASE $CAULDRON_DATABASE.bak

# Re-initialize
rm $CAULDRON_DATABASE
$CAULDRON_INTERNAL_TOOLS/__init_cauldron_DB.fish
```

---

## Fish Shell Integration

### config.fish Integration

Add Cauldron to your Fish config:

```fish
# ~/.config/fish/config.fish

# Ensure Cauldron variables are loaded
if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.config/cauldron
end

# Load Cauldron initialization if available
if test -f $CAULDRON_PATH/tools/__init_cauldron_vars.fish
    source $CAULDRON_PATH/tools/__init_cauldron_vars.fish
end
```

### Custom Aliases

Add personal aliases in `~/.config/fish/config.fish`:

```fish
# Quick familiar access
alias f "familiar"
alias a "ask"

# Package installation shortcut
alias i "installs"

# Search shortcut
alias h "hamsa"
```

### Function Overrides

To override a Cauldron function:

1. Create your version in `~/.config/fish/functions/`
2. Fish will use your version (loaded first)

```fish
# ~/.config/fish/functions/familiar.fish
function familiar --description "My custom familiar"
    # Your implementation
end
```

---

## Advanced Configuration

### Logging

Configure logging behavior:

```bash
# Log location
echo $CAULDRON_PATH/logs/cauldron.log

# View logs
tail -f $CAULDRON_PATH/logs/cauldron.log

# Clear logs
echo "" > $CAULDRON_PATH/logs/cauldron.log
```

### Update Configuration

Customize update behavior in `update/cauldron_update.fish`:

```fish
# Default update steps (can be reordered or disabled)
set update_steps \
    "invoke_sudo" \
    "visual_checkout" \
    "prune_branches" \
    "update_aquarium" \
    "package_update" \
    "system_update" \
    "homebrew_update" \
    "yarn_update" \
    "upgrade_deps"
```

### Banner Configuration

Customize banner fonts:

```bash
# Preview fonts
preview_banner_font

# Choose font
choose_banner_font
```

### Node.js Configuration

For TypeScript components:

```bash
# Edit tsconfig.json
$EDITOR $CAULDRON_PATH/../tsconfig.json

# Key settings
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ES2022",
    "strict": true
  }
}
```

### ESLint Configuration

Customize linting:

```bash
$EDITOR eslint.config.js
```

Default uses `@magik_io/lint_golem` for strict TypeScript checking.

---

## Configuration Files Reference

| File | Purpose | Location |
|------|---------|----------|
| `palettes.json` | Color themes | `data/` |
| `spinners.json` | Loading animations | `data/` |
| `dependencies.json` | Package registry | Root |
| `cauldron.db` | SQLite database | `data/` |
| `schema.sql` | DB schema | `data/` |
| `*.cow` | Cowsay characters | `data/` |
| `config.fish` | Fish configuration | `~/.config/fish/` |

---

## Best Practices

### 1. Backup Your Configuration

```bash
# Create backup
cp -r $CAULDRON_PATH/data ~/cauldron-backup/
```

### 2. Document Your Changes

Keep notes on customizations:
```bash
# Add to your config
# MY CUSTOMIZATIONS:
# - Changed primary palette color
# - Added custom spinner
# - Modified familiar default
```

### 3. Version Control Your Config

```bash
# Track your configuration
cd $CAULDRON_PATH
git init
git add data/palettes.json data/spinners.json
git commit -m "My custom configuration"
```

### 4. Test Changes

Before modifying system-wide:
```bash
# Test in isolated environment
fish -c "source modified_function.fish; test_function"
```

---

## Resetting to Defaults

### Reset All Configuration

```bash
# Remove custom config
rm -rf $CAULDRON_PATH

# Reinstall
cd ~/.cauldron
./install.fish
```

### Reset Specific Components

```bash
# Reset palettes
cp ~/.cauldron/data/palettes.json $CAULDRON_PALETTES

# Reset spinners
cp ~/.cauldron/data/spinners.json $CAULDRON_SPINNERS

# Reset database
rm $CAULDRON_DATABASE
$CAULDRON_INTERNAL_TOOLS/__init_cauldron_DB.fish
```

---

## Next Steps

- **Explore functions**: See `docs/API.md`
- **Customize familiar**: See `docs/FAMILIAR.md`
- **Contribute**: See `CONTRIBUTING.md`

---

Your configuration, your cauldron! 🪄🐟
