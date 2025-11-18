function __personality_import --description "Import personality from JSON file"
    if test (count $argv) -eq 0
        echo "Usage: personality import <json_file>"
        return 1
    end

    set -l json_file $argv[1]

    if not test -f "$json_file"
        echo "Error: File not found: $json_file"
        return 1
    end

    # Parse JSON
    set -l personality_json (cat "$json_file" | jq -c '.')

    if test -z "$personality_json"
        echo "Error: Invalid JSON file"
        return 1
    end

    # Extract fields
    set -l name (echo "$personality_json" | jq -r '.name')
    set -l display_name (echo "$personality_json" | jq -r '.display_name')
    set -l description (echo "$personality_json" | jq -r '.description')
    set -l system_prompt (echo "$personality_json" | jq -r '.system_prompt')

    # Check if personality already exists
    set -l existing (sqlite3 "$CAULDRON_DATABASE" "
        SELECT id FROM personalities WHERE name = '$name'
    " 2>/dev/null)

    if test -n "$existing"
        read -l -P "Personality '$name' already exists. Overwrite? [y/N] " confirm
        if test "$confirm" != "y" -a "$confirm" != "Y"
            echo "Import cancelled"
            return 0
        end

        # Delete existing
        sqlite3 "$CAULDRON_DATABASE" "DELETE FROM personalities WHERE name = '$name'" 2>/dev/null
    end

    # Insert personality
    sqlite3 "$CAULDRON_DATABASE" "
        INSERT INTO personalities (name, display_name, description, system_prompt, is_builtin, created_at, updated_at)
        VALUES (
            '$name',
            '$display_name',
            '$description',
            '$(string replace -a "'" "''" $system_prompt)',
            0,
            strftime('%s', 'now'),
            strftime('%s', 'now')
        )
    " 2>/dev/null

    set -l personality_id (sqlite3 "$CAULDRON_DATABASE" "
        SELECT id FROM personalities WHERE name = '$name'
    " 2>/dev/null)

    if test -z "$personality_id"
        echo "Error: Failed to import personality"
        return 1
    end

    # Import traits
    echo "$personality_json" | jq -c '.traits[]' | while read -l trait
        set -l trait_name (echo "$trait" | jq -r '.trait_name')
        set -l trait_value (echo "$trait" | jq -r '.trait_value')
        set -l trait_desc (echo "$trait" | jq -r '.description')

        sqlite3 "$CAULDRON_DATABASE" "
            INSERT INTO personality_traits (personality_id, trait_name, trait_value, description)
            VALUES ($personality_id, '$trait_name', $trait_value, '$trait_desc')
        " 2>/dev/null
    end

    set_color -o green
    echo "✓ Personality '$display_name' imported successfully!"
    set_color normal
    echo ""
    echo "Activate it with: personality set $name"
end
