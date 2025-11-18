#!/usr/bin/env fish

function __get_preference -d "Get a user preference from the database" -a key project_path
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

    # Escape single quotes for SQL
    set key (string replace -a "'" "''" $key)

    # Try to get project-specific preference first, then fall back to global
    set -l value

    if test -n "$project_path"
        set project_path (string replace -a "'" "''" $project_path)
        set value (sqlite3 $CAULDRON_DATABASE "
            SELECT preference_value
            FROM user_preferences
            WHERE preference_key = '$key' AND project_path = '$project_path'
            LIMIT 1;
        " 2>/dev/null)
    end

    # If no project-specific preference found, get global preference
    if test -z "$value"
        set value (sqlite3 $CAULDRON_DATABASE "
            SELECT preference_value
            FROM user_preferences
            WHERE preference_key = '$key' AND project_path IS NULL
            LIMIT 1;
        " 2>/dev/null)
    end

    if test -n "$value"
        echo $value
        return 0
    else
        return 1
    end
end
