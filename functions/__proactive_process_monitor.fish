#!/usr/bin/env fish
# __proactive_process_monitor.fish v1.0.0
# Monitors long-running commands and provides completion notifications

function __proactive_process_monitor --description "Monitor long-running processes" --argument-names command duration exit_code
    # Get preferences
    set -l show_stats (__get_preference "proactive.process_monitor.show_stats" "true")

    # Format duration nicely
    set -l duration_text (__format_duration $duration)

    # Determine status message
    set -l status_text ""
    set -l status_emoji ""

    if test $exit_code -eq 0
        set status_text "completed successfully"
        set status_emoji "✓"
    else
        set status_text "failed"
        set status_emoji "✗"
    end

    # Build message
    set -l message "Long-running command $status_text"
    set -l details "Command: $command\nDuration: $duration_text\nExit code: $exit_code"

    # Generate suggestion based on command type
    set -l suggestion (__generate_process_suggestion "$command" $exit_code $duration)

    # Store alert
    set -l timestamp (date +%s)
    __proactive_create_alert "process" "low" "$message" "$suggestion" $timestamp

    # Show notification
    if test "$show_stats" = "true"
        set -l notify_message "$status_emoji Command completed: $command\n   Duration: $duration_text | Exit code: $exit_code"

        if test -n "$suggestion"
            set notify_message "$notify_message\n   $suggestion"
        end

        familiar "$notify_message" --stoned 2>/dev/null
    else
        familiar "$status_emoji Command $status_text ($duration_text)" --stoned 2>/dev/null
    end

    # Update process statistics
    __update_process_stats "$command" $duration $exit_code

    return 0
end

function __format_duration --description "Format milliseconds to human-readable duration" --argument-names duration_ms
    set -l seconds (math "floor($duration_ms / 1000)")
    set -l minutes (math "floor($seconds / 60)")
    set -l hours (math "floor($minutes / 60)")

    if test $hours -gt 0
        set -l mins (math "$minutes % 60")
        set -l secs (math "$seconds % 60")
        echo "$hours"h "$mins"m "$secs"s
    else if test $minutes -gt 0
        set -l secs (math "$seconds % 60")
        echo "$minutes"m "$secs"s
    else
        echo "$seconds"s
    end
end

function __generate_process_suggestion --argument-names command exit_code duration
    set -l suggestion ""

    # Specific suggestions based on command type
    if string match -q '*build*' -- "$command"
        if test $exit_code -eq 0
            set suggestion "Build successful! Consider running tests next."
        else
            set suggestion "Build failed. Check the error logs above."
        end
    else if string match -q '*test*' -- "$command"
        if test $exit_code -eq 0
            set suggestion "All tests passed! Ready to commit?"
        else
            set suggestion "Some tests failed. Review the failures above."
        end
    else if string match -q '*npm install*' -- "$command"; or string match -q '*yarn install*' -- "$command"
        if test $exit_code -eq 0
            set suggestion "Dependencies installed successfully!"
        else
            set suggestion "Installation failed. Try clearing cache or check your network."
        end
    else if string match -q '*git clone*' -- "$command"
        if test $exit_code -eq 0
            set suggestion "Repository cloned successfully!"
        end
    else if string match -q '*docker*' -- "$command"
        if test $exit_code -eq 0
            set suggestion "Docker operation completed!"
        end
    else
        # Generic message for very long processes
        set -l minutes (math "floor($duration / 60000)")
        if test $minutes -gt 10
            set suggestion "That took a while! Consider optimizing this command or running it in the background."
        end
    end

    echo $suggestion
end

function __update_process_stats --argument-names command duration exit_code
    # Store in database for future pattern analysis
    if not test -f "$CAULDRON_DATABASE"
        return 0
    end

    # Extract base command (first word)
    set -l base_command (string split -m 1 ' ' -- "$command")[1]

    # We could track average durations, success rates, etc.
    # For now, just stored in command_history table

    return 0
end

function __notify_process_complete --description "Show desktop notification for process completion" --argument-names command duration exit_code
    # Optional: Send desktop notification (requires notify-send or terminal-notifier)
    if command -v notify-send >/dev/null 2>&1
        set -l duration_text (__format_duration $duration)
        if test $exit_code -eq 0
            notify-send "🔮 Cauldron" "Command completed: $command ($duration_text)" 2>/dev/null &
        else
            notify-send "🔮 Cauldron" "Command failed: $command ($duration_text)" --urgency=critical 2>/dev/null &
        end
    else if command -v terminal-notifier >/dev/null 2>&1
        # macOS
        set -l duration_text (__format_duration $duration)
        terminal-notifier -title "🔮 Cauldron" -message "Command completed: $command ($duration_text)" 2>/dev/null &
    end

    return 0
end
