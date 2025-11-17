# Installation Guide

This guide provides comprehensive instructions for installing Cauldron on your system.

## Table of Contents

- [Quick Install](#quick-install)
- [Prerequisites](#prerequisites)
- [Step-by-Step Installation](#step-by-step-installation)
- [Post-Installation Setup](#post-installation-setup)
- [Platform-Specific Instructions](#platform-specific-instructions)
- [Troubleshooting](#troubleshooting)
- [Uninstallation](#uninstallation)
- [Upgrading](#upgrading)

---

## Quick Install

For experienced users, here's the quick installation method:

```bash
git clone https://github.com/MagikIO/cauldron.git ~/.cauldron
cd ~/.cauldron && ./install.fish
```

For detailed instructions, continue reading below.

---

## Prerequisites

### Required Software

1. **Fish Shell** (v3.0 or higher)
   ```bash
   # Check version
   fish --version
   ```

2. **Git**
   ```bash
   # Check version
   git --version
   ```

3. **curl**
   ```bash
   # Check version
   curl --version
   ```

4. **sudo access** (for package installation)

### Recommended Software

These will be installed automatically if missing, but can be pre-installed:

- **Node.js** v22+ (for TypeScript components)
- **SQLite3** (for database features)
- **fzf** (for fuzzy finding)
- **bat** (for syntax highlighting)
- **cowsay** (for familiar output)

### System Requirements

- **Operating System**: Linux (Ubuntu/Debian) or macOS
- **Memory**: 512MB RAM minimum
- **Disk Space**: 100MB for full installation
- **Network**: Internet connection for package downloads

---

## Step-by-Step Installation

### Step 1: Install Fish Shell

If Fish Shell is not installed:

**Ubuntu/Debian:**
```bash
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update
sudo apt install fish
```

**macOS:**
```bash
brew install fish
```

**Fedora:**
```bash
sudo dnf install fish
```

**Arch Linux:**
```bash
sudo pacman -S fish
```

### Step 2: Clone the Repository

```bash
# Create the cauldron directory
mkdir -p ~/.cauldron

# Clone the repository
git clone https://github.com/MagikIO/cauldron.git ~/.cauldron

# Navigate to the directory
cd ~/.cauldron
```

### Step 3: Run the Installer

```bash
# Make sure you're in Fish shell
fish

# Run the installer
./install.fish
```

The installer will:

1. **Set up environment variables**
   - `CAULDRON_PATH` → `~/.config/cauldron`
   - `CAULDRON_DATABASE` → Database file location
   - `CAULDRON_PALETTES` → Color palette file
   - `CAULDRON_SPINNERS` → Spinner definitions

2. **Create directory structure**
   ```
   ~/.config/cauldron/
   ├── data/
   ├── docs/
   ├── functions/
   ├── logs/
   ├── node/
   ├── packages/
   └── tools/
   ```

3. **Copy functions to Fish configuration**
   - All functions are copied to `~/.config/fish/functions/`

4. **Initialize the SQLite database**
   - Creates `cauldron.db` with schema

5. **Install essential tools**
   - fzf, bat, cowsay, etc.

6. **Reload Fish configuration**

### Step 4: Verify Installation

```bash
# Check if Cauldron is available
cauldron --version

# Test a basic function
familiar "Hello, I'm your new familiar!"

# Check environment variables
echo $CAULDRON_PATH
```

---

## Post-Installation Setup

### 1. Choose Your Package Manager Preference

```bash
choose_packman
```

This interactive command lets you set your preferred package manager (APT, Homebrew, or Snap).

### 2. Install AI Features (Optional)

For the `ask` and advanced `familiar` features, install Ollama:

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull the llama3.2 model
ollama pull llama3.2
```

### 3. Customize Your Familiar

Edit the familiar settings:

```bash
# List available familiars (cow files)
__list_familiars

# Test different familiars
familiar "Test message" --trogdor
familiar "Test message" --yoda
```

### 4. Set Up Git Integration

```bash
# Update git aliases for better integration
update_git_alias
```

### 5. Configure Color Palette (Optional)

Cauldron includes three color palettes:
- `berry` - Purple/pink tones
- `malory` - Green/blue tones
- `neodutch` - Warm earth tones

Edit `~/.config/cauldron/data/palettes.json` to customize.

---

## Platform-Specific Instructions

### Ubuntu/Debian Linux

```bash
# Install prerequisites
sudo apt update
sudo apt install fish git curl

# Clone and install
git clone https://github.com/MagikIO/cauldron.git ~/.cauldron
cd ~/.cauldron
./install.fish
```

**Additional APT packages installed:**
- bat, cbonsai, cowsay, fortune
- jp2a, linuxlogo, pv, hyfetch
- build-essential, procps, rig
- toilet, sqlite3

### macOS

```bash
# Install prerequisites using Homebrew
brew install fish git curl

# Set Fish as default shell (optional)
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish

# Clone and install
git clone https://github.com/MagikIO/cauldron.git ~/.cauldron
cd ~/.cauldron
./install.fish
```

**Additional Homebrew packages installed:**
- glow, fzf, timg
- watchman, lsd, fx, navi

### Fedora/RHEL

```bash
# Install Fish
sudo dnf install fish git curl

# Clone and install
git clone https://github.com/MagikIO/cauldron.git ~/.cauldron
cd ~/.cauldron
./install.fish
```

Note: Some APT-specific packages may not be available on Fedora. The installer will skip unavailable packages.

### Arch Linux

```bash
# Install prerequisites
sudo pacman -S fish git curl

# Clone and install
git clone https://github.com/MagikIO/cauldron.git ~/.cauldron
cd ~/.cauldron
./install.fish
```

---

## Troubleshooting

### Common Issues

#### 1. "Command not found: fish"

**Solution:** Install Fish Shell first:
```bash
# Ubuntu/Debian
sudo apt install fish

# macOS
brew install fish
```

#### 2. "Permission denied" during installation

**Solution:** Ensure you have sudo access:
```bash
sudo -v
./install.fish
```

#### 3. Functions not available after installation

**Solution:** Reload Fish configuration:
```bash
source ~/.config/fish/config.fish
# Or restart your terminal
```

#### 4. Database errors

**Solution:** Re-initialize the database:
```bash
rm $CAULDRON_DATABASE
$CAULDRON_INTERNAL_TOOLS/__init_cauldron_DB.fish
```

#### 5. Missing environment variables

**Solution:** Run variable initialization:
```bash
$CAULDRON_INTERNAL_TOOLS/__init_cauldron_vars.fish
```

#### 6. Cowsay characters not working

**Solution:** Ensure cowsay is installed and cow files are in place:
```bash
installs cowsay
ls $CAULDRON_PATH/data/*.cow
```

#### 7. Ollama/AI features not working

**Solution:** Install and verify Ollama:
```bash
# Check if Ollama is running
ollama list

# Pull required model
ollama pull llama3.2
```

### Diagnostic Commands

```bash
# Check Cauldron installation
cauldron --version

# Verify environment
env | grep CAULDRON

# List installed functions
functions | grep -E "^(ask|familiar|installs|hamsa)"

# Check database
sqlite3 $CAULDRON_DATABASE ".tables"

# Test familiar
familiar "Diagnostic test"
```

### Getting Help

If you encounter issues:

1. Check the [GitHub Issues](https://github.com/MagikIO/cauldron/issues)
2. Review the error logs: `~/.config/cauldron/logs/cauldron.log`
3. Run with verbose output where available
4. Ensure all prerequisites are installed

---

## Uninstallation

### Complete Uninstallation

```bash
# Remove Cauldron configuration
rm -rf ~/.config/cauldron

# Remove cloned repository
rm -rf ~/.cauldron

# Remove installed functions
cd ~/.config/fish/functions
rm -f (ls ~/.cauldron/functions/ | sed 's/.fish$//')

# Unset environment variables
set -e CAULDRON_PATH
set -e CAULDRON_DATABASE
set -e CAULDRON_PALETTES
set -e CAULDRON_SPINNERS
set -e CAULDRON_INTERNAL_TOOLS
```

### Partial Uninstallation

To keep configuration but remove functions:

```bash
# Only remove functions
cd ~/.config/fish/functions
rm -f (ls ~/.cauldron/functions/ | sed 's/.fish$//')

# Keep ~/.config/cauldron for data preservation
```

---

## Upgrading

### Standard Upgrade

```bash
cauldron --update
```

This runs the full update process including:
- Git repository pull
- System package updates
- Function reinstallation
- Database migrations

### Manual Upgrade

```bash
cd ~/.cauldron
git pull origin main
./install.fish
```

### Re-Installation with Configuration Preservation

If you need to re-install while keeping your settings:

```bash
./internal/__backup_cauldron_and_update.fish
```

This will:
1. Backup your current configuration
2. Pull latest changes
3. Re-install while preserving data

### Version Checking

```bash
# Check current version
cauldron --version

# Check for updates
cd ~/.cauldron
git fetch
git log HEAD..origin/main --oneline
```

---

## Advanced Installation

### Custom Installation Directory

To install to a custom location:

```bash
# Set custom path before installation
set -Ux CAULDRON_PATH /custom/path/to/cauldron

# Clone and install
git clone https://github.com/MagikIO/cauldron.git /your/clone/path
cd /your/clone/path
./install.fish
```

### Minimal Installation

For a minimal installation without optional dependencies:

1. Clone the repository
2. Edit `dependencies.json` to remove unwanted packages
3. Run installation:
   ```bash
   ./install.fish
   ```

### Development Installation

For development purposes:

```bash
# Clone to development location
git clone https://github.com/MagikIO/cauldron.git ~/dev/cauldron
cd ~/dev/cauldron

# Install Node dependencies
yarn install

# Run in development mode
yarn run
```

---

## Security Notes

- The installer requires `sudo` for package installation
- No data is sent externally during installation
- All files are installed locally
- Database is local-only (no cloud sync)
- AI features use local Ollama instance

---

## Next Steps

After installation:

1. **Explore the documentation**: `docs/functions/`
2. **Try basic commands**: `familiar -h`, `ask -h`, `installs -h`
3. **Customize your setup**: Edit palettes, choose your familiar
4. **Read the architecture**: `ARCHITECTURE.md`
5. **Consider contributing**: `CONTRIBUTING.md`

---

## Support

- **Documentation**: `/docs` directory
- **Issues**: [GitHub Issues](https://github.com/MagikIO/cauldron/issues)
- **Changelog**: `CHANGELOG.md`

---

Happy brewing with Cauldron! 🪄🐟
