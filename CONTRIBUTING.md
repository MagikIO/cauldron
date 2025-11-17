# Contributing to Cauldron

Thank you for your interest in contributing to Cauldron! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Submitting Changes](#submitting-changes)
- [Writing Fish Shell Functions](#writing-fish-shell-functions)
- [Writing TypeScript Code](#writing-typescript-code)
- [Documentation](#documentation)
- [Testing](#testing)
- [Release Process](#release-process)

---

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment. Please:

- Be respectful and constructive in discussions
- Welcome newcomers and help them get started
- Focus on what is best for the community
- Show empathy towards other community members

---

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/cauldron.git
   cd cauldron
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/MagikIO/cauldron.git
   ```
4. **Install dependencies**:
   ```bash
   yarn install
   ```

---

## Development Setup

### Prerequisites

- **Fish Shell** v3.0+
- **Node.js** v22+
- **Yarn** v4.3.1+
- **Git**
- **SQLite3**

### Environment Setup

```bash
# Install Fish Shell (if not already installed)
# Ubuntu/Debian
sudo apt-get install fish

# macOS
brew install fish

# Install Node.js (using nvm or asdf)
asdf install nodejs 22.9.0
asdf global nodejs 22.9.0

# Install Yarn
corepack enable
corepack prepare yarn@4.3.1 --activate

# Install project dependencies
yarn install
```

### Running the Project

```bash
# Run TypeScript components in debug mode
yarn run

# Generate changelog
yarn changelog

# Lint TypeScript code
npx eslint .
```

---

## Project Structure

Understanding the project structure is essential for contributing:

```
cauldron/
├── node/                    # TypeScript/Node.js code
│   ├── index.ts            # Entry point
│   ├── Cauldron.ts         # Main orchestrator
│   ├── DB.ts               # Database manager
│   └── CustomUpdateMech.ts # Update system
│
├── functions/              # Core Fish functions (main utilities)
├── familiar/               # AI companion system
├── UI/                     # Terminal UI components
├── text/                   # Text formatting
├── effects/                # Visual effects
├── alias/                  # Shell aliases
├── cli/                    # CLI commands
├── setup/                  # Installation scripts
├── update/                 # Update system
├── internal/               # Internal utilities
├── tools/                  # System tools
├── packages/               # Package manager integrations
├── config/                 # Configuration utilities
├── data/                   # Data files (JSON, SQL, .cow)
└── docs/                   # Documentation
```

### Key Directories

- **functions/**: Core utilities that users interact with directly
- **familiar/**: AI companion interface and speech functions
- **UI/**: Visual components like spinners, badges, boxes
- **internal/**: Helper functions not meant for direct user interaction

---

## Coding Standards

### Fish Shell

1. **File naming**: Use lowercase with underscores (e.g., `my_function.fish`)
2. **Function structure**:
   ```fish
   function my_function --description "Brief description"
       # Parse arguments
       argparse h/help -- $argv
       or return

       if set -ql _flag_help
           echo "Usage: my_function [options]"
           return 0
       end

       # Function logic here
   end
   ```

3. **Best practices**:
   - Always include `--description` for functions
   - Support `-h/--help` flags
   - Use `argparse` for argument parsing
   - Quote variables: `"$variable"` not `$variable`
   - Use `set -l` for local variables
   - Add meaningful comments

### TypeScript

1. **File naming**: Use PascalCase for classes (e.g., `Cauldron.ts`)
2. **Code style**:
   - Use TypeScript strict mode
   - Target ES2022
   - Use `async/await` over callbacks
   - Prefer `const` over `let`
   - Add type annotations

3. **Example**:
   ```typescript
   export class MyClass {
       private readonly property: string;

       constructor(value: string) {
           this.property = value;
       }

       async doSomething(): Promise<void> {
           // Implementation
       }
   }
   ```

### General Guidelines

- **Indentation**: 2 spaces for Fish, 4 spaces for TypeScript
- **Line length**: Keep lines under 120 characters
- **Comments**: Write clear, concise comments
- **Error handling**: Always handle errors gracefully
- **Security**: Avoid command injection vulnerabilities

---

## Submitting Changes

### Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the coding standards

3. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: Add new feature description"
   ```

   Use [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `docs:` - Documentation only
   - `style:` - Formatting changes
   - `refactor:` - Code refactoring
   - `test:` - Adding tests
   - `chore:` - Maintenance tasks

4. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request** on GitHub

### Pull Request Guidelines

- **Title**: Clear and descriptive (e.g., "Add package version checking")
- **Description**: Explain what changes you made and why
- **Tests**: Include tests if applicable
- **Documentation**: Update docs if needed
- **Breaking changes**: Clearly mark any breaking changes

### PR Template

```markdown
## Description
Brief description of the changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Other (describe):

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-reviewed the code
- [ ] Added/updated documentation
- [ ] No new warnings
- [ ] Tested the changes
```

---

## Writing Fish Shell Functions

### Template

```fish
#!/usr/bin/env fish

function function_name --description "What this function does"
    # Version information
    set -l version "1.0.0"

    # Argument parsing
    argparse h/help v/version d/dry-run -- $argv
    or return 1

    # Help flag
    if set -ql _flag_help
        echo "function_name - Brief description"
        echo ""
        echo "USAGE:"
        echo "    function_name [OPTIONS] <arguments>"
        echo ""
        echo "OPTIONS:"
        echo "    -h, --help      Show this help message"
        echo "    -v, --version   Show version information"
        echo "    -d, --dry-run   Preview without executing"
        echo ""
        echo "EXAMPLES:"
        echo "    function_name file.txt"
        echo "    function_name -d config.json"
        return 0
    end

    # Version flag
    if set -ql _flag_version
        echo "function_name version $version"
        return 0
    end

    # Validate arguments
    if test (count $argv) -eq 0
        echo "Error: No arguments provided"
        echo "Run 'function_name --help' for usage"
        return 1
    end

    # Main logic
    for arg in $argv
        if set -ql _flag_dry_run
            echo "Would process: $arg"
        else
            # Actual processing
            echo "Processing: $arg"
        end
    end

    return 0
end
```

### Documentation

Create a markdown file in `docs/functions/`:

```markdown
# function_name

Brief description of what the function does.

## Synopsis

```bash
function_name [OPTIONS] <arguments>
```

## Description

Detailed description of the function's purpose and behavior.

## Options

- `-h, --help` - Display help message
- `-v, --version` - Show version
- `-d, --dry-run` - Preview without changes

## Examples

```bash
# Basic usage
function_name file.txt

# With options
function_name -d config.json
```

## See Also

- Related functions
- External documentation

## Version

1.0.0
```

---

## Writing TypeScript Code

### Class Template

```typescript
import { DatabaseManager } from './DB.js';

interface MyClassOptions {
    option1: string;
    option2?: number;
}

export class MyClass {
    private db: DatabaseManager;
    private options: MyClassOptions;

    constructor(options: MyClassOptions) {
        this.options = options;
    }

    async init(): Promise<void> {
        this.db = await DatabaseManager.init();
        // Initialization logic
    }

    async doWork(): Promise<string> {
        // Implementation
        return 'result';
    }

    toString(): string {
        return JSON.stringify(this.options, null, 2);
    }
}
```

### Database Operations

```typescript
import sql from 'sql-template-tag';

// Query with sql template tag
const query = sql`
    SELECT * FROM table_name
    WHERE column = ${value}
`;

await db.run(query);
```

---

## Documentation

### When to Document

- **New functions**: Always create documentation
- **API changes**: Update existing docs
- **Breaking changes**: Highlight prominently
- **Complex logic**: Add inline comments

### Documentation Structure

```
docs/
├── functions/          # Function-specific docs
│   └── function_name.md
├── setup/              # Installation and setup
├── text/               # Text utilities
└── tools.md            # General tools docs
```

### Style Guide

- Use clear, concise language
- Include code examples
- Document all options/parameters
- Add "See Also" sections for related content
- Keep examples practical and relevant

---

## Testing

### Manual Testing

Since Cauldron is primarily Fish shell scripts, test manually:

```bash
# Test a function
source functions/my_function.fish
my_function --help
my_function test-argument

# Test with different scenarios
my_function -d file.txt  # Dry run
my_function --version
```

### TypeScript Testing

```bash
# Run TypeScript
yarn run

# Check for type errors
npx tsc --noEmit

# Lint code
npx eslint .
```

### Test Checklist

- [ ] Function runs without errors
- [ ] Help text is accurate and helpful
- [ ] Edge cases are handled
- [ ] Error messages are clear
- [ ] No security vulnerabilities
- [ ] Works on supported platforms

---

## Release Process

Cauldron uses semantic versioning (SemVer):

- **MAJOR**: Breaking changes
- **MINOR**: New features (backward compatible)
- **PATCH**: Bug fixes

### Creating a Release

1. Update version in `package.json`
2. Generate changelog:
   ```bash
   yarn changelog
   ```
3. Commit changes:
   ```bash
   git add .
   git commit -m "chore: Bump version to X.Y.Z"
   ```
4. Tag the release:
   ```bash
   git tag vX.Y.Z
   ```
5. Push:
   ```bash
   git push origin main --tags
   ```

The CI pipeline (Ouroboros CI) handles the release automation.

---

## Questions?

If you have questions:

1. Check existing documentation
2. Look at similar functions for patterns
3. Open an issue on GitHub
4. Contact the maintainers

---

## Recognition

Contributors are valued members of the Cauldron community. Your contributions help make terminal work more magical for everyone!

---

Thank you for contributing to Cauldron! 🪄🐟
