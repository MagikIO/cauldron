function __personality_export --description "Export personality to JSON file"
    if test (count $argv) -eq 0
        echo "Usage: personality export <name> [output_file]"
        return 1
    end

    set -l personality_name $argv[1]
    set -l output_file

    if test (count $argv) -ge 2
        set output_file $argv[2]
    else
        set output_file "$personality_name.json"
    end

    # Get personality data
    set -l personality_data (sqlite3 "$CAULDRON_DATABASE" "
        SELECT json_object(
            'name', p.name,
            'display_name', p.display_name,
            'description', p.description,
            'system_prompt', p.system_prompt,
            'traits', (
                SELECT json_group_array(
                    json_object(
                        'trait_name', trait_name,
                        'trait_value', trait_value,
                        'description', description
                    )
                )
                FROM personality_traits
                WHERE personality_id = p.id
            )
        )
        FROM personalities p
        WHERE p.name = '$personality_name'
    " 2>/dev/null)

    if test -z "$personality_data"
        echo "Error: Personality '$personality_name' not found"
        return 1
    end

    # Write to file
    echo "$personality_data" | jq '.' > "$output_file"

    if test $status -eq 0
        set_color -o green
        echo "✓ Personality exported to: $output_file"
        set_color normal
    else
        echo "Error: Failed to export personality"
        return 1
    end
end
