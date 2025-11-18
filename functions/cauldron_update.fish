function cauldron_update --description "Update Cauldron to the latest version"
    set -l func_version "1.0.0"
    set -l options h/help c/check-only b/branch=

    argparse -n cauldron_update $options -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: cauldron_update [OPTIONS]"
        echo ""
        echo "Update Cauldron to the latest version"
        echo ""
        echo "Options:"
        echo "  -h, --help         Show this help"
        echo "  -c, --check-only   Check for updates without applying"
        echo "  -b, --branch NAME  Update to specific branch (default: main)"
        echo ""
        echo "Examples:"
        echo "  cauldron_update                 # Update to latest version"
        echo "  cauldron_update --check-only    # Check for updates"
        echo "  cauldron_update --branch dev    # Update to dev branch"
        return 0
    end

    set -l branch (set -q _flag_branch && echo $_flag_branch || echo "main")

    echo "🔮 Cauldron Update System"
    echo ""

    # Verify we're in a git repository
    if not test -d "$CAULDRON_PATH/.git"
        echo "Error: Cauldron installation is not a git repository"
        echo "Please reinstall using the install script"
        return 1
    end

    cd "$CAULDRON_PATH"

    # Fetch latest changes
    echo "→ Checking for updates..."
    git fetch origin $branch 2>/dev/null

    # Check if updates are available
    set -l local_hash (git rev-parse HEAD)
    set -l remote_hash (git rev-parse origin/$branch 2>/dev/null)

    if test "$local_hash" = "$remote_hash"
        echo "✓ Cauldron is already up to date!"
        return 0
    end

    # Show what will change
    echo ""
    echo "Updates available:"
    echo ""
    git log --oneline --decorate --graph HEAD..origin/$branch | head -n 10

    if set -q _flag_check_only
        echo ""
        echo "Run 'cauldron_update' to apply these updates"
        return 0
    end

    echo ""
    read -l -P "Apply updates? [y/N] " confirm

    if test "$confirm" != "y" -a "$confirm" != "Y"
        echo "Update cancelled"
        return 0
    end

    # Create backup before updating
    echo ""
    echo "→ Creating backup..."

    if not __run_migrations --backup-only
        echo "Error: Failed to create backup"
        return 1
    end

    # Stash local changes
    echo "→ Stashing local changes..."
    git stash push -m "Cauldron auto-update stash (date +%Y%m%d_%H%M%S)" 2>/dev/null

    # Pull updates
    echo "→ Pulling latest changes..."
    if not git pull origin $branch --rebase
        echo "Error: Failed to pull updates"
        echo "Your local changes have been stashed"
        echo "Run 'git stash pop' to restore them"
        return 1
    end

    echo "✓ Code updated successfully"

    # Run migrations
    echo ""
    echo "→ Running database migrations..."
    if not __run_migrations
        echo "Warning: Migrations failed"
        echo "Your database has been backed up"
        echo "You may need to run 'cauldron_repair' to fix issues"
    else
        echo "✓ Migrations completed"
    end

    # Copy updated data files
    echo "→ Updating data files..."
    cp -f "$CAULDRON_PATH/data/palettes.json" "$CAULDRON_DATABASE/../palettes.json" 2>/dev/null
    cp -f "$CAULDRON_PATH/data/spinners.json" "$CAULDRON_DATABASE/../spinners.json" 2>/dev/null

    # Copy updated functions
    echo "→ Updating functions..."
    set -l updated_count 0
    for func_file in $CAULDRON_PATH/functions/*.fish
        if test -f "$func_file"
            set -l func_name (basename "$func_file")
            cp -f "$func_file" "$HOME/.config/cauldron/functions/"
            set updated_count (math $updated_count + 1)
        end
    end

    echo "✓ Updated $updated_count functions"

    # Update Node.js dependencies if needed
    if test -f "$CAULDRON_PATH/package.json"
        echo "→ Updating Node.js dependencies..."
        if command -q pnpm
            pnpm install 2>/dev/null
        else if command -q npm
            npm install 2>/dev/null
        end
    end

    # Show what changed
    echo ""
    echo "✨ Cauldron updated successfully!"
    echo ""
    echo "Changes applied:"
    git log --oneline --decorate $local_hash..$remote_hash

    echo ""
    echo "Please restart your Fish shell to use the updated version:"
    echo "  exec fish"

    return 0
end
