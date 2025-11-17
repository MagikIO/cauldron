# API Reference

Complete reference for all Cauldron functions organized by category.

## Table of Contents

- [AI & Search Functions](#ai--search-functions)
- [Package Management](#package-management)
- [File Operations](#file-operations)
- [Development Tools](#development-tools)
- [UI Components](#ui-components)
- [Text Formatting](#text-formatting)
- [System Utilities](#system-utilities)
- [Git Operations](#git-operations)
- [CLI Commands](#cli-commands)

---

## AI & Search Functions

### `ask`

Query the llama3.2 AI model.

```bash
ask [OPTIONS] <question>
```

**Options:**
- `-h, --help` - Show help
- `-r, --raw` - Output raw response (no markdown rendering)

**Examples:**
```bash
ask "How do I create a React component?"
ask "Explain async/await in JavaScript"
ask -r "What is a closure?" | jq .
```

**Requirements:** Ollama with llama3.2 model

---

### `hamsa`

Search code recursively with fzf preview and open results in VS Code.

```bash
hamsa <search_term>
```

**Features:**
- Recursive grep search
- Live fzf preview with syntax highlighting
- Opens selected file in VS Code at matching line

**Examples:**
```bash
hamsa "TODO"
hamsa "function authenticate"
hamsa "import React"
```

**Requirements:** fzf, bat, VS Code

---

### `familiar`

Interact with your AI companion.

```bash
familiar [OPTIONS] <message>
```

**Options:**
- `-h, --help` - Show help
- `--borg` - Robotic emotion
- `--dead` - X_X emotion
- `--stoned` - Relaxed emotion
- `--paranoid` - Nervous emotion
- `--drunk` - Slurred emotion
- `--greedy` - Money emotion
- `--trogdor`, `--yoda`, etc. - Character selection

**Examples:**
```bash
familiar "Hello!"
familiar "I need help" --paranoid
familiar "Show me wisdom" --yoda
```

---

### `f-says`

Make your familiar speak (cowsay wrapper).

```bash
f-says <message>
```

---

### `f-thinks`

Make your familiar think (cowthink wrapper).

```bash
f-thinks <thought>
```

---

## Package Management

### `installs`

Install packages from multiple sources.

```bash
installs [OPTIONS] <packages...>
```

**Options:**
- `-h, --help` - Show help
- `-d, --dry-run` - Preview without installing
- `-f, --file` - Install from file
- `--apt` - Force APT package manager
- `--brew` - Force Homebrew
- `--snap` - Force Snap

**Examples:**
```bash
installs bat fzf cowsay
installs --apt build-essential
installs -d neovim
installs -f requirements.txt
```

---

### `choose_packman`

Interactively select preferred package manager.

```bash
choose_packman
```

**Workflow:**
1. Detects available package managers
2. Presents selection menu
3. Saves preference to database

---

### `nvm_update_node`

Update Node.js using NVM.

```bash
nvm_update_node
```

---

### ASDF Integration

```bash
# Update Node.js via ASDF
__cauldron_asdf_update_node

# Update Ruby via ASDF
__cauldron_asdf_update_ruby

# Update Go via ASDF
__cauldron_asdf_update_go
```

---

## File Operations

### `backup_and_edit`

Edit a file with automatic backup creation.

```bash
backup_and_edit <file>
```

**Features:**
- Creates timestamped backup
- Opens file in default editor
- Preserves original on failure

**Example:**
```bash
backup_and_edit config.json
# Creates: config.json.bak.20240101_120000
```

---

### `bak`

Create a backup of a file.

```bash
bak <file>
```

**Example:**
```bash
bak important.txt
# Creates: important.txt.bak
```

---

### `cpfunc`

Copy Fish shell functions to Fish config directory.

```bash
cpfunc [OPTIONS] <source>
```

**Options:**
- `-h, --help` - Show help
- `-d, --directory` - Copy all functions from directory
- `-v, --verbose` - Verbose output

**Examples:**
```bash
cpfunc my_function.fish
cpfunc ./functions/ -d
cpfunc -v custom.fish
```

---

### `env2json`

Convert environment variables to JSON format.

```bash
env2json [OPTIONS]
```

**Options:**
- `-h, --help` - Show help
- `-p, --prefix` - Filter by prefix

**Examples:**
```bash
env2json
env2json -p CAULDRON
env2json > env.json
```

---

### `cache-pipe`

Cache piped input for reuse.

```bash
command | cache-pipe <cache_name>
cache-pipe <cache_name>  # Retrieve
```

**Example:**
```bash
ls -la | cache-pipe dir_listing
cache-pipe dir_listing  # Show cached result
```

---

## Development Tools

### `node_init`

Initialize a Node.js project.

```bash
node_init [OPTIONS] <project_name>
```

**Options:**
- `-h, --help` - Show help
- `-t, --typescript` - Initialize with TypeScript
- `-y, --yarn` - Use Yarn instead of npm

**Examples:**
```bash
node_init my-project
node_init -t typescript-app
node_init -y yarn-project
```

---

### `create_workspace`

Create a new development workspace.

```bash
create_workspace <workspace_name>
```

**Features:**
- Creates directory structure
- Initializes git repository
- Sets up basic configuration

---

### `create_service`

Create a systemd service file.

```bash
create_service [OPTIONS] <service_name>
```

**Options:**
- `-h, --help` - Show help
- `-d, --description` - Service description
- `-c, --command` - Command to execute

**Example:**
```bash
create_service myapp -d "My Application" -c "/usr/bin/myapp"
```

---

### `dev-it`

Development helper utilities.

```bash
dev-it [OPTIONS]
```

**Features:**
- Quick development environment setup
- Common development tasks

---

### `roll-yarn`

Manage and update Yarn packages.

```bash
roll-yarn [OPTIONS]
```

**Features:**
- Update all dependencies
- Interactive package selection
- Version management

---

### `iterate`

Iterate and release npm packages.

```bash
iterate [OPTIONS]
```

**Features:**
- Version bumping
- Changelog generation
- Git tagging
- npm publishing

---

### `update_repo`

Update repository with all dependencies.

```bash
update_repo
```

**Performs:**
- Git pull
- Package updates
- Build verification

---

### `funced`

Enhanced Fish function editor.

```bash
funced <function_name>
```

**Features:**
- Opens function in editor
- Auto-saves on close
- Syntax validation

---

### `fished`

Fish editing utilities.

```bash
fished [OPTIONS]
```

---

## UI Components

### `badge`

Display a status badge.

```bash
badge <text> [color]
```

**Colors:** red, green, blue, yellow, magenta, cyan

**Examples:**
```bash
badge "SUCCESS" green
badge "ERROR" red
badge "WARNING" yellow
```

---

### `badges`

Display multiple badges.

```bash
badges <badge1> <badge2> ...
```

---

### `box`

Draw a text box.

```bash
box <text>
```

**Example:**
```bash
box "Important Message"
# Output:
# ┌─────────────────────┐
# │  Important Message  │
# └─────────────────────┘
```

---

### `spinner`

Display a loading spinner.

```bash
spin <message> [spinner_type]
```

**Spinner Types:** dots, line, arc

**Example:**
```bash
spin "Loading..." dots
# Output: ⠋ Loading...
```

---

### `confirm`

Display a yes/no confirmation prompt.

```bash
confirm <question>
```

**Example:**
```bash
if confirm "Continue?"
    echo "Proceeding..."
end
```

---

### `choose`

Display a selection menu.

```bash
choose <options...>
```

**Example:**
```bash
set selection (choose "Option 1" "Option 2" "Option 3")
echo "You chose: $selection"
```

---

### `hr`

Display a horizontal rule.

```bash
hr [character]
```

**Example:**
```bash
hr "="
# Output: ========================================
```

---

### `print_center`

Print text centered in terminal.

```bash
print_center <text>
```

---

### `print_separator`

Print a visual separator.

```bash
print_separator
```

---

### `palette`

Get color from palette.

```bash
palette <palette_name> <color_key>
```

**Example:**
```bash
set color (palette berry primary)
set_color $color
```

---

### `color-block`

Display a color block.

```bash
color-block <color>
```

---

## Text Formatting

### `bold`

Display bold text.

```bash
bold <text>
```

**Example:**
```bash
bold "Important!"
```

---

### `italic`

Display italic text.

```bash
italic <text>
```

**Example:**
```bash
italic "Emphasized"
```

---

### `underline`

Display underlined text.

```bash
underline <text>
```

**Example:**
```bash
underline "Title"
```

---

### `banner`

Display a banner.

```bash
banner <text>
```

**Example:**
```bash
banner "CAULDRON"
```

---

### `beam-banner`

Display a beam-style banner.

```bash
beam-banner <text>
```

---

### `black-hole-banner`

Display a black-hole style banner.

```bash
black-hole-banner <text>
```

---

### `styled-banner`

Display a styled banner (configurable).

```bash
styled-banner <text>
```

---

## System Utilities

### `detectOS`

Detect operating system.

```bash
detectOS
```

**Returns:** Operating system identifier

---

### `getLatestGithubReleaseTag`

Get the latest release tag from a GitHub repository.

```bash
getLatestGithubReleaseTag <owner/repo>
```

**Example:**
```bash
getLatestGithubReleaseTag MagikIO/cauldron
# Output: v0.3.1
```

---

### `getLatestGithubReleaseAsJSON`

Get the latest release information as JSON.

```bash
getLatestGithubReleaseAsJSON <owner/repo>
```

---

### `peek-at-fish`

Inspect Fish shell internals.

```bash
peek-at-fish [OPTIONS]
```

**Features:**
- View function definitions
- Inspect variables
- Debug Fish scripts

---

### `load_path_first`

Modify PATH to load a directory first.

```bash
load_path_first <directory>
```

**Example:**
```bash
load_path_first /usr/local/bin
```

---

### `scope_check`

Validate variable scope.

```bash
scope_check <variable_name>
```

---

### `set_prefs`

Set user preferences.

```bash
set_prefs <key> <value>
```

---

### `pick-from`

Random selection from options.

```bash
pick-from <options...>
```

**Example:**
```bash
pick-from "red" "blue" "green"
# Randomly returns one option
```

---

## Git Operations

### `visual_git_checkout`

Interactive git branch selection.

```bash
visual_git_checkout
```

**Features:**
- Lists all branches
- fzf fuzzy selection
- Preview branch info

---

### `update_git_alias`

Update git alias definitions.

```bash
update_git_alias
```

---

## CLI Commands

### `cauldron`

Main Cauldron CLI.

```bash
cauldron [OPTIONS] [COMMAND]
```

**Options:**
- `-h, --help` - Show help
- `-v, --version` - Show version
- `--update` - Update Cauldron

**Commands:**
- `--new-docs` - Open documentation
- `--update` - Run update process

**Examples:**
```bash
cauldron --help
cauldron --version
cauldron --update
```

---

## Visual Effects

### `rain-effect`

Display a rain animation.

```bash
rain-effect
```

---

### `orbiting-volley-effect`

Display orbiting volley animation.

```bash
orbiting-volley-effect
```

---

### `vhs-effect`

Display VHS-style effect.

```bash
vhs-effect
```

---

## Aliases

Quick shortcuts included with Cauldron:

| Alias | Command | Description |
|-------|---------|-------------|
| `la` | `ls -la` | List all files |
| `ll` | `ls -l` | Long listing |
| `lla` | `ls -la` | Long list all |
| `lst` | `ls -lt` | List by time |
| `lt` | `ls -lt` | Time sorted |
| `n+` | - | Node version up |
| `n++` | - | Node version latest |
| `yarn+` | - | Yarn shortcuts |
| `shiny` | - | Sparkle text |
| `sassy` | - | Sassy output |
| `lolcat` | - | Rainbow text |
| `whatami` | - | System info |
| `trains` | - | ASCII train |

---

## Internal Functions

These functions are prefixed with `__` and are for internal use:

- `__init_cauldron_DB.fish` - Initialize database
- `__init_cauldron_vars.fish` - Initialize variables
- `__install_essential_tools.fish` - Install dependencies
- `__list_familiars.fish` - List cowsay characters
- `__cauldron_*_update_step.fish` - Update process steps

---

## Getting Function Help

Every Cauldron function supports help:

```bash
function_name -h
function_name --help
```

This displays:
- Usage syntax
- Available options
- Examples
- Version information

---

## Error Codes

Standard return codes:

| Code | Meaning |
|------|---------|
| `0` | Success |
| `1` | General error |
| `2` | Invalid arguments |
| `3` | Missing dependencies |
| `4` | Permission denied |
| `5` | Network error |

---

## See Also

- **[CONFIGURATION.md](CONFIGURATION.md)** - Configuration options
- **[FAMILIAR.md](FAMILIAR.md)** - AI companion details
- **[ARCHITECTURE.md](../ARCHITECTURE.md)** - System design
- **[CONTRIBUTING.md](../CONTRIBUTING.md)** - Development guidelines

---

Magic at your fingertips! 🪄🐟
