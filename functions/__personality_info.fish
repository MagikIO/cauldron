function __personality_info --description "Show detailed personality information"
    if test (count $argv) -eq 0
        echo "Usage: personality info <name>"
        return 1
    end

    set -l personality_name $argv[1]

    # Get personality details
    set -l personality_data (sqlite3 "$CAULDRON_DATABASE" "
        SELECT p.id, p.display_name, p.description, p.system_prompt, p.is_builtin,
               datetime(p.created_at, 'unixepoch', 'localtime') as created
        FROM personalities p
        WHERE p.name = '$personality_name'
        LIMIT 1
    " 2>/dev/null)

    if test -z "$personality_data"
        echo "Error: Personality '$personality_name' not found"
        return 1
    end

    set -l parts (string split '|' $personality_data)
    set -l id $parts[1]
    set -l display_name $parts[2]
    set -l description $parts[3]
    set -l system_prompt $parts[4]
    set -l is_builtin $parts[5]
    set -l created $parts[6]

    # Display header
    set_color -o cyan
    echo "$display_name"
    set_color normal

    if test "$is_builtin" = "1"
        set_color yellow
        echo "[Built-in Personality]"
        set_color normal
    else
        echo "[Custom Personality]"
    end

    echo ""
    echo "$description"
    echo ""

    # System prompt
    set_color -o yellow
    echo "System Prompt:"
    set_color normal
    echo "\"$system_prompt\""
    echo ""

    # Traits
    set_color -o green
    echo "Personality Traits:"
    set_color normal

    set -l traits (sqlite3 "$CAULDRON_DATABASE" "
        SELECT trait_name, trait_value, description
        FROM personality_traits
        WHERE personality_id = $id
        ORDER BY trait_name
    " 2>/dev/null)

    if test -n "$traits"
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

            set_color -d
            echo "$trait_value/10"
            set_color normal
        end
    else
        echo "  No custom traits defined"
    end

    echo ""
    echo "Created: $created"
    echo ""
end
