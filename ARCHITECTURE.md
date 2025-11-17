# Cauldron Architecture

This document describes the high-level architecture of Cauldron, explaining how its components work together to provide a magical terminal experience.

## Table of Contents

- [Overview](#overview)
- [Design Philosophy](#design-philosophy)
- [System Layers](#system-layers)
- [Core Components](#core-components)
- [Data Flow](#data-flow)
- [Module Organization](#module-organization)
- [Extension Points](#extension-points)
- [Technology Stack](#technology-stack)

---

## Overview

Cauldron is a multi-layered Fish Shell utility suite that combines:

1. **Fish Shell Functions** - Primary user interface and utilities
2. **TypeScript/Node.js Backend** - Complex logic and data management
3. **SQLite Database** - Persistent storage and configuration
4. **External Tool Integration** - Package managers, AI models, and CLI tools

```
┌─────────────────────────────────────────────────────┐
│                    User Interface                    │
│         (Fish Shell Functions & CLI)                 │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│                   Core Services                      │
│    (Familiar, Package Management, UI Components)     │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│                 Data & Storage                       │
│       (SQLite, JSON Config, Environment)             │
└─────────────────────┬───────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────┐
│              External Integrations                   │
│     (Ollama, Package Managers, Git, System Tools)    │
└─────────────────────────────────────────────────────┘
```

---

## Design Philosophy

### 1. **Familiarity as a Metaphor**

The "familiar" concept (from magical lore) represents an AI companion that assists users. This metaphor guides:
- Personification of helper functions
- Emotional states for output (stoned, paranoid, drunk, etc.)
- Cowsay characters as visual representation

### 2. **Progressive Enhancement**

Features work at multiple levels:
- Basic: Pure Fish shell functionality
- Enhanced: With optional dependencies (fzf, bat)
- Full: With AI capabilities (Ollama)

### 3. **Non-Intrusive Installation**

Cauldron respects the user's environment:
- Installs to `~/.config/cauldron` (XDG compliant)
- Doesn't override existing functions without permission
- Uses universal Fish variables for configuration

### 4. **Modular Architecture**

Each component is independently functional:
- Functions can be used standalone
- No hard dependencies between modules
- Graceful degradation when dependencies are missing

---

## System Layers

### Layer 1: User Interface

**Location**: `cli/`, `functions/`, `familiar/`

This layer handles direct user interaction:

```fish
# CLI entry point
cauldron [command] [options]

# Direct function calls
ask "question"
familiar "message"
installs package-name
```

**Responsibilities**:
- Command-line argument parsing
- User input validation
- Output formatting and display
- Help documentation

### Layer 2: Core Services

**Location**: `functions/`, `UI/`, `text/`, `effects/`

Business logic and utilities:

```
┌──────────────┬──────────────┬──────────────┐
│   Familiar   │    Package   │      UI      │
│   Services   │  Management  │  Components  │
├──────────────┼──────────────┼──────────────┤
│ - ask.fish   │- installs    │- badge       │
│ - f-says     │- choose_pack │- box         │
│ - f-thinks   │- node_init   │- spinner     │
└──────────────┴──────────────┴──────────────┘
```

### Layer 3: Data Management

**Location**: `node/`, `data/`

TypeScript backend for complex operations:

```typescript
// Database Manager
class DatabaseManager {
    loadTableMetadata()
    createTable()
    insertJSON()
}

// Main Orchestrator
class Cauldron {
    init()
    info()
    toString()
}
```

### Layer 4: Storage

**Location**: `data/`

Persistent storage mechanisms:

- **SQLite Database** (`cauldron.db`) - Structured data
- **JSON Files** - Configuration and metadata
  - `palettes.json` - Color schemes
  - `spinners.json` - Animation definitions
  - `dependencies.json` - External tool registry
- **Cow Files** (`.cow`) - Character art

### Layer 5: External Integrations

System-level integrations:

```
┌──────────────────────────────────────┐
│         External Services            │
├──────────┬──────────┬────────────────┤
│  Ollama  │   Git    │ Package Mgrs   │
│ (AI/LLM) │          │ (apt/brew/snap)│
└──────────┴──────────┴────────────────┘
```

---

## Core Components

### 1. Cauldron Main Class

**File**: `node/Cauldron.ts`

The central orchestrator that manages:
- Dependency tracking across package managers
- System information aggregation
- Version management

```typescript
class Cauldron {
    version: string = '1.0.6';
    dependencies: Map<string, string[]>;
    db: DatabaseManager;

    async init(): Promise<Cauldron>;
    info(): string;
}
```

### 2. Database Manager

**File**: `node/DB.ts`

Abstraction over SQLite:
- Schema management
- CRUD operations
- JSON data serialization

```typescript
class DatabaseManager {
    async loadTableMetadata(): Promise<void>;
    async createTable(name: string, schema: object): Promise<void>;
    async insertJSON(table: string, data: object): Promise<void>;
}
```

### 3. Custom Update Mechanism

**File**: `node/CustomUpdateMech.ts`

Orchestrates the update process:

```
Update Steps:
1. Invoke Sudo
2. Visual Git Checkout
3. Prune Local Branches
4. Update Aquarium
5. Package Manager Update
6. System Update
7. Homebrew Update
8. Yarn/NPM Update
9. Upgrade Dependencies
```

### 4. Familiar System

**Files**: `familiar/*.fish`

AI companion interface:

```
familiar.fish     → Main interface
├── f-says.fish   → Speech output (cowsay)
├── f-thinks.fish → Thought output
└── say.fish      → Base speech utility
```

Emotions map to cowsay modes:
- `borg` - Robotic
- `dead` - X_X
- `stoned` - Relaxed
- `paranoid` - Nervous
- `drunk` - Slurred
- `greedy` - Dollar signs

### 5. Package Installation System

**File**: `functions/installs.fish`

Multi-source package manager:

```
installs
├── Check preferred package manager
├── Validate package availability
├── Execute installation
│   ├── APT (sudo apt-get install)
│   ├── Homebrew (brew install)
│   └── Snap (sudo snap install)
└── Update database records
```

### 6. UI Component System

**Location**: `UI/`

Visual building blocks:

```
UI Components
├── badge.fish      → Status badges [SUCCESS]
├── box.fish        → Text boxes ┌─────┐
├── spinner.fish    → Loading animation ⠋⠙⠹
├── palette.fish    → Color management
├── confirm.fish    → Yes/No prompts
└── choose.fish     → Selection menus
```

---

## Data Flow

### Installation Flow

```
User runs ./install.fish
        │
        ▼
┌───────────────────┐
│ Set Environment   │ → CAULDRON_PATH, CAULDRON_DATABASE
│ Variables         │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Copy Tools &      │ → ~/.config/cauldron/
│ Functions         │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Initialize        │ → cauldron.db schema
│ Database          │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Install Essential │ → fzf, bat, cowsay, etc.
│ Tools             │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Source Fish       │ → Functions available
│ Configuration     │
└───────────────────┘
```

### AI Query Flow

```
User: ask "question"
        │
        ▼
┌───────────────────┐
│ Parse Arguments   │ → Check for flags
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Format Request    │ → Build prompt
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Call Ollama API   │ → ollama run llama3.2
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Process Response  │ → Parse JSON output
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Render Output     │ → Optional markdown (glow)
└───────────────────┘
```

### Package Installation Flow

```
User: installs package-name
        │
        ▼
┌───────────────────┐
│ Parse Options     │ → --apt, --brew, --snap
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Check Available   │ → Query package managers
│ Package Managers  │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Select Preferred  │ → Based on user preference
│ Manager           │
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Execute Install   │ → apt-get / brew / snap
└─────────┬─────────┘
          │
          ▼
┌───────────────────┐
│ Update Database   │ → Record installation
└───────────────────┘
```

---

## Module Organization

### Directory Responsibilities

| Directory | Purpose | User-Facing |
|-----------|---------|-------------|
| `functions/` | Core utilities | Yes |
| `familiar/` | AI companion | Yes |
| `UI/` | Visual components | Yes |
| `text/` | Text formatting | Yes |
| `effects/` | Visual effects | Yes |
| `alias/` | Shell shortcuts | Yes |
| `cli/` | Main CLI | Yes |
| `setup/` | Installation | Limited |
| `update/` | Update system | Limited |
| `internal/` | Helper functions | No |
| `tools/` | System tools | No |
| `packages/` | Package integrations | Limited |
| `config/` | Configuration | Limited |
| `node/` | TypeScript backend | No |
| `data/` | Static data | No |

### Function Naming Conventions

- **Public functions**: `my_function` (lowercase with underscores)
- **Private/internal**: `__private_function` (double underscore prefix)
- **Update steps**: `__cauldron_*_update_step`
- **Initialization**: `__init_*`

---

## Extension Points

### Adding New Functions

1. Create file in appropriate directory
2. Follow function template (see CONTRIBUTING.md)
3. Add documentation in `docs/functions/`
4. Register in install.fish if needed

### Adding New Familiar Emotions

1. Edit `familiar/familiar.fish`
2. Add emotion to switch statement
3. Map to cowsay `-e` or `-T` flags

### Adding New UI Components

1. Create file in `UI/`
2. Follow existing component patterns
3. Use `set_color` for theming
4. Support palette integration

### Adding Package Manager Support

1. Edit `functions/installs.fish`
2. Add detection logic
3. Add installation command
4. Update `dependencies.json`

### Adding Database Tables

1. Create schema in `data/schema.sql`
2. Use `DatabaseManager.createTable()`
3. Add migration in `data/update.sql`

---

## Technology Stack

### Primary Technologies

- **Fish Shell** (v3.0+) - Main scripting language
- **TypeScript** (v5.5.4) - Backend logic
- **Node.js** (v22.9.0) - Runtime environment
- **SQLite** (v5.1.1) - Data storage

### Development Tools

- **Yarn** (v4.3.1) - Package management
- **ESLint** (v9.8.0) - Code linting
- **git-cliff** - Changelog generation
- **tsx** - TypeScript execution

### External Dependencies

- **Ollama** - Local LLM provider
- **fzf** - Fuzzy finder
- **bat** - Syntax highlighting
- **cowsay** - ASCII art output
- **glow** - Markdown rendering

### Configuration Files

| File | Purpose |
|------|---------|
| `package.json` | NPM configuration |
| `tsconfig.json` | TypeScript settings |
| `eslint.config.js` | Linting rules |
| `.editorconfig` | Editor formatting |
| `cliff.toml` | Changelog config |
| `.tool-versions` | ASDF version pinning |

---

## Security Considerations

### Input Validation

- All user inputs are validated
- File paths are sanitized
- SQL queries use parameterized statements

### Privilege Escalation

- Sudo is only invoked when necessary
- User is prompted before sudo operations
- Package installations require explicit consent

### Data Protection

- Local-only database (no cloud sync)
- No telemetry or data collection
- Credentials never stored in database

---

## Performance Considerations

### Fish Shell Performance

- Functions are lazy-loaded
- Minimal startup overhead
- Efficient argument parsing with `argparse`

### Database Performance

- SQLite is local and fast
- Queries are optimized
- Connection pooling in TypeScript

### External Tool Calls

- Tools are only invoked when needed
- Results are cached where appropriate
- Parallel execution where possible

---

## Future Architecture Considerations

### Planned Improvements

1. **Plugin System** - Allow third-party extensions
2. **Remote Familiar** - Cloud-based AI options
3. **Cross-Shell Support** - Zsh/Bash compatibility
4. **Web Dashboard** - Visual configuration UI

### Scalability

- Modular design supports growth
- Database schema allows migration
- Configuration is externalized

---

## Conclusion

Cauldron's architecture balances simplicity with power, providing a magical terminal experience while maintaining clean separation of concerns. The layered approach allows for independent evolution of components while the consistent design philosophy ensures a cohesive user experience.

For implementation details, see the source code and function-specific documentation in `docs/functions/`.
