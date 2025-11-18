# Installation & Update Guide

## New Installation

### Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/MagikIO/cauldron/main/install.sh | bash
```

This will:
- Clone Cauldron to `~/.cauldron`
- Create config directory at `~/.config/cauldron`
- Initialize database with all schemas
- Run migrations automatically
- Install Fish functions
- Setup Fish shell integration
- Install Node.js dependencies

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/MagikIO/cauldron.git ~/.cauldron
cd ~/.cauldron

# Run installation script
./install.sh
```

### Environment Variables

The installer sets these automatically:

```fish
CAULDRON_PATH             # Installation directory (~/.cauldron)
CAULDRON_DATABASE         # Database path (~/.config/cauldron/data/cauldron.db)
CAULDRON_PALETTES         # Color palettes JSON
CAULDRON_SPINNERS         # Spinner animations JSON
CAULDRON_INTERNAL_TOOLS   # Internal tools directory
```

### Post-Installation

1. **Restart your terminal** or run:
   ```fish
   exec fish
   ```

2. **Install dependencies** (optional but recommended):
   ```fish
   installs -f $CAULDRON_PATH/data/dependencies.json
   ```

3. **Test the installation**:
   ```fish
   ask "Hello! Tell me about yourself"
   personality list
   ```

## Updating Cauldron

### Check for Updates

```fish
cauldron_update --check-only
```

Shows available updates without applying them.

### Apply Updates

```fish
cauldron_update
```

This will:
1. Create automatic database backup
2. Stash local changes (if any)
3. Pull latest code from GitHub
4. Run database migrations
5. Update data files (palettes, spinners)
6. Update Fish functions
7. Update Node.js dependencies

### Update to Specific Branch

```fish
cauldron_update --branch dev
```

Useful for testing beta features or development versions.

### What Gets Updated

- ✅ Core Cauldron code
- ✅ Database schema (via migrations)
- ✅ Fish functions
- ✅ Data files (JSON configs)
- ✅ Node.js dependencies
- ✅ TypeScript backend
- ❌ Your custom personalities (preserved)
- ❌ User preferences (preserved)
- ❌ Conversation history (preserved)
- ❌ Project contexts (preserved)

## Repair Mode

If something goes wrong, use repair mode to fix issues.

### Verify Installation

```fish
cauldron_repair --verify-only
```

Checks for:
- Installation directory exists
- Database exists and is valid
- Required database tables present
- Fish functions installed
- Data files present
- Fish configuration correct

### Auto-Repair

```fish
cauldron_repair --fix-all
```

Automatically fixes all detected issues:
- Recreates missing database
- Reinstalls missing functions
- Restores missing data files
- Fixes Fish configuration

### Interactive Repair

```fish
cauldron_repair
```

Shows issues and asks before fixing each one.

## Database Migrations

Migrations are run automatically during updates, but you can manage them manually.

### Run Pending Migrations

```fish
__run_migrations
```

### Check Migration Status

```fish
__run_migrations --dry-run
```

Shows pending migrations without applying.

### Rollback Migrations

```fish
__run_migrations --rollback 1
```

Rolls back the last migration (restores from backup).

### Backup Database

```fish
__run_migrations --backup-only
```

Creates a timestamped backup without running migrations.

Backups are stored in: `~/.config/cauldron/data/backups/`

## Troubleshooting

### Installation Failed

**Error: Prerequisites missing**

Install required tools:
```bash
# Linux (Debian/Ubuntu)
sudo apt-get install git fish sqlite3

# macOS
brew install git fish sqlite3
```

**Error: Git clone failed**

- Check internet connection
- Verify GitHub access
- Try manual clone

**Error: Database creation failed**

- Check permissions on `~/.config/cauldron`
- Verify SQLite is installed: `sqlite3 --version`

### Update Failed

**Error: Git pull failed**

Your local changes conflict with updates:
```fish
cd $CAULDRON_PATH
git stash
git pull origin main
cauldron_update
```

