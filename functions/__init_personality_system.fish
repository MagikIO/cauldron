function __init_personality_system --description "Initialize personality system on shell startup"
    # Check if personality system is already initialized
    set -l personality_check (sqlite3 "$CAULDRON_DATABASE" "
        SELECT name FROM sqlite_master WHERE type='table' AND name='personalities'
    " 2>/dev/null)

    if test -z "$personality_check"
        # Personality system not initialized, run migration
        if test -f "$CAULDRON_PATH/data/migrations/001_personality_system.sql"
            sqlite3 "$CAULDRON_DATABASE" < "$CAULDRON_PATH/data/migrations/001_personality_system.sql" 2>/dev/null
        end
    end

    # Ensure adaptive_metrics has global entry
    set -l metrics_check (sqlite3 "$CAULDRON_DATABASE" "
        SELECT COUNT(*) FROM adaptive_metrics WHERE project_path IS NULL
    " 2>/dev/null)

    if test "$metrics_check" = "0"
        sqlite3 "$CAULDRON_DATABASE" "
            INSERT OR IGNORE INTO adaptive_metrics (project_path, recent_error_rate, consecutive_errors, consecutive_successes, project_complexity_score, last_updated)
            VALUES (NULL, 0.0, 0, 0, 5.0, strftime('%s', 'now'))
        " 2>/dev/null
    end

    # Ensure there's an active personality set
    set -l active_personality (sqlite3 "$CAULDRON_DATABASE" "
        SELECT preference_value FROM user_preferences
        WHERE preference_key = 'active_personality' AND project_path IS NULL
    " 2>/dev/null)

    if test -z "$active_personality"
        # Set default personality
        sqlite3 "$CAULDRON_DATABASE" "
            INSERT OR REPLACE INTO user_preferences (preference_key, preference_value, project_path, created_at, updated_at)
            VALUES ('active_personality', 'wise_mentor', NULL, strftime('%s', 'now'), strftime('%s', 'now'))
        " 2>/dev/null

        # Initialize relationship for default personality
        set -l wise_mentor_id (sqlite3 "$CAULDRON_DATABASE" "
            SELECT id FROM personalities WHERE name = 'wise_mentor' LIMIT 1
        " 2>/dev/null)

        if test -n "$wise_mentor_id"
            sqlite3 "$CAULDRON_DATABASE" "
                INSERT OR IGNORE INTO familiar_relationship (project_path, personality_id, relationship_level, first_interaction, unlocked_features)
                VALUES (NULL, $wise_mentor_id, 0, strftime('%s', 'now'), '[]')
            " 2>/dev/null
        end
    end
end
