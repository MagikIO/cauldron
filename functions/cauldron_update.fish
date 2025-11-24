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

    # Show all pending installation tasks
    echo ""
    echo "📦 Installation Tasks:"
    echo "  • Updating functions and data files"
    echo "  • Running database migrations"
    echo "  • Initializing personality system"
    if test -f "$CAULDRON_PATH/package.json"
        echo "  • Updating Node.js dependencies"
    end
    echo ""

    # Create temp directory for parallel job status
    set -l temp_dir (mktemp -d)
    set -l functions_dir "$HOME/.config/cauldron/functions"
    # Note: functions_dir is now a symlink, no need to create it

    # Job 1: Core update chain (functions → data → migrations → personality)
    # This must be sequential due to dependencies
    set -l core_status "$temp_dir/core_status"
    set -l core_log "$temp_dir/core_log"

    fish -c "
        # Functions are now symlinked - no copying needed!
        # Count available functions for reporting
        set -l updated_count (find '$CAULDRON_PATH/functions' -name '*.fish' 2>/dev/null | wc -l)

        echo \"functions:\$updated_count (via symlink)\" >> '$core_log'

        # Copy data files
        set -l data_dir (dirname '$CAULDRON_DATABASE')
        cp -f '$CAULDRON_PATH/data/palettes.json' \$data_dir/palettes.json 2>/dev/null
        cp -f '$CAULDRON_PATH/data/spinners.json' \$data_dir/spinners.json 2>/dev/null
        echo 'data:ok' >> '$core_log'

        # Run migrations
        if test -f '$functions_dir/__run_migrations.fish'
            source '$functions_dir/__run_migrations.fish'
        end

        if __run_migrations 2>&1 | tail -n 20 >> '$core_log'
            echo 'migrations:ok' >> '$core_log'

            # Initialize personality system
            if test -f '$functions_dir/__init_personality_system.fish'
                source '$functions_dir/__init_personality_system.fish'
            end
            if test -f '$functions_dir/__ensure_builtin_personalities.fish'
                source '$functions_dir/__ensure_builtin_personalities.fish'
            end
            if functions -q __init_personality_system
                __init_personality_system 2>/dev/null
                echo 'personality:ok' >> '$core_log'
            else
                echo 'personality:skip' >> '$core_log'
            end
        else
            echo 'migrations:failed' >> '$core_log'
        end

        echo 'done' > '$core_status'
    " &
    set -l core_pid $last_pid

    # Job 2: Node.js dependencies (can run in parallel with core updates)
    set -l node_status "$temp_dir/node_status"
    set -l node_log "$temp_dir/node_log"
    set -l has_nodejs 0

    if test -f "$CAULDRON_PATH/package.json"
        set has_nodejs 1
        fish -c "
            if command -q pnpm
                cd '$CAULDRON_PATH' && pnpm install >> '$node_log' 2>&1
                echo 'pnpm:ok' >> '$node_log'
            else if command -q npm
                cd '$CAULDRON_PATH' && npm install >> '$node_log' 2>&1
                echo 'npm:ok' >> '$node_log'
            else
                echo 'none:skip' >> '$node_log'
            end
            echo 'done' > '$node_status'
        " &
        set -l node_pid $last_pid
    end

    # Wait for jobs to complete with status updates
    set -l core_done 0
    set -l node_done 0
    set -l dots 0

    echo "⏳ Installing in parallel..."

    while test $core_done -eq 0 -o \( $has_nodejs -eq 1 -a $node_done -eq 0 \)
        # Check core job
        if test $core_done -eq 0 -a -f "$core_status"
            set core_done 1
            echo "  ✓ Core updates completed"
        end

        # Check node job
        if test $has_nodejs -eq 1 -a $node_done -eq 0 -a -f "$node_status"
            set node_done 1
            echo "  ✓ Node.js dependencies completed"
        end

        # Still waiting, show progress
        if test $core_done -eq 0 -o \( $has_nodejs -eq 1 -a $node_done -eq 0 \)
            sleep 0.5
        end
    end

    echo ""
    echo "📋 Installation Summary:"

    # Parse and display core results
    if test -f "$core_log"
        set -l func_count (grep '^functions:' "$core_log" | cut -d: -f2)
        if test -n "$func_count"
            echo "  ✓ Updated $func_count functions"
        end

        if grep -q '^data:ok' "$core_log"
            echo "  ✓ Data files updated"
        end

        if grep -q '^migrations:ok' "$core_log"
            echo "  ✓ Database migrations completed"
        else if grep -q '^migrations:failed' "$core_log"
            echo "  ⚠ Migrations failed - database backed up"
            echo "    You may need to run 'cauldron_repair' to fix issues"
        end

        if grep -q '^personality:ok' "$core_log"
            echo "  ✓ Personality system initialized"
        end
    end

    # Parse and display node results
    if test $has_nodejs -eq 1 -a -f "$node_log"
        if grep -q 'pnpm:ok' "$node_log"
            echo "  ✓ Node dependencies updated (pnpm)"
        else if grep -q 'npm:ok' "$node_log"
            echo "  ✓ Node dependencies updated (npm)"
        else if grep -q 'none:skip' "$node_log"
            echo "  ⚠ No package manager found (skipped Node.js dependencies)"
        end
    end

    # Cleanup temp files
    rm -rf "$temp_dir" 2>/dev/null

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
