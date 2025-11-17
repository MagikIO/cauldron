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

    # If project_path is not provided, it's a global preference (NULL)
    set -l project_clause "NULL"
    if test -n "$project_path"
        set project_clause "'$project_path'"
    end

    # Escape single quotes for SQL
    set key (string replace -a "'" "''" $key)
    set value (string replace -a "'" "''" $value)

    # Insert or update preference
    sqlite3 $CAULDRON_DATABASE "
        INSERT INTO user_preferences (preference_key, preference_value, project_path, created_at, updated_at)
        VALUES ('$key', '$value', $project_clause, strftime('%s', 'now'), strftime('%s', 'now'))
        ON CONFLICT(preference_key, project_path) DO UPDATE SET
            preference_value = '$value',
            updated_at = strftime('%s', 'now');
    " 2>/dev/null

    if test $status -eq 0
        return 0
    else
        return 1
    end
end
