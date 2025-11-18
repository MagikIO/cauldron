#!/usr/bin/env zsh
# proactive.zsh - Zsh shell integration for Cauldron Proactive Intelligence
# Add this to your ~/.zshrc:
#   source ~/.config/cauldron/integrations/proactive.zsh

# Ensure Cauldron is initialized
if [[ -z "$CAULDRON_DATABASE" ]]; then
    echo "Warning: Cauldron not initialized. Run 'cauldron init' first." >&2
    return 1
fi

# Track command start time
__cauldron_preexec() {
    __CAULDRON_CMD_START_TIME=$(date +%s%3N)
    __CAULDRON_LAST_CMD="$1"
}

# Monitor command completion
__cauldron_postexec() {
    local exit_code=$?

    # Skip if proactive intelligence is disabled
    local enabled=$(sqlite3 "$CAULDRON_DATABASE" "SELECT preference_value FROM user_preferences WHERE preference_key = 'enable_proactive_suggestions' AND project_path IS NULL;" 2>/dev/null)
    if [[ "$enabled" != "true" ]]; then
        return 0
    fi

    local cmd="$__CAULDRON_LAST_CMD"

    # Calculate duration
    local end_time=$(date +%s%3N)
    local duration=$((end_time - __CAULDRON_CMD_START_TIME))

    # Store in database
    local timestamp=$(date +%s)
    local cwd=$(pwd)

    sqlite3 "$CAULDRON_DATABASE" "
        INSERT INTO command_history (session_id, command, exit_code, duration_ms, timestamp, working_directory)
        VALUES ('$CAULDRON_SESSION_ID', '${cmd//\'/\'\'}', $exit_code, $duration, $timestamp, '${cwd//\'/\'\'}');
    " 2>/dev/null

    # Run proactive monitors in background
    if [[ $exit_code -ne 0 ]]; then
        # Error watcher
        (fish -c "__proactive_error_watcher '$cmd' $exit_code $duration" 2>/dev/null &)
    fi

    # Process monitor for long-running commands (> 60 seconds)
    if [[ $duration -gt 60000 ]]; then
        (fish -c "__proactive_process_monitor '$cmd' $duration $exit_code" 2>/dev/null &)
    fi

    return 0
}

# Set up hooks
autoload -Uz add-zsh-hook
add-zsh-hook preexec __cauldron_preexec
add-zsh-hook precmd __cauldron_postexec

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

        patterns)
            echo "Detected Patterns:"
            echo "=================="
            sqlite3 "$CAULDRON_DATABASE" "
                SELECT commands, frequency
                FROM command_patterns
                WHERE dismissed = 0
                ORDER BY frequency DESC
                LIMIT 10;
            " 2>/dev/null
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
            echo "  patterns      - Show detected patterns"
            echo "  help          - Show this help message"
            ;;
    esac
}

# Auto-complete for proactive command
_proactive_completions() {
    local -a commands
    commands=(
        'on:Enable proactive intelligence'
        'enable:Enable proactive intelligence'
        'off:Disable proactive intelligence'
        'disable:Disable proactive intelligence'
        'status:Show current status'
        'alerts:Show pending alerts'
        'clear:Dismiss all alerts'
        'patterns:Show detected patterns'
        'help:Show help message'
    )
    _describe 'proactive commands' commands
}

compdef _proactive_completions proactive
