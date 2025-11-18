function __personality_set --description "Set active personality"
    set -l options p/project

    argparse -n __personality_set $options -- $argv
    or return 1

    if test (count $argv) -eq 0
        echo "Usage: personality set <name> [--project]"
        echo ""
        echo "Options:"
        echo "  -p, --project  Set personality for current project only"
        return 1
    end

    set -l personality_name $argv[1]
    set -l project_path

    # Get project path if --project flag is set
    if set -q _flag_project
        set project_path (git rev-parse --show-toplevel 2>/dev/null)
        if test -z "$project_path"
            echo "Error: Not in a git repository"
            echo "Project-specific personalities require a git repository"
            return 1
        end
    end

    # Verify personality exists
    set -l personality_id (sqlite3 "$CAULDRON_DATABASE" "
        SELECT id FROM personalities WHERE name = '$personality_name' LIMIT 1
    " 2>/dev/null)

    if test -z "$personality_id"
        echo "Error: Personality '$personality_name' not found"
        echo "Run 'personality list' to see available personalities"
        return 1
    end

    # Determine scope
    set -l scope_desc "global"
    set -l project_value "NULL"

    if set -q _flag_project
        set scope_desc "project: $(basename $project_path)"
        set project_value "'$project_path'"
    end

    # Update user preference
    if set -q _flag_project
        sqlite3 "$CAULDRON_DATABASE" "
            INSERT OR REPLACE INTO user_preferences (preference_key, preference_value, project_path, created_at, updated_at)
            VALUES ('active_personality', '$personality_name', '$project_path', strftime('%s', 'now'), strftime('%s', 'now'))
        " 2>/dev/null
    else
        sqlite3 "$CAULDRON_DATABASE" "
            UPDATE user_preferences
            SET preference_value = '$personality_name', updated_at = strftime('%s', 'now')
            WHERE preference_key = 'active_personality' AND project_path IS NULL
        " 2>/dev/null
    end

    # Initialize relationship if needed
    sqlite3 "$CAULDRON_DATABASE" "
        INSERT OR IGNORE INTO familiar_relationship (project_path, personality_id, relationship_level, first_interaction, unlocked_features)
        VALUES ($project_value, $personality_id, 0, strftime('%s', 'now'), '[]')
    " 2>/dev/null

    # Get display name
    set -l display_name (sqlite3 "$CAULDRON_DATABASE" "
        SELECT display_name FROM personalities WHERE id = $personality_id
    " 2>/dev/null)

    echo "✓ Personality set to: $display_name ($scope_desc)"
    echo ""
    echo "Your familiar's personality has been updated!"
    echo "Try: ask \"Hello! Tell me about yourself\""
end
