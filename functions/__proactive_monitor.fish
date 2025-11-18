#!/usr/bin/env fish
# __proactive_monitor.fish v1.0.0
# Core proactive intelligence monitoring function
# Called after each command execution to provide intelligent assistance

function __proactive_monitor --description "Monitor commands and provide proactive assistance"
    # Skip if not initialized or if disabled globally
    if not set -q CAULDRON_SESSION_ID
        return 0
    end

    # Get the last command executed
    set -l last_command (history --max=1 2>/dev/null | string trim)
    if test -z "$last_command"
        return 0
    end

    # Get command exit status and timing
    set -l exit_code $status
    set -l cmd_duration $CMD_DURATION

    # Convert microseconds to milliseconds
    if test -n "$cmd_duration"
        set cmd_duration (math "floor($cmd_duration / 1000)")
    else
        set cmd_duration 0
    end

    # Get current timestamp
    set -l timestamp (date +%s)

    # Get current working directory
    set -l cwd (pwd)

    # Store command in history (even if successful)
    __proactive_store_command "$last_command" $exit_code $cmd_duration $timestamp "$cwd"

    # Check preferences to see which monitors are enabled
    set -l error_watcher_enabled (__get_preference "proactive.error_watcher.enabled" "true")
    set -l git_guardian_enabled (__get_preference "proactive.git_guardian.enabled" "true")
    set -l process_monitor_enabled (__get_preference "proactive.process_monitor.enabled" "true")
    set -l pattern_detector_enabled (__get_preference "proactive.pattern_detector.enabled" "true")

    # Track command count for periodic checks
    if not set -q __CAULDRON_CMD_COUNT
        set -g __CAULDRON_CMD_COUNT 0
    end
    set -g __CAULDRON_CMD_COUNT (math "$__CAULDRON_CMD_COUNT + 1")

    # 1. Error Watcher - Check every command failure
    if test "$error_watcher_enabled" = "true" -a $exit_code -ne 0
        __proactive_error_watcher "$last_command" $exit_code $cmd_duration &
    end

    # 2. Git Guardian - Check every N commands
    set -l git_check_interval (__get_preference "proactive.git_guardian.check_interval" "10")
    if test "$git_guardian_enabled" = "true"
        if test (math "$__CAULDRON_CMD_COUNT % $git_check_interval") -eq 0
            __proactive_git_guardian &
        end
    end

    # 3. Process Monitor - Check if command was long-running
    set -l process_threshold (__get_preference "proactive.process_monitor.threshold_ms" "60000")
    if test "$process_monitor_enabled" = "true"
        if test $cmd_duration -gt $process_threshold
            __proactive_process_monitor "$last_command" $cmd_duration $exit_code &
        end
    end

    # 4. Pattern Detector - Check every N commands
    set -l pattern_check_interval (__get_preference "proactive.pattern_detector.check_interval" "20")
    if test "$pattern_detector_enabled" = "true"
        if test (math "$__CAULDRON_CMD_COUNT % $pattern_check_interval") -eq 0
            __proactive_pattern_detector &
        end
    end

    return 0
end

function __proactive_store_command --description "Store command in history database" --argument-names cmd exit_code duration timestamp cwd
    # Skip if database not available
    if not test -f "$CAULDRON_DATABASE"
        return 0
    end

    # Sanitize command for SQL (escape single quotes)
    set -l safe_cmd (string replace -a "'" "''" -- "$cmd")
    set -l safe_cwd (string replace -a "'" "''" -- "$cwd")

    # Store in database (truncate stderr/stdout samples to 1000 chars)
    sqlite3 "$CAULDRON_DATABASE" "
        INSERT INTO command_history (session_id, command, exit_code, duration_ms, timestamp, working_directory)
        VALUES ('$CAULDRON_SESSION_ID', '$safe_cmd', $exit_code, $duration, $timestamp, '$safe_cwd');
    " 2>/dev/null

    return 0
end
