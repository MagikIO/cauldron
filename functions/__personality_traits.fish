function __personality_traits --description "Show personality traits"
    if test (count $argv) -eq 0
        echo "Usage: personality traits <name>"
        return 1
    end

    set -l personality_name $argv[1]

    # Get personality ID and display name
    set -l personality_info (sqlite3 "$CAULDRON_DATABASE" "
        SELECT id, display_name FROM personalities WHERE name = '$personality_name'
    " 2>/dev/null)

    if test -z "$personality_info"
        echo "Error: Personality '$personality_name' not found"
        return 1
    end

    set -l parts (string split '|' $personality_info)
    set -l personality_id $parts[1]
    set -l display_name $parts[2]

    set_color -o cyan
    echo "$display_name - Traits"
    set_color normal
    echo ""

    # Get traits
    set -l traits (sqlite3 "$CAULDRON_DATABASE" "
        SELECT trait_name, trait_value, description
        FROM personality_traits
        WHERE personality_id = $personality_id
        ORDER BY trait_name
    " 2>/dev/null)

    if test -z "$traits"
        echo "No traits defined for this personality"
        return 0
    end

    echo "$traits" | while read -l line
        set -l trait_parts (string split '|' $line)
        set -l trait_name $trait_parts[1]
        set -l trait_value $trait_parts[2]
        set -l trait_desc $trait_parts[3]

        # Format trait name
        set -l formatted_name (string replace -a '_' ' ' $trait_name | string upper | string sub -l 1)(string replace -a '_' ' ' $trait_name | string sub -s 2)

        echo -n "  $formatted_name: "

        # Visual bar
        set -l filled (math "round($trait_value)")
        echo -n "["
        for i in (seq $filled)
            echo -n "█"
        end
        for i in (seq (math "10 - $filled"))
            echo -n "░"
        end
        echo -n "] "

        set_color yellow
        echo -n "$trait_value/10"
        set_color normal
        set_color -d
        echo " - $trait_desc"
        set_color normal
    end

    echo ""
end
