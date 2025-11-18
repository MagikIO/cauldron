function __personality_delete --description "Delete a custom personality"
    if test (count $argv) -eq 0
        echo "Usage: personality delete <name>"
        return 1
    end

    set -l personality_name $argv[1]

    # Get personality info
    set -l personality_info (sqlite3 "$CAULDRON_DATABASE" "
        SELECT id, display_name, is_builtin FROM personalities WHERE name = '$personality_name'
    " 2>/dev/null)

    if test -z "$personality_info"
        echo "Error: Personality '$personality_name' not found"
        return 1
    end

    set -l parts (string split '|' $personality_info)
    set -l personality_id $parts[1]
    set -l display_name $parts[2]
    set -l is_builtin $parts[3]

    if test "$is_builtin" = "1"
        echo "Error: Cannot delete built-in personality"
        return 1
    end

    # Check if it's the active personality
    set -l is_active (sqlite3 "$CAULDRON_DATABASE" "
        SELECT COUNT(*) FROM user_preferences
        WHERE preference_key = 'active_personality'
        AND preference_value = '$personality_name'
    " 2>/dev/null)

    if test "$is_active" -gt 0
        echo "Warning: '$display_name' is currently active"
        echo "You'll be switched to the default personality after deletion"
        echo ""
    end

    read -l -P "Delete personality '$display_name'? [y/N] " confirm
    if test "$confirm" != "y" -a "$confirm" != "Y"
        echo "Deletion cancelled"
        return 0
    end

    # Delete personality (CASCADE will delete traits and relationships)
    sqlite3 "$CAULDRON_DATABASE" "
        DELETE FROM personalities WHERE id = $personality_id
    " 2>/dev/null

    # If it was active, switch to default
    if test "$is_active" -gt 0
        sqlite3 "$CAULDRON_DATABASE" "
            UPDATE user_preferences
            SET preference_value = 'wise_mentor', updated_at = strftime('%s', 'now')
            WHERE preference_key = 'active_personality'
        " 2>/dev/null
    end

    echo "✓ Personality '$display_name' deleted"
end