**Error: Migration failed**

Database migration error:
```fish
# Restore from backup
cd ~/.config/cauldron/data/backups
ls -lt  # Find latest backup
cp cauldron_backup_YYYYMMDD_HHMMSS.db ../cauldron.db

# Try repair
cauldron_repair --fix-all
```

**Error: Functions not loading**

Functions aren't in Fish path:
```fish
# Check function path
echo $fish_function_path

# Manually source functions
set -gx fish_function_path "$HOME/.config/cauldron/functions" $fish_function_path

# Repair installation
cauldron_repair
```

### Repair Failed

**Database corrupted beyond repair**

Nuclear option - recreate database (loses conversation history):
```fish
# Backup old database
mv $CAULDRON_DATABASE $CAULDRON_DATABASE.broken

# Recreate from scratch
sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/schema.sql
sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/memory_schema.sql
sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/proactive_schema.sql
__run_migrations
```

**Complete reinstall needed**

Last resort:
```bash
# Backup your custom data
cp ~/.config/cauldron/data/cauldron.db ~/cauldron_backup.db

# Remove everything
rm -rf ~/.cauldron
rm -rf ~/.config/cauldron

# Reinstall
curl -fsSL https://raw.githubusercontent.com/MagikIO/cauldron/main/install.sh | bash

# Optionally restore old database (if compatible)
cp ~/cauldron_backup.db ~/.config/cauldron/data/cauldron.db
```

## Version Management

### Check Current Version

```fish
# Ask function version
ask --version

# Personality system version
personality --version

# Git commit hash
cd $CAULDRON_PATH && git rev-parse --short HEAD
```

### View Changelog

```fish
cd $CAULDRON_PATH
cat CHANGELOG.md
```

Or view online: https://github.com/MagikIO/cauldron/blob/main/CHANGELOG.md

## Uninstallation

If you want to remove Cauldron:

```bash
# Remove installation
rm -rf ~/.cauldron

# Remove config and data
rm -rf ~/.config/cauldron

# Remove Fish config (manual step)
# Edit ~/.config/fish/config.fish and remove the Cauldron section
```

## Advanced

### Custom Installation Location

```bash
export CAULDRON_INSTALL_DIR="/opt/cauldron"
curl -fsSL https://raw.githubusercontent.com/MagikIO/cauldron/main/install.sh | bash
```

### Development Installation

For contributing or testing:

```bash
# Fork and clone your fork
git clone https://github.com/YOUR_USERNAME/cauldron.git ~/.cauldron
cd ~/.cauldron

# Install in development mode
./install.sh

# Create a feature branch
git checkout -b feature/my-feature

# Make changes, test, commit
git add .
git commit -m "feat: Add my feature"
git push origin feature/my-feature
```

### Migration Development

Creating a new migration:

```fish
# Create migration file
cd $CAULDRON_PATH/data/migrations

# Name format: NNN_description.sql
# Where NNN is next sequential number
touch 002_add_new_feature.sql

# Write SQL
echo "-- Migration 002: Add New Feature
CREATE TABLE IF NOT EXISTS new_table (
    id INTEGER PRIMARY KEY,
    data TEXT
);
" > 002_add_new_feature.sql

# Test migration
__run_migrations --dry-run
__run_migrations
```

## Support

- **Documentation**: https://github.com/MagikIO/cauldron
- **Issues**: https://github.com/MagikIO/cauldron/issues
- **Discussions**: https://github.com/MagikIO/cauldron/discussions

## Quick Reference

```fish
# Installation
curl -fsSL https://raw.githubusercontent.com/MagikIO/cauldron/main/install.sh | bash

# Update
cauldron_update

# Repair
cauldron_repair

# Migrations
__run_migrations
__run_migrations --dry-run
__run_migrations --rollback 1

# Verify
cauldron_repair --verify-only
```
