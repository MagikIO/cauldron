#!/usr/bin/env fish
# proactive.fish - Fish shell integration for Cauldron Proactive Intelligence
# Add this to your ~/.config/fish/config.fish:
#   source ~/.config/cauldron/integrations/proactive.fish

# Ensure Cauldron is initialized
if not set -q CAULDRON_DATABASE
    echo "Warning: Cauldron not initialized. Run 'cauldron init' first." >&2
    exit 1
end

# Hook into fish command completion events
function __cauldron_command_postexec --on-event fish_postexec
    # Capture command status before any other operations
    set -l cmd_status $status

    # Only run if proactive intelligence is enabled
    set -l enabled (__get_preference "enable_proactive_suggestions" "false" 2>/dev/null)
    if test "$enabled" != "true"
        return 0
    end

    # Call the main proactive monitor with the captured status
    __proactive_monitor $cmd_status 2>/dev/null &

    # Don't let the monitor affect the actual command status
    return $cmd_status
end

function __cauldron_command_preexec --on-event fish_preexec
    # Track when command started (for duration calculation)
    set -g __CAULDRON_CMD_START_TIME (date +%s%3N)
end

# Optional: Provide user-facing commands for controlling proactive intelligence

function proactive --description "Control Cauldron proactive intelligence"
    set -l subcommand $argv[1]

    switch "$subcommand"
        case "on" "enable"
            __enable_proactive

        case "off" "disable"
            __disable_proactive

        case "status"
            __proactive_status

        case "alerts"
            # Show pending alerts
            if test -f "$CAULDRON_DATABASE"
                set -l alerts (sqlite3 "$CAULDRON_DATABASE" "
                    SELECT alert_type, message, suggestion
                    FROM proactive_alerts
                    WHERE dismissed_at IS NULL
                    ORDER BY priority DESC, triggered_at DESC
                    LIMIT 10;
                " 2>/dev/null)

                if test -n "$alerts"
                    echo "Pending Alerts:"
                    echo "==============="
                    echo $alerts
                else
                    echo "No pending alerts."
                end
            end

        case "clear"
            # Dismiss all alerts
            if test -f "$CAULDRON_DATABASE"
                sqlite3 "$CAULDRON_DATABASE" "
                    UPDATE proactive_alerts
                    SET dismissed_at = strftime('%s', 'now')
                    WHERE dismissed_at IS NULL;
                " 2>/dev/null
                echo "All alerts dismissed."
            end

        case "patterns"
            # Show detected patterns
            if test -f "$CAULDRON_DATABASE"
                set -l patterns (sqlite3 "$CAULDRON_DATABASE" "
                    SELECT commands, frequency
                    FROM command_patterns
                    WHERE dismissed = 0
                    ORDER BY frequency DESC
                    LIMIT 10;
                " 2>/dev/null)

                if test -n "$patterns"
                    echo "Detected Patterns:"
                    echo "=================="
                    echo $patterns
                else
                    echo "No patterns detected yet."
                end
            end

        case "help" "*"
            echo "Usage: proactive [command]"
            echo ""
            echo "Commands:"
            echo "  on, enable    - Enable proactive intelligence"
            echo "  off, disable  - Disable proactive intelligence"
            echo "  status        - Show current status and statistics"
            echo "  alerts        - Show pending alerts"
            echo "  clear         - Dismiss all alerts"
            echo "  patterns      - Show detected command patterns"
            echo "  help          - Show this help message"
    end
end

# Auto-enable if preference is set
if test (__get_preference "enable_proactive_suggestions" "false" 2>/dev/null) = "true"
    # Proactive intelligence is enabled
    # The event handlers are already set up above
end
