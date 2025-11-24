function cauldron_repair --description "Repair broken Cauldron installation"
    set -l func_version "1.0.0"
    set -l options h/help v/verify-only f/fix-all

    argparse -n cauldron_repair $options -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: cauldron_repair [OPTIONS]"
        echo ""
        echo "Detect and fix issues with Cauldron installation"
        echo ""
        echo "Options:"
        echo "  -h, --help         Show this help"
        echo "  -v, --verify-only  Only check for issues, don't fix"
        echo "  -f, --fix-all      Automatically fix all detected issues"
        echo ""
        echo "Examples:"
        echo "  cauldron_repair                # Interactive repair"
        echo "  cauldron_repair --verify-only  # Only check for issues"
        echo "  cauldron_repair --fix-all      # Auto-fix everything"
        return 0
    end

    echo "🔧 Cauldron Repair System"
    echo ""

    set -l issues_found 0
    set -l issues_fixed 0
    set -l issues ()

    # Check 1: Verify CAULDRON_PATH exists
    echo "→ Checking installation directory..."
    if not test -d "$CAULDRON_PATH"
        set issues_found (math $issues_found + 1)
        set -a issues "CAULDRON_PATH directory missing: $CAULDRON_PATH"
        echo "  ✗ Installation directory not found"
    else
        echo "  ✓ Installation directory OK"
    end

    # Check 2: Verify database exists
    echo "→ Checking database..."
    if not test -f "$CAULDRON_DATABASE"
        set issues_found (math $issues_found + 1)
        set -a issues "Database file missing: $CAULDRON_DATABASE"
        echo "  ✗ Database not found"
    else
        # Verify database integrity
        if sqlite3 "$CAULDRON_DATABASE" "PRAGMA integrity_check;" | grep -q "ok"
            echo "  ✓ Database OK"
        else
            set issues_found (math $issues_found + 1)
            set -a issues "Database integrity check failed"
            echo "  ✗ Database corrupted"
        end
    end

    # Check 3: Verify essential tables exist
    if test -f "$CAULDRON_DATABASE"
        echo "→ Checking database schema..."
        set -l required_tables conversation_history project_context user_preferences sessions

        set -l missing_tables ()

        for table in $required_tables
            if not sqlite3 "$CAULDRON_DATABASE" "SELECT name FROM sqlite_master WHERE type='table' AND name='$table';" | grep -q "$table"
                set -a missing_tables $table
            end
        end

        if test (count $missing_tables) -gt 0
            set issues_found (math $issues_found + 1)
            set -a issues "Missing database tables: "(string join ", " $missing_tables)
            echo "  ✗ Missing tables: "(string join ", " $missing_tables)
        else
            echo "  ✓ Database schema OK"
        end
    end

    # Check 4: Verify dependencies table has date column
    if test -f "$CAULDRON_DATABASE"
        echo "→ Checking dependencies table schema..."
        set -l has_date_column (sqlite3 "$CAULDRON_DATABASE" "PRAGMA table_info(dependencies);" 2>/dev/null | grep -c "date")

        if test $has_date_column -eq 0
            set issues_found (math $issues_found + 1)
            set -a issues "Dependencies table missing 'date' column (required for parallel installs)"
            echo "  ✗ Dependencies table schema outdated"
        else
            echo "  ✓ Dependencies table schema OK"
        end
    end

    # Check 5: Verify functions symlink is valid
    echo "→ Checking Fish functions symlink..."
    set -l functions_dir "$HOME/.config/cauldron/functions"

    if not test -L "$functions_dir"
        set issues_found (math $issues_found + 1)
        set -a issues "Functions symlink missing: $functions_dir"
        echo "  ✗ Functions symlink not found"
    else if not test -d "$functions_dir"
        set issues_found (math $issues_found + 1)
        set -a issues "Functions symlink broken: $functions_dir"
        echo "  ✗ Functions symlink is broken"
    else
        set -l func_count (ls "$functions_dir"/*.fish 2>/dev/null | wc -l)

        if test $func_count -lt 10
            set issues_found (math $issues_found + 1)
            set -a issues "Too few functions available (found $func_count, expected 30+)"
            echo "  ✗ Only $func_count functions available (expected 30+)"
        else
            # Check for critical functions (via symlink)
            set -l critical_functions ask.fish f-thinks.fish f-says.fish cauldron_update.fish cauldron_repair.fish
            set -l missing_functions ()

            for func in $critical_functions
                if not test -f "$functions_dir/$func"
                    set -a missing_functions $func
                end
            end

            if test (count $missing_functions) -gt 0
                set issues_found (math $issues_found + 1)
                set -a issues "Missing critical functions: "(string join ", " $missing_functions)
                echo "  ✗ Missing critical functions: "(string join ", " $missing_functions)
            else
                echo "  ✓ Functions OK ($func_count installed)"
            end
        end
    end

    # Check 6: Verify data files
    echo "→ Checking data files..."
    set -l required_files palettes.json spinners.json

    set -l missing_files ()

    for file in $required_files
        set -l file_path (dirname "$CAULDRON_DATABASE")"/$file"
        if not test -f "$file_path"
            set -a missing_files $file
        end
    end

    if test (count $missing_files) -gt 0
        set issues_found (math $issues_found + 1)
        set -a issues "Missing data files: "(string join ", " $missing_files)
        echo "  ✗ Missing files: "(string join ", " $missing_files)
    else
        echo "  ✓ Data files OK"
    end

    # Check 7: Verify Fish config
    echo "→ Checking Fish configuration..."
    set -l fish_config "$HOME/.config/fish/config.fish"

    if not test -f "$fish_config"
        set issues_found (math $issues_found + 1)
        set -a issues "Fish config file missing"
        echo "  ✗ Fish config not found"
    else if not grep -q "CAULDRON_PATH" "$fish_config"
        set issues_found (math $issues_found + 1)
        set -a issues "Cauldron not configured in Fish config"
        echo "  ✗ Cauldron not in Fish config"
    else
        echo "  ✓ Fish configuration OK"
    end

    # Summary
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if test $issues_found -eq 0
        echo "✨ No issues found! Cauldron is healthy."
        return 0
    end

    echo "Found $issues_found issue(s):"
    echo ""

    for issue in $issues
        echo "  • $issue"
    end

    if set -q _flag_verify_only
        echo ""
        echo "Run 'cauldron_repair --fix-all' to fix these issues"
        return 1
    end

    # Ask user if they want to fix
    echo ""

    if not set -q _flag_fix_all
        read -l -P "Attempt to fix these issues? [y/N] " confirm
        if test "$confirm" != "y" -a "$confirm" != "Y"
            echo "Repair cancelled"
            return 1
        end
    end

    echo ""
    echo "→ Attempting repairs..."
    echo ""

    # Fix 1: Recreate database if missing or corrupted
    if string match -q "*Database*" -- $issues
        echo "  → Recreating database..."

        # Backup existing database if it exists
        if test -f "$CAULDRON_DATABASE"
            mv "$CAULDRON_DATABASE" "$CAULDRON_DATABASE.broken.bak"
        end

        # Create new database
        mkdir -p (dirname "$CAULDRON_DATABASE")

        if test -f "$CAULDRON_PATH/data/schema.sql"
            sqlite3 "$CAULDRON_DATABASE" < "$CAULDRON_PATH/data/schema.sql"
            sqlite3 "$CAULDRON_DATABASE" < "$CAULDRON_PATH/data/memory_schema.sql" 2>/dev/null
            sqlite3 "$CAULDRON_DATABASE" < "$CAULDRON_PATH/data/proactive_schema.sql" 2>/dev/null

            # Run migrations
            __run_migrations 2>/dev/null

            echo "    ✓ Database recreated"
            set issues_fixed (math $issues_fixed + 1)
        else
            echo "    ✗ Schema files not found"
        end
    end

    # Fix 2: Update dependencies table schema
    if string match -q "*Dependencies table*" -- $issues
        echo "  → Updating dependencies table schema..."

        # Check if the date column exists before trying to add it
        set -l has_date_column (sqlite3 "$CAULDRON_DATABASE" "PRAGMA table_info(dependencies);" 2>/dev/null | grep -c "date")

        if test $has_date_column -eq 0
            sqlite3 "$CAULDRON_DATABASE" "ALTER TABLE dependencies ADD COLUMN date TEXT;" 2>/dev/null

            if test $status -eq 0
                echo "    ✓ Added date column to dependencies table"
                set issues_fixed (math $issues_fixed + 1)
            else
                echo "    ✗ Failed to add date column"
            end
        else
            echo "    ✓ Date column already exists"
            set issues_fixed (math $issues_fixed + 1)
        end
    end

    # Fix 3: Recreate function symlinks
    if string match -q "*function*" -- $issues
        echo "  → Recreating function symlinks..."

        # List of directories to symlink
        set -l dirs functions familiar UI text effects alias cli internal tools packages config setup update integrations docs
        set -l linked_count 0

        for dir in $dirs
            set -l source_dir "$CAULDRON_PATH/$dir"
            set -l target_link "$HOME/.config/cauldron/$dir"

            # Only create symlink if source directory exists
            if test -d "$source_dir"
                # Remove existing symlink or directory if it exists
                if test -L "$target_link"; or test -d "$target_link"
                    rm -rf "$target_link"
                end

                # Create symlink
                ln -sf "$source_dir" "$target_link"
                set linked_count (math $linked_count + 1)
            end
        end

        # Count functions for verification
        set -l func_count (find "$HOME/.config/cauldron/functions" -name '*.fish' 2>/dev/null | wc -l)

        echo "    ✓ Recreated $linked_count symlinks ($func_count functions available)"
        set issues_fixed (math $issues_fixed + 1)
    end

    # Fix 4: Restore data files
    if string match -q "*data file*" -- $issues
        echo "  → Restoring data files..."

        set -l data_dir (dirname "$CAULDRON_DATABASE")

        if test -f "$CAULDRON_PATH/data/palettes.json"
            cp -f "$CAULDRON_PATH/data/palettes.json" "$data_dir/"
        end

        if test -f "$CAULDRON_PATH/data/spinners.json"
            cp -f "$CAULDRON_PATH/data/spinners.json" "$data_dir/"
        end

        echo "    ✓ Data files restored"
        set issues_fixed (math $issues_fixed + 1)
    end

    # Fix 5: Fix Fish config
    if string match -q "*Fish config*" -- $issues
        echo "  → Updating Fish configuration..."

        set -l fish_config "$HOME/.config/fish/config.fish"
        mkdir -p (dirname "$fish_config")
        touch "$fish_config"

        # Add Cauldron configuration
        echo "" >> "$fish_config"
        echo "# Cauldron - Magik for your terminal" >> "$fish_config"
        echo "set -gx CAULDRON_PATH \"$CAULDRON_PATH\"" >> "$fish_config"
        echo "set -gx CAULDRON_DATABASE \"\$HOME/.config/cauldron/data/cauldron.db\"" >> "$fish_config"
        echo "set -gx CAULDRON_PALETTES \"\$HOME/.config/cauldron/data/palettes.json\"" >> "$fish_config"
        echo "set -gx CAULDRON_SPINNERS \"\$HOME/.config/cauldron/data/spinners.json\"" >> "$fish_config"
        echo "" >> "$fish_config"
        echo "if not contains \"\$HOME/.config/cauldron/functions\" \$fish_function_path" >> "$fish_config"
        echo "    set -gx fish_function_path \"\$HOME/.config/cauldron/functions\" \$fish_function_path" >> "$fish_config"
        echo "end" >> "$fish_config"

        echo "    ✓ Fish configuration updated"
        set issues_fixed (math $issues_fixed + 1)
    end

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "✨ Repair complete: $issues_fixed of $issues_found issues fixed"
    echo ""
    echo "Please restart your Fish shell:"
    echo "  exec fish"

    return 0
end
