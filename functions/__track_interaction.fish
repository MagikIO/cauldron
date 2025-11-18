function __track_interaction --description "Track interaction and update relationship metrics"
    set -l options s/success f/failure e/error-rate=

    argparse -n __track_interaction $options -- $argv

    set -l project_path (git rev-parse --show-toplevel 2>/dev/null)
    set -l success 1

    if set -q _flag_failure
        set success 0
    end

    # Get active personality
    set -l personality_id (sqlite3 "$CAULDRON_DATABASE" "
        SELECT p.id
        FROM user_preferences up
        JOIN personalities p ON up.preference_value = p.name
        WHERE up.preference_key = 'active_personality'
        AND up.project_path IS NULL
        LIMIT 1
    " 2>/dev/null)

    if test -z "$personality_id"
        return 0
    end

    # Update familiar relationship
    set -l relationship_change 0

    if test "$success" -eq 1
        # Successful interaction increases relationship
        set relationship_change (math "max(1, 100 - (SELECT COALESCE(relationship_level, 0) FROM familiar_relationship WHERE personality_id = $personality_id AND project_path IS NULL)) / 20")

        sqlite3 "$CAULDRON_DATABASE" "
            UPDATE familiar_relationship
            SET total_interactions = total_interactions + 1,
                successful_interactions = successful_interactions + 1,
                relationship_level = min(100, relationship_level + $relationship_change),
                last_interaction = strftime('%s', 'now')
            WHERE personality_id = $personality_id AND project_path IS NULL
        " 2>/dev/null
    else
        # Failed interaction has smaller impact
        set relationship_change 0

        sqlite3 "$CAULDRON_DATABASE" "
            UPDATE familiar_relationship
            SET total_interactions = total_interactions + 1,
                failed_interactions = failed_interactions + 1,
                last_interaction = strftime('%s', 'now')
            WHERE personality_id = $personality_id AND project_path IS NULL
        " 2>/dev/null
    end

    # Check for unlocked features based on relationship level
    set -l current_level (sqlite3 "$CAULDRON_DATABASE" "
        SELECT relationship_level FROM familiar_relationship
        WHERE personality_id = $personality_id AND project_path IS NULL
    " 2>/dev/null)

    if test -n "$current_level"
        set -l unlocked_features "[]"

        if test "$current_level" -ge 5
            set unlocked_features (echo "$unlocked_features" | jq '. + ["casual_greetings"]')
        end

        if test "$current_level" -ge 20
            set unlocked_features (echo "$unlocked_features" | jq '. + ["preference_memory"]')
        end

        if test "$current_level" -ge 40
            set unlocked_features (echo "$unlocked_features" | jq '. + ["inside_jokes"]')
        end

        if test "$current_level" -ge 60
            set unlocked_features (echo "$unlocked_features" | jq '. + ["concise_mode"]')
        end

        if test "$current_level" -ge 80
            set unlocked_features (echo "$unlocked_features" | jq '. + ["proactive_suggestions"]')
        end

        if test "$current_level" -ge 100
            set unlocked_features (echo "$unlocked_features" | jq '. + ["max_familiarity"]')
        end

        sqlite3 "$CAULDRON_DATABASE" "
            UPDATE familiar_relationship
            SET unlocked_features = '$unlocked_features'
            WHERE personality_id = $personality_id AND project_path IS NULL
        " 2>/dev/null
    end

    # Update adaptive metrics
    if set -q _flag_error_rate
        set -l error_rate $_flag_error_rate

        sqlite3 "$CAULDRON_DATABASE" "
            UPDATE adaptive_metrics
            SET recent_error_rate = $error_rate,
                consecutive_errors = CASE WHEN $success = 0 THEN consecutive_errors + 1 ELSE 0 END,
                consecutive_successes = CASE WHEN $success = 1 THEN consecutive_successes + 1 ELSE 0 END,
                last_updated = strftime('%s', 'now')
            WHERE project_path IS NULL
        " 2>/dev/null
    else
        sqlite3 "$CAULDRON_DATABASE" "
            UPDATE adaptive_metrics
            SET consecutive_errors = CASE WHEN $success = 0 THEN consecutive_errors + 1 ELSE 0 END,
                consecutive_successes = CASE WHEN $success = 1 THEN consecutive_successes + 1 ELSE 0 END,
                last_updated = strftime('%s', 'now')
            WHERE project_path IS NULL
        " 2>/dev/null
    end

    # Record interaction history
    set -l outcome "success"
    if test "$success" -eq 0
        set outcome "failure"
    end

    sqlite3 "$CAULDRON_DATABASE" "
        INSERT INTO interaction_history (personality_id, project_path, timestamp, interaction_type, outcome)
        VALUES ($personality_id, NULL, strftime('%s', 'now'), 'query', '$outcome')
    " 2>/dev/null

    return 0
end
