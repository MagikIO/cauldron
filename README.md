# Cauldron

### Bringing Magik to Fish Shell 🪄🐟

[![Version](https://img.shields.io/badge/version-0.3.1-blue.svg)](https://github.com/MagikIO/cauldron)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Fish Shell](https://img.shields.io/badge/Fish_Shell-Required-green.svg)](https://fishshell.com/)
[![Node.js](https://img.shields.io/badge/Node.js-v22-brightgreen.svg)](https://nodejs.org/)

> With the help of your beloved familiar, become an arcane master of the terminal.

Cauldron is a comprehensive Fish Shell utility suite that enhances your terminal experience with AI-powered assistance, rich UI components, and powerful developer tools. Whether you're managing packages, searching code, or automating workflows, Cauldron provides the magical touch your terminal needs.

---

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation)
- [Core Concepts](#core-concepts)
- [Usage Examples](#usage-examples)
- [Documentation](#documentation)
- [System Requirements](#system-requirements)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

---

## Features

### 🤖 AI-Powered Familiar
- **Interactive AI Assistant**: Get help from your terminal companion
- **LLM Integration**: Query the llama3.2 model directly from your shell
- **Smart Code Search**: Find and preview code with intelligent suggestions

### 🎨 Rich Terminal UI
- **Visual Components**: Boxes, badges, spinners, and progress indicators
- **Color Palettes**: Pre-configured themes (berry, malory, neodutch)
- **Text Styling**: Bold, italic, underline, and banner effects
- **Visual Effects**: Rain, orbiting volleys, and VHS effects

### 📦 Package Management
- **Multi-Source Installation**: Install from APT, Homebrew, and Snap
- **Language Version Management**: ASDF and NVM integration
- **Automated Updates**: System-wide update orchestration

### 🛠 Developer Tools
- **Workspace Creation**: Quick project scaffolding
- **Repository Management**: Git workflow automation
- **Node.js Utilities**: Environment initialization and Yarn management
- **Code Search**: Recursive grep with fzf preview and VS Code integration

### 🗄 Data Management
- **SQLite Integration**: Built-in database for configuration storage
- **Environment Conversion**: Export environment variables to JSON
- **Backup Automation**: Automatic file backups before editing

---

## Quick Start

```bash
# Clone and install
git clone https://github.com/MagikIO/cauldron.git ~/.cauldron
cd ~/.cauldron
./install.fish

# Start using Cauldron
ask "How do I create a new React component?"  # Query AI
hamsa "TODO"                                    # Search code with preview
familiar "Hello, what can you help me with?"   # Chat with your familiar
cauldron --help                                 # View all commands
```

---

## Installation

### Prerequisites

- **Fish Shell** (v3.0+)
- **Git**
- **curl**
- **Node.js** v22+ (recommended)
- **pnpm** v9+ (optional, for development)

### Standard Installation

```bash
# Create cauldron directory and clone
mkdir -p ~/.cauldron
git clone https://github.com/MagikIO/cauldron.git ~/.cauldron
cd ~/.cauldron
./install.fish
```

The installer will:
1. Set up the `~/.config/cauldron` directory structure
2. Copy all functions to your Fish configuration
3. Initialize the SQLite database
4. Set required environment variables
5. Install essential tools (fzf, bat, cowsay, etc.)
6. Configure your shell for immediate use

### Re-Installation

If you encounter issues and need to re-install while preserving your configuration:

```bash
./internal/__backup_cauldron_and_update.fish
```

### Updating

Keep Cauldron up to date with:

```bash
cauldron --update
```

This runs a multi-step update process including:
- Git repository updates
- System package updates
- Language runtime updates
- Dependency management

For detailed installation instructions, see [docs/INSTALLATION.md](docs/INSTALLATION.md).

---

## Core Concepts

### The Familiar System

Your "familiar" is an AI companion that assists you in the terminal. It can:
- Answer questions about your codebase
- Provide coding assistance
- Display messages with various "emotions" (borg, dead, stoned, paranoid, drunk, greedy)
- Use custom cowsay characters (Yoda, Vault-Boy, Wheatley, etc.)

### Function Organization

Cauldron organizes its functionality into categories:
- **functions/** - Core utilities (installs, node_init, workspace creation)
- **familiar/** - AI companion interface
- **UI/** - Visual components (badges, boxes, spinners)
- **text/** - Text formatting (bold, italic, banners)
- **effects/** - Visual effects (rain, VHS, orbiting)
- **alias/** - Shell shortcuts and aliases
- **packages/** - Package manager integrations

### Environment Variables

Cauldron uses these environment variables:
- `CAULDRON_PATH` - Base installation directory
- `CAULDRON_DATABASE` - SQLite database location
- `CAULDRON_PALETTES` - Color palette definitions
- `CAULDRON_SPINNERS` - Spinner animation definitions
- `CAULDRON_INTERNAL_TOOLS` - Internal tool scripts

---

## Usage Examples

### AI & Search

```bash
# Query the AI model
ask "Explain the difference between map and forEach in JavaScript"

# Search code with live preview
hamsa "authentication"

# Get help from your familiar
familiar "How do I optimize this database query?"
```

### Package Management

```bash
# Install packages from multiple sources
installs bat fzf cowsay

# Install from specific package manager
installs --apt build-essential

# Dry run to see what would be installed
installs --dry-run neovim

# Select preferred package manager
choose_packman
```

### Development Workflows

```bash
# Initialize a Node.js project
node_init my-project

# Create a new workspace
create_workspace my-app

# Update repository with all dependencies
update_repo

# Manage Yarn packages
roll-yarn
```

### File Operations

```bash
# Edit with automatic backup
backup_and_edit config.json

# Create a backup
bak important-file.txt

# Copy Fish functions
cpfunc ./my-functions/ -d
```

### UI & Text Formatting

```bash
# Display styled text
bold "Important message"
italic "Emphasized text"
underline "Underlined text"

# Create banners
banner "Welcome"
beam-banner "Project Name"

# Show spinners
spin "Loading..."

# Display badges
badge "SUCCESS" green
```

### System Administration

```bash
# Detect operating system
detectOS

# Get latest GitHub release
getLatestGithubReleaseTag owner/repo

# Visual git branch selection
visual_git_checkout
```

---

## Documentation

### Core Documentation

- **[INSTALLATION.md](docs/INSTALLATION.md)** - Detailed installation guide
- **[CONFIGURATION.md](docs/CONFIGURATION.md)** - Configuration options and customization
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and design
- **[API.md](docs/API.md)** - Complete function reference
- **[FAMILIAR.md](docs/FAMILIAR.md)** - AI companion guide

### Function-Specific Documentation

Located in `docs/functions/`:
- [ask](docs/functions/ask.md) - AI model querying
- [backup_and_edit](docs/functions/backup_and_edit.md) - File editing with backups
- [cache-pipe](docs/functions/cache-pipe.md) - Caching utilities
- [cpfunc](docs/functions/cpfunc.md) - Function copying
- [create_service](docs/functions/create_service.md) - Service creation
- [dev-it](docs/functions/dev-it.md) - Development tools
- [env2json](docs/functions/env2json.md) - Environment to JSON conversion
- [installs](docs/functions/installs.md) - Package installation
- [node_init](docs/functions/node_init.md) - Node.js initialization
- [update_repo](docs/functions/update_repo.md) - Repository updates

### Getting Help

Every function supports the `-h` or `--help` flag:

```bash
installs -h
ask --help
familiar -h
```

---

## System Requirements

### Required

- **Operating System**: Linux (Ubuntu/Debian recommended) or macOS
- **Shell**: Fish Shell v3.0+
- **Git**: For version control and updates
- **curl**: For downloading resources

### Recommended

- **Node.js**: v22.9.0 (for TypeScript components)
- **pnpm**: v9+ (for dependency management)
- **SQLite3**: For database features
- **fzf**: For fuzzy finding and search
- **bat**: For syntax-highlighted file viewing

### External Dependencies

Cauldron can install these tools automatically:

**Via APT (Linux):**
- bat, cbonsai, cowsay, fortune, jp2a, linuxlogo
- pv, hyfetch, build-essential, procps, curl, git
- rig, toilet, sqlite3

**Via Homebrew:**
- glow, fzf, timg, watchman, lsd, fx, navi

**Via Snap:**
- lolcat-c

**For AI Features:**
- Ollama with llama3.2 model

---

## Project Structure

```
cauldron/
├── node/                    # TypeScript/Node.js components
│   ├── index.ts            # Main entry point
│   ├── Cauldron.ts         # Core orchestrator class
│   ├── DB.ts               # Database manager
│   └── CustomUpdateMech.ts # Update mechanism
│
├── functions/              # Core Fish shell functions
├── familiar/               # AI companion system
├── UI/                     # User interface components
├── text/                   # Text formatting utilities
├── effects/                # Visual effects
├── alias/                  # Shell aliases
├── cli/                    # Command-line interface
├── setup/                  # Installation utilities
├── update/                 # Update system
├── internal/               # Internal utilities
├── tools/                  # Internal tools
├── packages/               # Package manager integrations
│   ├── asdf/              # ASDF version manager
│   └── nvm/               # Node Version Manager
│
├── data/                   # Static data files
│   ├── cauldron.db        # SQLite database
│   ├── palettes.json      # Color palettes
│   ├── spinners.json      # Spinner definitions
│   └── *.cow              # Cowsay characters
│
├── docs/                   # Documentation
│   ├── functions/         # Function-specific docs
│   ├── setup/             # Setup documentation
│   └── text/              # Text utilities docs
│
├── config/                 # Configuration utilities
├── install.fish           # Main installation script
├── dependencies.json      # External dependencies
├── package.json           # NPM configuration
├── tsconfig.json          # TypeScript configuration
└── CHANGELOG.md           # Version history
```

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/MagikIO/cauldron.git
cd cauldron

# Install dependencies
pnpm install

# Run TypeScript components
pnpm run

# Lint code
pnpm lint

# Run tests
./tests/run_tests.fish
```

### Testing

Cauldron uses [Fishtape](https://github.com/jorgebucaran/fishtape) for testing Fish shell functions. Tests are automatically run via GitHub Actions on every push and pull request.

```bash
# Install test dependencies
./tests/setup.fish

# Run all tests
./tests/run_tests.fish

# Run unit tests only
./tests/run_tests.fish --unit

# Run integration tests only
./tests/run_tests.fish --integration
```

See [tests/README.md](tests/README.md) for comprehensive testing documentation.

### Code Style

- Fish shell functions follow consistent patterns
- TypeScript uses strict mode with ES2022 target
- ESLint with @magik_io/lint_golem configuration
- Semantic versioning for releases

### Submitting Changes

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

---

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

### Recent Updates

- **v0.3.1** - Improved directory creation and copying logic
- **v0.3.0** - Database initialization improvements
- **v0.2.1** - Update process bug fixes
- **v0.2.0** - Added database support, new cow files, improved CLI

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Author

**Antonio B.**
Email: Abourassa@AssetVal.com
Repository: [MagikIO/cauldron](https://github.com/MagikIO/cauldron)

---

## Acknowledgments

- Fish Shell community for the excellent shell
- Ollama team for local LLM support
- All the open-source tools that make this possible

---

<p align="center">
  <strong>Bringing Magik to Fish Shell 🪄🐟</strong><br>
  Made with ❤️ by MagikIO
</p>
