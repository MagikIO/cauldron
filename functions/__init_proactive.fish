#!/usr/bin/env fish
# __init_proactive.fish v1.0.0
# Initialize proactive intelligence system

function __init_proactive --description "Initialize proactive intelligence monitoring"
    # Skip if database not available
    if not test -f "$CAULDRON_DATABASE"
        return 0
    end

    # Initialize database schema
    if test -f "$CAULDRON_PATH/data/proactive_schema.sql"
        sqlite3 "$CAULDRON_DATABASE" < "$CAULDRON_PATH/data/proactive_schema.sql" 2>/dev/null
    else if test -f (dirname (status -f))/../data/proactive_schema.sql
        sqlite3 "$CAULDRON_DATABASE" < (dirname (status -f))/../data/proactive_schema.sql 2>/dev/null
    end

    # Check if proactive intelligence is enabled
    set -l enabled (__get_preference "enable_proactive_suggestions" "false")

    if test "$enabled" != "true"
        # Proactive intelligence disabled - skip setup
        return 0
    end

    # Set up Fish event handlers for proactive monitoring
    __setup_proactive_hooks

    # Clean up old alerts (older than 7 days)
    __cleanup_old_alerts

    return 0
end

function __setup_proactive_hooks --description "Set up Fish shell event handlers for proactive monitoring"
    # Hook into fish_postexec event to monitor every command
    # This creates a function that will be called after each command execution

    # Check if already set up
    if functions -q __cauldron_proactive_postexec_handler
        # Already set up, don't duplicate
        return 0
    end

    # Create the postexec handler function
    function __cauldron_proactive_postexec_handler --on-event fish_postexec
        # Call the main proactive monitor
        __proactive_monitor $status 2>/dev/null &
        # Run in background to not slow down the shell
    end

    # Optional: Hook into fish_preexec to track command start times
    # This would allow more precise duration tracking
    if not functions -q __cauldron_proactive_preexec_handler
        function __cauldron_proactive_preexec_handler --on-event fish_preexec
            # Store command start time
            set -g __CAULDRON_CMD_START_TIME (date +%s%3N)
        end
    end

    return 0
end

function __cleanup_old_alerts --description "Clean up old proactive alerts from database"
    if not test -f "$CAULDRON_DATABASE"
        return 0
    end

    # Delete alerts older than 7 days
    set -l seven_days_ago (math (date +%s) - 604800)

    sqlite3 "$CAULDRON_DATABASE" "
        DELETE FROM proactive_alerts
        WHERE triggered_at < $seven_days_ago;
    " 2>/dev/null

    # Clean up old command history (keep last 1000 commands per session)
    sqlite3 "$CAULDRON_DATABASE" "
        DELETE FROM command_history
        WHERE id NOT IN (
            SELECT id FROM command_history
            ORDER BY timestamp DESC
            LIMIT 1000
        );
    " 2>/dev/null

    # Clean up dismissed patterns older than 30 days
    set -l thirty_days_ago (math (date +%s) - 2592000)

    sqlite3 "$CAULDRON_DATABASE" "
        DELETE FROM command_patterns
        WHERE dismissed = 1 AND last_seen < $thirty_days_ago;
    " 2>/dev/null

    return 0
end

function __disable_proactive --description "Disable proactive intelligence"
    # Remove event handlers
    if functions -q __cauldron_proactive_postexec_handler
        functions -e __cauldron_proactive_postexec_handler
    end

    if functions -q __cauldron_proactive_preexec_handler
        functions -e __cauldron_proactive_preexec_handler
    end

    # Update preference
    __save_preference "enable_proactive_suggestions" "false"

    familiar "Proactive intelligence disabled. I'll wait for you to ask." --stoned 2>/dev/null

    return 0
end

function __enable_proactive --description "Enable proactive intelligence"
    # Update preference
    __save_preference "enable_proactive_suggestions" "true"

    # Initialize
    __init_proactive

    familiar "Proactive intelligence enabled! I'll keep an eye on things." --paranoid 2>/dev/null

    return 0
end

function __proactive_status --description "Show proactive intelligence status"
    set -l enabled (__get_preference "enable_proactive_suggestions" "false")

    echo "Proactive Intelligence Status"
    echo "=============================="
    echo ""

    if test "$enabled" = "true"
        echo "Status: ENABLED"
        echo ""
        echo "Active features:"

        # Check each feature
        set -l error_watcher (__get_preference "proactive.error_watcher.enabled" "true")
        if test "$error_watcher" = "true"
            echo "  ✓ Error Watcher - Monitors command failures"
        else
            echo "  ✗ Error Watcher - Disabled"
        end

        set -l git_guardian (__get_preference "proactive.git_guardian.enabled" "true")
        if test "$git_guardian" = "true"
            echo "  ✓ Git Guardian - Watches for uncommitted changes"
        else
            echo "  ✗ Git Guardian - Disabled"
        end

        set -l process_monitor (__get_preference "proactive.process_monitor.enabled" "true")
        if test "$process_monitor" = "true"
            echo "  ✓ Process Monitor - Alerts on long-running commands"
        else
            echo "  ✗ Process Monitor - Disabled"
        end

        set -l pattern_detector (__get_preference "proactive.pattern_detector.enabled" "true")
        if test "$pattern_detector" = "true"
            echo "  ✓ Pattern Detector - Suggests automation"
        else
            echo "  ✗ Pattern Detector - Disabled"
        end

        echo ""
        echo "Recent activity:"

        # Show pending alerts
        if test -f "$CAULDRON_DATABASE"
            set -l pending_count (sqlite3 "$CAULDRON_DATABASE" "SELECT COUNT(*) FROM proactive_alerts WHERE dismissed_at IS NULL;" 2>/dev/null)
            echo "  • $pending_count pending alerts"

            set -l recent_errors (sqlite3 "$CAULDRON_DATABASE" "SELECT COUNT(*) FROM command_history WHERE exit_code != 0 AND timestamp > (strftime('%s', 'now') - 3600);" 2>/dev/null)
            echo "  • $recent_errors errors in last hour"

            set -l patterns (sqlite3 "$CAULDRON_DATABASE" "SELECT COUNT(*) FROM command_patterns WHERE dismissed = 0;" 2>/dev/null)
            echo "  • $patterns detected patterns"
        end
    else
        echo "Status: DISABLED"
        echo ""
        echo "Run '__enable_proactive' to activate."
    end

    return 0
end
