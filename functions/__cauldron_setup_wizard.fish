#!/usr/bin/env fish

function __cauldron_setup_wizard --description "Interactive setup wizard for first-time Cauldron installation"
    # This function collects user preferences during installation
    # It stores: preferred name, pronouns, familiar name, and familiar personality

    set -l func_version "1.0.0"
    set __cauldron_category "Internal"

    # Flag options
    set -l options "s/skip" "h/help" "v/version"
    argparse -n __cauldron_setup_wizard $options -- $argv

    if set -q _flag_version
        echo $func_version
        return 0
    end

    if set -q _flag_help
        echo "Usage: __cauldron_setup_wizard [OPTIONS]"
        echo ""
        echo "Interactive setup wizard for Cauldron installation"
        echo ""
        echo "Options:"
        echo "  -s, --skip     Skip interactive setup and use defaults"
        echo "  -h, --help     Show this help message"
        echo "  -v, --version  Show version number"
        return 0
    end

    # Skip if flag is set (for non-interactive installs)
    if set -q _flag_skip
        echo "Skipping interactive setup, using defaults..."
        return 0
    end

    # Check if we're in an interactive terminal
    if not isatty stdin
        echo "Non-interactive terminal detected, skipping setup wizard..."
        return 0
    end

    # Welcome banner
    echo ""
    echo "╔═══════════════════════════════════════════════════════╗"
    echo "║                                                       ║"
    echo "║         🔮  Welcome to Cauldron Setup  🔮            ║"
    echo "║                                                       ║"
    echo "╚═══════════════════════════════════════════════════════╝"
    echo ""
    echo "Let's personalize your Cauldron experience!"
    echo ""

    # Collect user's preferred name
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  What should your familiar call you?"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    read -l -P "Your preferred name: " user_name

    # Default to username if empty
    if test -z "$user_name"
        set user_name (whoami)
        echo "  Using system username: $user_name"
    end

    # Collect user's pronouns
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  What are your preferred pronouns?"
    echo "  (e.g., he/him, she/her, they/them, etc.)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    read -l -P "Your pronouns: " user_pronouns

    # Default to they/them if empty
    if test -z "$user_pronouns"
        set user_pronouns "they/them"
        echo "  Using default: $user_pronouns"
    end

    # Collect familiar name preference
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Let's name your familiar!"
    echo "  Press Enter to generate a random name, or type your own"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    set -l familiar_name ""
    set -l satisfied "n"

    while test "$satisfied" != "y"
        read -l -P "Familiar name (Enter for random): " familiar_name_input

        if test -z "$familiar_name_input"
            # Generate random name using new-name if available
            if command -q new-name
                set familiar_name (new-name 2>/dev/null | string split " ")[1]
            else
                # Fallback to simple random names
                set -l names "Zephyr" "Luna" "Astrid" "Felix" "Nova" "Orion" "Sage" "Phoenix" "Echo" "Rune"
                set familiar_name $names[(random 1 (count $names))]
            end
            echo "  Generated name: $familiar_name"
        else
            set familiar_name $familiar_name_input
        end

        read -l -P "Happy with '$familiar_name'? (y/n/r for random): " satisfied

        if test "$satisfied" = "r"
            set satisfied "n"
        end
    end

    # Choose familiar personality
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Choose your familiar's personality:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Get personalities from database
    set -l personalities (sqlite3 "$CAULDRON_DATABASE" "
        SELECT name, display_name, description
        FROM personalities
        WHERE is_builtin = 1
        ORDER BY name ASC
    " 2>/dev/null)

    if test -n "$personalities"
        echo ""
        set -l idx 1
        set -l personality_names

        for line in $personalities
            set -l parts (string split '|' $line)
            set -l name $parts[1]
            set -l display_name $parts[2]
            set -l description $parts[3]

            set personality_names $personality_names $name

            # Truncate description if too long
            set -l short_desc $description
            if test (string length "$description") -gt 50
                set short_desc (string sub -l 47 "$description")"..."
            end

            echo "  $idx. $display_name"
            echo "     $short_desc"
            echo ""
            set idx (math $idx + 1)
        end

        # Default to wise_mentor (option 1)
        read -l -P "Select personality (1-"(count $personality_names)", default: 1): " personality_choice

        if test -z "$personality_choice"
            set personality_choice 1
        end

        # Validate input
        if test "$personality_choice" -ge 1 -a "$personality_choice" -le (count $personality_names)
            set -l selected_personality $personality_names[$personality_choice]
            echo "  Selected: $selected_personality"
        else
            set -l selected_personality "wise_mentor"
            echo "  Invalid choice, using default: wise_mentor"
        end
    else
        set -l selected_personality "wise_mentor"
        echo "  Using default personality: wise_mentor"
    end

    # Save all preferences to database
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Saving your preferences..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Build user profile string
    set -l user_profile "User: $user_name ($user_pronouns)"

    # Insert or update user preferences
    sqlite3 "$CAULDRON_DATABASE" "
        INSERT OR REPLACE INTO user_preferences (preference_key, preference_value, project_path, created_at, updated_at)
        VALUES
            ('user_name', '$user_name', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
            ('user_pronouns', '$user_pronouns', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
            ('user_profile', '$user_profile', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
            ('familiar_name', '$familiar_name', NULL, strftime('%s', 'now'), strftime('%s', 'now')),
            ('active_personality', '$selected_personality', NULL, strftime('%s', 'now'), strftime('%s', 'now'))
    " 2>/dev/null

    # Set environment variables
    set -Ux CAULDRON_USER_NAME $user_name
    set -Ux CAULDRON_USER_PRONOUNS $user_pronouns
    set -Ux CAULDRON_FAMILIAR_NAME $familiar_name

    # Initialize relationship for the selected personality
    set -l personality_id (sqlite3 "$CAULDRON_DATABASE" "
        SELECT id FROM personalities WHERE name = '$selected_personality' LIMIT 1
    " 2>/dev/null)

    if test -n "$personality_id"
        sqlite3 "$CAULDRON_DATABASE" "
            INSERT OR IGNORE INTO familiar_relationship
            (project_path, personality_id, relationship_level, total_interactions, successful_interactions, failed_interactions, first_interaction)
            VALUES
            (NULL, $personality_id, 0, 0, 0, 0, strftime('%s', 'now'))
        " 2>/dev/null
    end

    echo ""
    echo "✓ Preferences saved successfully!"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Summary:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Name:        $user_name"
    echo "  Pronouns:    $user_pronouns"
    echo "  Familiar:    $familiar_name"
    echo "  Personality: $selected_personality"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    return 0
end
