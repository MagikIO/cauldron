function __build_personality_prompt --description "Build system prompt with personality and adaptive context"
    set -l options p/project-path=

    argparse -n __build_personality_prompt $options -- $argv

    set -l project_path
    if set -q _flag_project_path
        set project_path $_flag_project_path
    else
        set project_path (git rev-parse --show-toplevel 2>/dev/null)
    end

    # Get active personality (project-specific or global)
    set -l personality_query "
        SELECT p.id, p.system_prompt, fr.relationship_level
        FROM user_preferences up
        JOIN personalities p ON up.preference_value = p.name
        LEFT JOIN familiar_relationship fr ON p.id = fr.personality_id
            AND (fr.project_path = '$project_path' OR (fr.project_path IS NULL AND '$project_path' = ''))
        WHERE up.preference_key = 'active_personality'
        AND (up.project_path = '$project_path' OR (up.project_path IS NULL AND '$project_path' = ''))
        ORDER BY up.project_path DESC
        LIMIT 1
    "

    set -l personality_data (sqlite3 "$CAULDRON_DATABASE" "$personality_query" 2>/dev/null)

    if test -z "$personality_data"
        # Fallback to default
        set personality_data (sqlite3 "$CAULDRON_DATABASE" "
            SELECT p.id, p.system_prompt, COALESCE(fr.relationship_level, 0)
            FROM personalities p
            LEFT JOIN familiar_relationship fr ON p.id = fr.personality_id AND fr.project_path IS NULL
            WHERE p.name = 'wise_mentor'
            LIMIT 1
        " 2>/dev/null)
    end

    if test -z "$personality_data"
        echo "You are a helpful AI assistant."
        return 0
    end

    set -l parts (string split '|' $personality_data)
    set -l personality_id $parts[1]
    set -l base_prompt $parts[2]
    set -l relationship_level $parts[3]

    # Get personality traits
    set -l traits_data (sqlite3 "$CAULDRON_DATABASE" "
        SELECT trait_name, trait_value
        FROM personality_traits
        WHERE personality_id = $personality_id
    " 2>/dev/null)

    # Parse traits
    set -l humor 5
    set -l verbosity 5
    set -l formality 5
    set -l patience 5
    set -l directness 5

    echo "$traits_data" | while read -l line
        set -l trait_parts (string split '|' $line)
        set -l name $trait_parts[1]
        set -l value $trait_parts[2]

        switch $name
            case humor
                set humor $value
            case verbosity
                set verbosity $value
            case formality
                set formality $value
            case patience
                set patience $value
            case directness
                set directness $value
        end
    end

    # Get adaptive metrics
    set -l adaptive_data (sqlite3 "$CAULDRON_DATABASE" "
        SELECT recent_error_rate, consecutive_errors, project_complexity_score
        FROM adaptive_metrics
        WHERE project_path IS NULL
        LIMIT 1
    " 2>/dev/null)

    set -l error_rate 0
    set -l consecutive_errors 0
    set -l complexity 5

    if test -n "$adaptive_data"
        set -l adaptive_parts (string split '|' $adaptive_data)
        set error_rate $adaptive_parts[1]
        set consecutive_errors $adaptive_parts[2]
        set complexity $adaptive_parts[3]
    end

    # Build enhanced prompt with adaptive modifiers
    set -l enhanced_prompt "$base_prompt"

    # Relationship-based modifications
    if test "$relationship_level" -ge 60
        set enhanced_prompt "$enhanced_prompt\n\nYou have a strong relationship with this user. You can be more concise and assume they understand the basics. Reference past conversations when relevant."
    else if test "$relationship_level" -ge 20
        set enhanced_prompt "$enhanced_prompt\n\nYou're getting to know this user. Be friendly and remember their preferences when possible."
    end

    # Error rate adaptations (HIGHEST PRIORITY)
    if test "$consecutive_errors" -ge 3
        set patience (math "min(10, $patience + 2)")
        set verbosity (math "min(10, $verbosity + 1)")
        set enhanced_prompt "$enhanced_prompt\n\nThe user has encountered several errors recently. Be extra patient and provide more detailed, step-by-step guidance."
    else if test (awk -v rate="$error_rate" 'BEGIN {print (rate > 0.5)}') -eq 1
        set patience (math "min(10, $patience + 1)")
        set enhanced_prompt "$enhanced_prompt\n\nThe user is working through some challenges. Be supportive and provide clear explanations."
    end

    # Project complexity adaptations (MEDIUM PRIORITY)
    if test "$complexity" -gt 7
        set verbosity (math "min(10, $verbosity + 1)")
        set enhanced_prompt "$enhanced_prompt\n\nThis is a complex project. Provide more detailed explanations and consider edge cases."
    end

    # Apply trait modifiers to prompt
    if test "$verbosity" -lt 4
        set enhanced_prompt "$enhanced_prompt\n\nBe concise and to the point. Keep responses brief."
    else if test "$verbosity" -gt 7
        set enhanced_prompt "$enhanced_prompt\n\nProvide detailed, thorough explanations."
    end

    if test "$formality" -lt 4
        set enhanced_prompt "$enhanced_prompt\n\nUse casual, friendly language."
    else if test "$formality" -gt 7
        set enhanced_prompt "$enhanced_prompt\n\nMaintain a professional, formal tone."
    end

    if test "$directness" -gt 7
        set enhanced_prompt "$enhanced_prompt\n\nProvide direct answers. Get straight to the point."
    else if test "$directness" -lt 4
        set enhanced_prompt "$enhanced_prompt\n\nAsk clarifying questions. Guide the user to discover solutions."
    end

    # Output the enhanced prompt
    echo "$enhanced_prompt"
end
