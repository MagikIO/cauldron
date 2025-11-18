function __personality_list --description "List all available personalities"
    echo "Available Personalities:"
    echo ""

    # Get all personalities
    set -l personalities (sqlite3 "$CAULDRON_DATABASE" "
        SELECT name, display_name, description, is_builtin
        FROM personalities
        ORDER BY is_builtin DESC, name ASC
    " 2>/dev/null)

    if test -z "$personalities"
        echo "No personalities found"
        return 1
    end

    # Get current active personality
    set -l active_personality (sqlite3 "$CAULDRON_DATABASE" "
        SELECT preference_value
        FROM user_preferences
        WHERE preference_key = 'active_personality'
        AND project_path IS NULL
        LIMIT 1
    " 2>/dev/null)

    echo "$personalities" | while read -l line
        set -l parts (string split '|' $line)
        set -l name $parts[1]
        set -l display_name $parts[2]
        set -l description $parts[3]
        set -l is_builtin $parts[4]

        # Mark active personality
        if test "$name" = "$active_personality"
            set_color -o green
            echo -n "● "
        else
            set_color normal
            echo -n "  "
        end

        # Display name
        set_color -o cyan
        echo -n "$display_name"
        set_color normal

        # Builtin badge
        if test "$is_builtin" = "1"
            set_color yellow
            echo -n " [built-in]"
            set_color normal
        end

        echo ""

        # Description
        set_color normal
        echo "    $description"
        echo ""
    end

    echo ""
    echo "Use 'personality set <name>' to change your familiar's personality"
    echo "Use 'personality info <name>' for more details"
end
