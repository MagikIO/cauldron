function __personality_create --description "Create a custom personality"
    if test (count $argv) -eq 0
        echo "Usage: personality create <name>"
        return 1
    end

    set -l personality_name $argv[1]

    # Validate name (lowercase, underscores only)
    if not string match -qr '^[a-z_]+$' $personality_name
        echo "Error: Personality name must be lowercase letters and underscores only"
        return 1
    end

    # Check if personality already exists
    set -l existing (sqlite3 "$CAULDRON_DATABASE" "
        SELECT id FROM personalities WHERE name = '$personality_name' LIMIT 1
    " 2>/dev/null)

    if test -n "$existing"
        echo "Error: Personality '$personality_name' already exists"
        return 1
    end

    echo "Creating custom personality: $personality_name"
    echo ""

    # Collect information
    read -l -P "Display Name: " display_name
    if test -z "$display_name"
        set display_name (string replace -a '_' ' ' $personality_name | string upcasefirst)
    end

    read -l -P "Description: " description
    if test -z "$description"
        set description "A custom personality profile"
    end

    echo ""
    echo "System Prompt (the core instructions for the AI):"
    echo "Enter multiple lines, then press Ctrl+D when done:"
    echo ""

    set -l system_prompt_lines
    while read -l line
        set -a system_prompt_lines "$line"
    end

    set -l system_prompt (string join ' ' $system_prompt_lines)

    if test -z "$system_prompt"
        set system_prompt "You are a helpful AI assistant."
    end

    # Insert personality
    sqlite3 "$CAULDRON_DATABASE" "
        INSERT INTO personalities (name, display_name, description, system_prompt, is_builtin, created_at, updated_at)
        VALUES (
            '$personality_name',
            '$display_name',
            '$description',
            '$(string replace -a "'" "''" $system_prompt)',
            0,
            strftime('%s', 'now'),
            strftime('%s', 'now')
        )
    " 2>/dev/null

    set -l personality_id (sqlite3 "$CAULDRON_DATABASE" "
        SELECT id FROM personalities WHERE name = '$personality_name'
    " 2>/dev/null)

    if test -z "$personality_id"
        echo "Error: Failed to create personality"
        return 1
    end

    echo ""
    echo "Now let's set the personality traits (0-10 scale):"
    echo ""

    # Define default traits
    set -l traits humor verbosity formality patience directness

    for trait in $traits
        read -l -P "$trait (0-10): " value

        if test -z "$value"
            set value 5
        end

        # Validate value
        if not string match -qr '^\d+(\.\d+)?$' $value
            set value 5
        else if test (math "$value > 10") -eq 1
            set value 10
        else if test (math "$value < 0") -eq 1
            set value 0
        end

        sqlite3 "$CAULDRON_DATABASE" "
            INSERT INTO personality_traits (personality_id, trait_name, trait_value, description)
            VALUES (
                $personality_id,
                '$trait',
                $value,
                'Level of $trait (0-10)'
            )
        " 2>/dev/null
    end

    echo ""
    set_color -o green
    echo "✓ Personality '$display_name' created successfully!"
    set_color normal
    echo ""
    echo "Activate it with: personality set $personality_name"
end
