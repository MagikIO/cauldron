function __personality_choose --description "Interactively choose a personality"
    # Check if gum is available
    if not command -q gum
        echo "Error: 'gum' is not installed"
        echo "Install it with: brew install gum"
        return 1
    end

    # Get current active personality
    set -l active_personality (sqlite3 "$CAULDRON_DATABASE" "
        SELECT preference_value
        FROM user_preferences
        WHERE preference_key = 'active_personality'
        AND project_path IS NULL
        LIMIT 1
    " 2>/dev/null)

    # Get all personalities with their details
    set -l personalities (sqlite3 "$CAULDRON_DATABASE" "
        SELECT name, display_name, description, is_builtin
        FROM personalities
        ORDER BY is_builtin DESC, name ASC
    " 2>/dev/null)

    if test -z "$personalities"
        echo "No personalities found"
        return 1
    end

    # Build options array for gum with descriptions
    set -l options
    set -l name_map

    for line in $personalities
        set -l parts (string split '|' $line)
        set -l name $parts[1]
        set -l display_name $parts[2]
        set -l description $parts[3]
        set -l is_builtin $parts[4]

        # Create a formatted option
        set -l prefix "  "
        if test "$name" = "$active_personality"
            set prefix "● "
        end

        # Add builtin badge if applicable
        set -l badge ""
        if test "$is_builtin" = "1"
            set badge " [built-in]"
        end

        # Truncate description if too long
        set -l short_desc $description
        if test (string length "$description") -gt 60
            set short_desc (string sub -l 57 "$description")"..."
        end

        # Format: "● Display Name [built-in] - Description"
        set -l option "$prefix$display_name$badge - $short_desc"
        set options $options "$option"
        set name_map $name_map "$name"
    end

    # Show a nice header
    gum style \
        --border rounded \
        --border-foreground 213 \
        --padding "0 1" \
        --margin "1 0" \
        "Choose Your Familiar's Personality"

    # Use gum choose to select with nice styling
    set -l selected_index 1
    set -l choice (printf "%s\n" $options | gum choose \
        --height 10 \
        --header "Use arrow keys to navigate, Enter to select:" \
        --header.foreground 99 \
        --cursor.foreground 212 \
        --selected.foreground 212 \
        --cursor "→ ")

    if test -z "$choice"
        echo "No personality selected"
        return 0
    end

    # Find the index of the selected choice
    for i in (seq (count $options))
        if test "$options[$i]" = "$choice"
            set selected_index $i
            break
        end
    end

    set -l selected_name $name_map[$selected_index]

    # Ask if they want to set it globally or for the project
    set -l in_git_repo (git rev-parse --show-toplevel >/dev/null 2>&1; and echo "yes"; or echo "no")

    echo ""
    if test "$in_git_repo" = "yes"
        set -l project_name (basename (git rev-parse --show-toplevel 2>/dev/null))

        set -l scope (printf "Global (all projects)\nProject: $project_name\n" | gum choose \
            --header "Set personality for:" \
            --header.foreground 99 \
            --cursor.foreground 212 \
            --selected.foreground 212 \
            --cursor "→ ")

        if test -z "$scope"
            echo "Cancelled"
            return 0
        end

        echo ""
        if string match -q "Project:*" "$scope"
            __personality_set --project $selected_name
        else
            __personality_set $selected_name
        end
    else
        __personality_set $selected_name
    end
end
