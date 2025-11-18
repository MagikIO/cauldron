#!/usr/bin/env bash
# proactive.bash - Bash shell integration for Cauldron Proactive Intelligence
# Add this to your ~/.bashrc:
#   source ~/.config/cauldron/integrations/proactive.bash

# Ensure Cauldron is initialized
if [ -z "$CAULDRON_DATABASE" ]; then
    echo "Warning: Cauldron not initialized. Run 'cauldron init' first." >&2
    return 1
fi

# Track command start time
__cauldron_preexec() {
    __CAULDRON_CMD_START_TIME=$(date +%s%3N)
    __CAULDRON_LAST_CMD="$BASH_COMMAND"
}

# Monitor command completion
__cauldron_postexec() {
    local exit_code=$?
    local cmd="$__CAULDRON_LAST_CMD"

    # Skip if proactive intelligence is disabled
    local enabled=$(sqlite3 "$CAULDRON_DATABASE" "SELECT preference_value FROM user_preferences WHERE preference_key = 'enable_proactive_suggestions' AND project_path IS NULL;" 2>/dev/null)
    if [ "$enabled" != "true" ]; then
        return 0
    fi

    # Calculate duration
    local end_time=$(date +%s%3N)
    local duration=$((end_time - __CAULDRON_CMD_START_TIME))

    # Store in database
    local timestamp=$(date +%s)
    local cwd=$(pwd)

    sqlite3 "$CAULDRON_DATABASE" "
        INSERT INTO command_history (session_id, command, exit_code, duration_ms, timestamp, working_directory)
        VALUES ('$CAULDRON_SESSION_ID', '$(echo "$cmd" | sed "s/'/''/g")', $exit_code, $duration, $timestamp, '$(echo "$cwd" | sed "s/'/''/g")');
    " 2>/dev/null

    # Run proactive monitors in background
    if [ $exit_code -ne 0 ]; then
        # Error watcher
        (fish -c "__proactive_error_watcher '$cmd' $exit_code $duration" 2>/dev/null &)
    fi

    # Process monitor for long-running commands (> 60 seconds)
    if [ $duration -gt 60000 ]; then
        (fish -c "__proactive_process_monitor '$cmd' $duration $exit_code" 2>/dev/null &)
    fi

    return 0
}

# Set up trap for DEBUG signal (runs before each command)
trap '__cauldron_preexec' DEBUG

# Set up PROMPT_COMMAND to run after each command
if [ -z "$PROMPT_COMMAND" ]; then
    PROMPT_COMMAND="__cauldron_postexec"
else
    PROMPT_COMMAND="__cauldron_postexec; $PROMPT_COMMAND"
fi

# User-facing commands for controlling proactive intelligence
proactive() {
    local subcommand="$1"

    case "$subcommand" in
        on|enable)
            sqlite3 "$CAULDRON_DATABASE" "
                INSERT OR REPLACE INTO user_preferences (preference_key, preference_value, project_path, created_at, updated_at)
                VALUES ('enable_proactive_suggestions', 'true', NULL, strftime('%s', 'now'), strftime('%s', 'now'));
            " 2>/dev/null
            echo "Proactive intelligence enabled!"
            ;;

        off|disable)
            sqlite3 "$CAULDRON_DATABASE" "
                UPDATE user_preferences
                SET preference_value = 'false', updated_at = strftime('%s', 'now')
                WHERE preference_key = 'enable_proactive_suggestions' AND project_path IS NULL;
            " 2>/dev/null
            echo "Proactive intelligence disabled."
            ;;

        status)
            fish -c "__proactive_status" 2>/dev/null
            ;;

        alerts)
            echo "Pending Alerts:"
            echo "==============="
            sqlite3 "$CAULDRON_DATABASE" "
                SELECT alert_type || ': ' || message
                FROM proactive_alerts
                WHERE dismissed_at IS NULL
                ORDER BY priority DESC, triggered_at DESC
                LIMIT 10;
            " 2>/dev/null
            ;;

        clear)
            sqlite3 "$CAULDRON_DATABASE" "
                UPDATE proactive_alerts
                SET dismissed_at = strftime('%s', 'now')
                WHERE dismissed_at IS NULL;
            " 2>/dev/null
            echo "All alerts dismissed."
            ;;

        help|*)
            echo "Usage: proactive [command]"
            echo ""
            echo "Commands:"
            echo "  on, enable    - Enable proactive intelligence"
            echo "  off, disable  - Disable proactive intelligence"
            echo "  status        - Show current status"
            echo "  alerts        - Show pending alerts"
            echo "  clear         - Dismiss all alerts"
            echo "  help          - Show this help message"
            ;;
    esac
}

# Auto-complete for proactive command
_proactive_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "on off enable disable status alerts clear patterns help" -- "$cur"))
}

complete -F _proactive_completions proactive
