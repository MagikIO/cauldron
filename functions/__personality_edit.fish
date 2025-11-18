function __personality_edit --description "Edit personality traits"
    if test (count $argv) -eq 0
        echo "Usage: personality edit <name>"
        return 1
    end

    set -l personality_name $argv[1]

    # Get personality details
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
        echo "Warning: This is a built-in personality"
        read -l -P "Edit built-in personality? [y/N] " confirm
        if test "$confirm" != "y" -a "$confirm" != "Y"
            echo "Edit cancelled"
            return 0
        end
    end

    echo "Editing: $display_name"
    echo ""

    # Get current traits
    set -l traits (sqlite3 "$CAULDRON_DATABASE" "
        SELECT trait_name, trait_value
        FROM personality_traits
        WHERE personality_id = $personality_id
        ORDER BY trait_name
    " 2>/dev/null)

    if test -z "$traits"
        echo "No traits defined. Add traits? [y/N]"
        read -l confirm
        if test "$confirm" = "y" -o "$confirm" = "Y"
            # Add default traits
            for trait in humor verbosity formality patience directness
                read -l -P "$trait (0-10): " value
                if test -z "$value"
                    set value 5
                end

                sqlite3 "$CAULDRON_DATABASE" "
                    INSERT INTO personality_traits (personality_id, trait_name, trait_value, description)
                    VALUES ($personality_id, '$trait', $value, 'Level of $trait (0-10)')
                " 2>/dev/null
            end

            echo "✓ Traits added"
        end
        return 0
    end

    # Edit each trait
    echo "$traits" | while read -l line
        set -l trait_parts (string split '|' $line)
        set -l trait_name $trait_parts[1]
        set -l current_value $trait_parts[2]

        read -l -P "$trait_name [$current_value]: " new_value

        if test -z "$new_value"
            continue
        end

        # Validate value
        if not string match -qr '^\d+(\.\d+)?$' $new_value
            echo "  Invalid value, skipping"
            continue
        else if test (math "$new_value > 10") -eq 1
            set new_value 10
        else if test (math "$new_value < 0") -eq 1
            set new_value 0
        end

        sqlite3 "$CAULDRON_DATABASE" "
            UPDATE personality_traits
            SET trait_value = $new_value
            WHERE personality_id = $personality_id AND trait_name = '$trait_name'
        " 2>/dev/null

        echo "  ✓ Updated $trait_name to $new_value"
    end

    echo ""
    echo "✓ Personality traits updated"
end
