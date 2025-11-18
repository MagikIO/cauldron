#!/usr/bin/env fish

function __save_preference -d "Save a user preference to the database" -a key value project_path
    # Check dependencies
    if not set -q CAULDRON_DATABASE
        return 1
    end

    if not command -q sqlite3
        return 1
    end

    if test -z "$key"
        echo "Error: preference key is required"
        return 1
    end

    if test -z "$value"
        echo "Error: preference value is required"
        return 1
    end

    # Escape single quotes for SQL
    set key (string replace -a "'" "''" $key)
    set value (string replace -a "'" "''" $value)

    # Handle NULL project_path specially because SQLite treats NULL != NULL in UNIQUE constraints
    if test -z "$project_path"
        # For global preferences (project_path IS NULL), use separate logic
        # First try to update existing preference
        sqlite3 $CAULDRON_DATABASE "
            UPDATE user_preferences
            SET preference_value = '$value', updated_at = strftime('%s', 'now')
            WHERE preference_key = '$key' AND project_path IS NULL;
        " 2>/dev/null

        # Check if any rows were updated
        set -l changes (sqlite3 $CAULDRON_DATABASE "SELECT changes();" 2>/dev/null)

        # If no rows were updated, insert new preference
        if test "$changes" = "0"
            sqlite3 $CAULDRON_DATABASE "
                INSERT INTO user_preferences (preference_key, preference_value, project_path, created_at, updated_at)
                VALUES ('$key', '$value', NULL, strftime('%s', 'now'), strftime('%s', 'now'));
            " 2>/dev/null
        end
    else
        # For project-specific preferences, ON CONFLICT works fine
        set project_path (string replace -a "'" "''" $project_path)
        sqlite3 $CAULDRON_DATABASE "
            INSERT INTO user_preferences (preference_key, preference_value, project_path, created_at, updated_at)
            VALUES ('$key', '$value', '$project_path', strftime('%s', 'now'), strftime('%s', 'now'))
            ON CONFLICT(preference_key, project_path) DO UPDATE SET
                preference_value = '$value',
                updated_at = strftime('%s', 'now');
        " 2>/dev/null
    end

    if test $status -eq 0
        return 0
    else
        return 1
    end
end
