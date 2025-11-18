#!/usr/bin/env fish

function remember -d "Save a preference or fact for your familiar to remember"
    # Version Number
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help p/project g/global l/list
    argparse -n remember $options -- $argv

    if set -q _flag_version
        echo $func_version
        return
    end

    if set -q _flag_help
        echo "Usage: remember [OPTIONS] <key> <value>"
        echo "       remember --list"
        echo "Version: $func_version"
        echo "Save a preference or fact for your familiar to remember"
        echo
        echo "Options:"
        echo "  -v, --version    Show the version number"
        echo "  -h, --help       Show this help message"
        echo "  -p, --project    Save as project-specific preference (default)"
        echo "  -g, --global     Save as global preference"
        echo "  -l, --list       List all saved preferences"
        echo
        echo "Examples:"
        echo "  remember coding_style 'prefer strict TypeScript'"
        echo "  remember -g editor 'neovim'"
        echo "  remember preferred_framework 'Next.js'"
        echo "  remember --list"
        return
    end

    # Check dependencies
    if not set -q CAULDRON_DATABASE
        echo "Error: Memory system not initialized. Run '__init_memory' first."
        return 1
    end

    # List preferences
    if set -q _flag_list
        echo "Saved preferences:"
        echo ""

        set -l prefs (sqlite3 $CAULDRON_DATABASE "
            SELECT
                preference_key,
                preference_value,
                CASE WHEN project_path IS NULL THEN 'global' ELSE project_path END as scope,
                datetime(updated_at, 'unixepoch', 'localtime') as last_updated
            FROM user_preferences
            ORDER BY updated_at DESC;
        " 2>/dev/null)

        if test -n "$prefs"
            echo $prefs | while read -l line
                echo $line | awk -F '|' '{printf "  %s = %s [%s] (updated: %s)\n", $1, $2, $3, $4}'
            end
        else
            echo "  No preferences saved yet."
        end
        return 0
    end

    # Save a preference
    if test (count $argv) -lt 2
        echo "Error: Both key and value are required"
        echo "Usage: remember <key> <value>"
        return 1
    end

    set -l key $argv[1]
    set -l value $argv[2..-1]

    # Determine scope
    set -l project_path ""
    if not set -q _flag_global
        # Default to project-specific
        if git rev-parse --show-toplevel >/dev/null 2>&1
            set project_path (git rev-parse --show-toplevel)
        else
            set project_path (pwd)
        end
    end

    # Save preference
    if __save_preference "$key" "$value" "$project_path"
        if test -n "$project_path"
            f-says "I'll remember that $key = $value for this project!" -n
        else
            f-says "I'll remember that $key = $value globally!" -n
        end
        return 0
    else
        echo "Error: Failed to save preference"
        return 1
    end
end
