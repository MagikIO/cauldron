function __personality_show --description "Show current personality and relationship status"
    # Get current project path
    set -l project_path (git rev-parse --show-toplevel 2>/dev/null)

    # Get active personality
    set -l personality_data (sqlite3 "$CAULDRON_DATABASE" "
        SELECT p.name, p.display_name, p.description, fr.relationship_level,
               fr.total_interactions, fr.successful_interactions, fr.failed_interactions,
               fr.unlocked_features
        FROM user_preferences up
        JOIN personalities p ON up.preference_value = p.name
        LEFT JOIN familiar_relationship fr ON p.id = fr.personality_id AND fr.project_path IS NULL
        WHERE up.preference_key = 'active_personality'
        AND up.project_path IS NULL
        LIMIT 1
    " 2>/dev/null)

    if test -z "$personality_data"
        echo "No active personality found"
        echo "Run 'personality list' to see available personalities"
        return 1
    end

    set -l parts (string split '|' $personality_data)
    set -l name $parts[1]
    set -l display_name $parts[2]
    set -l description $parts[3]
    set -l relationship_level $parts[4]
    set -l total_interactions $parts[5]
    set -l successful_interactions $parts[6]
    set -l failed_interactions $parts[7]
    set -l unlocked_features $parts[8]

    # Display personality info
    set_color -o magenta
    echo "🔮 Current Personality"
    set_color normal
    echo ""

    set_color -o cyan
    echo "$display_name"
    set_color normal
    echo "$description"
    echo ""

    # Relationship status
    set_color -o yellow
    echo "📊 Relationship Status"
    set_color normal
    echo ""

    # Calculate relationship tier
    set -l tier "Stranger"
    set -l tier_color normal

    if test "$relationship_level" -ge 80
        set tier "Soul Bond"
        set tier_color magenta
    else if test "$relationship_level" -ge 60
        set tier "Trusted Companion"
        set tier_color blue
    else if test "$relationship_level" -ge 40
        set tier "Good Friend"
        set tier_color cyan
    else if test "$relationship_level" -ge 20
        set tier "Acquaintance"
        set tier_color green
    else if test "$relationship_level" -ge 5
        set tier "New Friend"
        set tier_color yellow
    end

    echo -n "  Level: "
    set_color $tier_color
    echo -n "$relationship_level/100"
    set_color normal
    echo " ($tier)"

    # Progress bar
    echo -n "  ["
    set -l filled (math "round($relationship_level / 5)")
    set -l empty (math "20 - $filled")

    set_color $tier_color
    for i in (seq $filled)
        echo -n "█"
    end
    set_color -d
    for i in (seq $empty)
        echo -n "░"
    end
    set_color normal
    echo "]"

    echo ""
    echo "  Total Interactions: $total_interactions"

    if test "$total_interactions" -gt 0
        set -l success_rate (math "round($successful_interactions / $total_interactions * 100)")
        echo "  Success Rate: $success_rate%"
    end

    # Unlocked features
    if test -n "$unlocked_features"; and test "$unlocked_features" != "[]"
        echo ""
        set_color -o green
        echo "✨ Unlocked Features"
        set_color normal
        echo "$unlocked_features" | jq -r '.[]' | while read -l feature
            echo "  • $feature"
        end
    end

    # Show next milestone
    echo ""
    set_color -o blue
    echo "🎯 Next Milestone"
    set_color normal

    if test "$relationship_level" -lt 5
        echo "  Reach level 5 to unlock: Casual greetings"
    else if test "$relationship_level" -lt 20
        echo "  Reach level 20 to unlock: Remembers your preferences"
    else if test "$relationship_level" -lt 40
        echo "  Reach level 40 to unlock: Inside jokes and callbacks"
    else if test "$relationship_level" -lt 60
        echo "  Reach level 60 to unlock: Concise responses (assumes knowledge)"
    else if test "$relationship_level" -lt 80
        echo "  Reach level 80 to unlock: Proactive suggestions"
    else if test "$relationship_level" -lt 100
        echo "  Reach level 100 to unlock: Max familiarity"
    else
        echo "  🎉 Maximum familiarity achieved!"
    end

    echo ""
end
