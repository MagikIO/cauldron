function __run_migrations --description "Run database migrations with backup and rollback support"
    set -l func_version "1.0.0"
    set -l options h/help d/dry-run b/backup-only r/rollback=

    argparse -n __run_migrations $options -- $argv
    or return 1

    if set -q _flag_help
        echo "Usage: __run_migrations [OPTIONS]"
        echo ""
        echo "Run database migrations with automatic backup"
        echo ""
        echo "Options:"
        echo "  -h, --help          Show this help"
        echo "  -d, --dry-run       Show pending migrations without applying"
        echo "  -b, --backup-only   Create backup without running migrations"
        echo "  -r, --rollback N    Rollback N migrations"
        echo ""
        echo "Examples:"
        echo "  __run_migrations                    # Run all pending migrations"
        echo "  __run_migrations --dry-run          # See what would be applied"
        echo "  __run_migrations --rollback 1       # Undo last migration"
        return 0
    end

    set -l db_path "$CAULDRON_DATABASE"
    set -l migrations_dir "$CAULDRON_PATH/data/migrations"

    # Verify database exists
    if not test -f "$db_path"
        echo "Error: Database not found at $db_path"
        return 1
    end

    # Verify migrations directory exists
    if not test -d "$migrations_dir"
        echo "Error: Migrations directory not found at $migrations_dir"
        return 1
    end

    # Create backup
    set -l backup_dir "$CAULDRON_PATH/data/backups"
    mkdir -p "$backup_dir"

    set -l timestamp (date +%Y%m%d_%H%M%S)
    set -l backup_file "$backup_dir/cauldron_backup_$timestamp.db"

    echo "Creating database backup..."
    cp "$db_path" "$backup_file"

    if test $status -ne 0
        echo "Error: Failed to create backup"
        return 1
    end

    echo "Backup created: $backup_file"

    if set -q _flag_backup_only
        return 0
    end

    # Ensure schema_migrations table exists
    sqlite3 "$db_path" "CREATE TABLE IF NOT EXISTS schema_migrations (
        version INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        applied_at INTEGER NOT NULL,
        checksum TEXT
    );"

    # Handle rollback
    if set -q _flag_rollback
        set -l rollback_count $_flag_rollback

        echo "Rolling back $rollback_count migration(s)..."

        # Get applied migrations in reverse order
        set -l applied_migrations (sqlite3 "$db_path" "SELECT version, name FROM schema_migrations ORDER BY version DESC LIMIT $rollback_count;")

        if test -z "$applied_migrations"
            echo "No migrations to rollback"
            return 0
        end

        # Restore from backup
        echo "Restoring database from backup..."

        # Find most recent backup before this session
        set -l restore_backup (ls -t "$backup_dir"/*.db | head -n 2 | tail -n 1)

        if test -z "$restore_backup"
            echo "Error: No backup found for rollback"
            return 1
        end

        cp "$restore_backup" "$db_path"
        echo "Rollback complete. Restored from: $restore_backup"
        return 0
    end

    # Get current schema version
    set -l current_version (sqlite3 "$db_path" "SELECT COALESCE(MAX(version), -1) FROM schema_migrations;" 2>/dev/null)

    if test -z "$current_version"
        set current_version -1
    end

    echo "Current schema version: $current_version"

    # Find pending migrations
    set -l pending_migrations

    for migration_file in (ls "$migrations_dir"/*.sql | sort)
        set -l filename (basename "$migration_file")
        set -l migration_version (string match -r '^(\d+)_' "$filename" | string split '_' | head -n 1)

        if test -z "$migration_version"
            continue
        end

        if test "$migration_version" -gt "$current_version"
            set -a pending_migrations "$migration_file"
        end
    end

    if test (count $pending_migrations) -eq 0
        echo "No pending migrations. Database is up to date."
        return 0
    end

    echo "Found "(count $pending_migrations)" pending migration(s):"

    for migration in $pending_migrations
        set -l filename (basename "$migration")
        echo "  - $filename"
    end

    if set -q _flag_dry_run
        echo ""
        echo "Dry run: No migrations applied"
        return 0
    end

    echo ""
    echo "Applying migrations..."

    # Apply each migration
    for migration in $pending_migrations
        set -l filename (basename "$migration")
        set -l migration_version (string match -r '^(\d+)_' "$filename" | string split '_' | head -n 1)
        set -l name (string replace -r '^\d+_(.+)\.sql$' '$1' "$filename")

        echo -n "Applying $filename... "

        # Calculate checksum
        set -l checksum (md5sum "$migration" | awk '{print $1}')

        # Apply migration
        if sqlite3 "$db_path" < "$migration" 2>/dev/null
            # Record migration
            sqlite3 "$db_path" "INSERT OR REPLACE INTO schema_migrations (version, name, applied_at, checksum)
                               VALUES ($migration_version, '$name', strftime('%s', 'now'), '$checksum');"

            echo "✓ Success"
        else
            echo "✗ Failed"
            echo ""
            echo "Error: Migration $filename failed"
            echo "Database has been backed up to: $backup_file"
            echo "You can restore with: cp $backup_file $db_path"
            return 1
        end
    end

    # Get new version
    set -l new_version (sqlite3 "$db_path" "SELECT MAX(version) FROM schema_migrations;")

    echo ""
    echo "Migrations complete. Schema version: $current_version → $new_version"
    echo "Backup available at: $backup_file"

    return 0
end
