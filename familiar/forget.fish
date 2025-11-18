#!/usr/bin/env fish

function forget -d "Clear conversation history or remove preferences"
    # Version Number
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help a/all s/session p/preference= y/yes
    argparse -n forget $options -- $argv

    if set -q _flag_version
        echo $func_version
        return
    end

    if set -q _flag_help
        echo "Usage: forget [OPTIONS]"
        echo "Version: $func_version"
        echo "Clear conversation history or remove preferences"
        echo
        echo "Options:"
        echo "  -v, --version        Show the version number"
        echo "  -h, --help           Show this help message"
        echo "  -s, --session        Clear conversation history for current session"
        echo "  -a, --all            Clear all conversation history"
        echo "  -p, --preference KEY Remove a specific preference"
        echo "  -y, --yes            Skip confirmation prompt"
        echo
        echo "Examples:"
        echo "  forget -s               # Clear this session's conversations"
        echo "  forget -a               # Clear all conversations (with confirmation)"
        echo "  forget -p coding_style  # Remove the 'coding_style' preference"
        echo "  forget -a -y            # Clear all without confirmation"
        return
    end

    # Check dependencies
    if not set -q CAULDRON_DATABASE
        echo "Error: Memory system not initialized. Run '__init_memory' first."
        return 1
    end

    if not command -q sqlite3
        echo "Error: sqlite3 is not installed"
        return 1
    end

    # Remove a specific preference
    if set -q _flag_preference
        set key (string replace -a "'" "''" $_flag_preference)

        # Check if preference exists
        set existing (sqlite3 $CAULDRON_DATABASE "
            SELECT preference_key FROM user_preferences WHERE preference_key = '$key' LIMIT 1;
        " 2>/dev/null)

        if test -z "$existing"
            echo "Preference '$_flag_preference' not found"
            return 1
        end

        # Confirm deletion unless -y flag is set
        if not set -q _flag_yes
            echo "Are you sure you want to forget '$_flag_preference'? (y/N)"
            read -l confirm
            if test "$confirm" != "y" -a "$confirm" != "Y"
                echo "Cancelled"
                return 0
            end
        end

        # Delete preference
        sqlite3 $CAULDRON_DATABASE "
            DELETE FROM user_preferences WHERE preference_key = '$key';
        " 2>/dev/null

        if test $status -eq 0
            f-says "I've forgotten about $_flag_preference" -n
            return 0
        else
            echo "Error: Failed to remove preference"
            return 1
        end
    end

    # Clear conversation history
    if set -q _flag_session
        if not set -q CAULDRON_SESSION_ID
            echo "Error: No active session found"
            return 1
        end

        # Confirm deletion unless -y flag is set
        if not set -q _flag_yes
            echo "Clear all conversation history for this session? (y/N)"
            read -l confirm
            if test "$confirm" != "y" -a "$confirm" != "Y"
                echo "Cancelled"
                return 0
            end
        end

        # Delete session conversations
        sqlite3 $CAULDRON_DATABASE "
            DELETE FROM conversation_history WHERE session_id = '$CAULDRON_SESSION_ID';
        " 2>/dev/null

        if test $status -eq 0
            f-says "I've forgotten our conversation from this session" --stoned -n
            return 0
        else
            echo "Error: Failed to clear session history"
            return 1
        end
    else if set -q _flag_all
        # Confirm deletion unless -y flag is set
        if not set -q _flag_yes
            echo "⚠️  WARNING: This will delete ALL conversation history!"
            echo "Are you absolutely sure? (yes/N)"
            read -l confirm
            if test "$confirm" != "yes"
                echo "Cancelled"
                return 0
            end
        end

        # Delete all conversations
        sqlite3 $CAULDRON_DATABASE "
            DELETE FROM conversation_history;
        " 2>/dev/null

        if test $status -eq 0
            f-says "All conversation history has been cleared" --dead -n
            return 0
        else
            echo "Error: Failed to clear all history"
            return 1
        end
    else
        echo "Error: Please specify what to forget"
        echo "Use --session, --all, or --preference"
        echo "Run 'forget --help' for more information"
        return 1
    end
end
