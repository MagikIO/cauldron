#!/usr/bin/env fish
# __proactive_error_watcher.fish v1.0.0
# Monitors command failures and offers intelligent assistance

function __proactive_error_watcher --description "Watch for command errors and offer help" --argument-names command exit_code duration
    # Get preferences
    set -l auto_suggest (__get_preference "proactive.error_watcher.auto_suggest" "false")
    set -l min_delay (__get_preference "proactive.error_watcher.min_delay_ms" "1000")

    # Skip very fast failures (likely intentional tests or checks)
    if test $duration -lt $min_delay
        return 0
    end

    # Skip certain benign commands
    if string match -qr '^(ls|cd|pwd|echo|cat|which|type|test|true|false)' -- "$command"
        return 0
    end

    # Get the last stderr output (if available via fish variables)
    set -l error_context ""

    # Try to get git-specific errors
    if string match -q 'git *' -- "$command"
        set error_context (__analyze_git_error "$command" $exit_code)
    else if string match -q 'npm *' -- "$command"
        set error_context (__analyze_npm_error "$command" $exit_code)
    else if string match -q 'cargo *' -- "$command"
        set error_context (__analyze_cargo_error "$command" $exit_code)
    else
        # Generic error
        set error_context "Exit code: $exit_code"
    end

    # Create alert message
    set -l timestamp (date +%s)
    set -l message "Command failed: $command"
    set -l suggestion ""

    # Generate suggestion based on command type
    if test "$auto_suggest" = "true"
        set suggestion (__generate_error_suggestion "$command" $exit_code)
    end

    # Store alert in database
    __proactive_create_alert "error" "medium" "$message" "$suggestion" $timestamp

    # Show notification to user
    if test -n "$suggestion"
        familiar "I noticed that failed. $suggestion" --paranoid 2>/dev/null
    else
        # Ask if they want help
        set -l response ""
        familiar "I noticed that failed. Want help analyzing the error?" --paranoid 2>/dev/null

        # If user wants help, call ask with the error context
        if test -t 0  # Only if interactive
            read -l -P "🔮 [y/N] > " response
            if string match -qir '^y' -- "$response"
                ask "The command '$command' failed with exit code $exit_code. $error_context. How can I fix this?"
            end
        end
    end

    return 0
end

function __analyze_git_error --argument-names command exit_code
    # Common git errors
    switch $exit_code
        case 1
            echo "Git reported an error. Check your git status and branch."
        case 128
            echo "Git repository not found or not a valid repository."
        case '*'
            echo "Git command failed."
    end
end

function __analyze_npm_error --argument-names command exit_code
    # Common npm errors
    if string match -q '*npm install*' -- "$command"
        echo "Package installation failed. Check your package.json and network connection."
    else if string match -q '*npm test*' -- "$command"
        echo "Tests failed."
    else if string match -q '*npm run*' -- "$command"
        echo "Script execution failed. Check your package.json scripts."
    else
        echo "NPM command failed."
    end
end

function __analyze_cargo_error --argument-names command exit_code
    if string match -q '*cargo build*' -- "$command"
        echo "Build failed. Check compiler errors above."
    else if string match -q '*cargo test*' -- "$command"
        echo "Tests failed."
    else
        echo "Cargo command failed."
    end
end

function __generate_error_suggestion --argument-names command exit_code
    # Generate helpful suggestions based on command
    if string match -q 'git push*' -- "$command"
        echo "Try: git pull --rebase first, or check if you have push permissions."
    else if string match -q 'git commit*' -- "$command"
        echo "Try: git status to see what's staged, or git add to stage changes."
    else if string match -q 'npm install*' -- "$command"
        echo "Try: rm -rf node_modules package-lock.json && npm install, or check your network."
    else if string match -q 'cargo build*' -- "$command"
        echo "Check the compiler errors above. Use 'cargo check' for faster feedback."
    else if string match -q 'make*' -- "$command"
        echo "Check the error above. Try 'make clean' and rebuild."
    else
        echo ""
    end
end

function __proactive_create_alert --argument-names alert_type priority message suggestion timestamp
    if not test -f "$CAULDRON_DATABASE"
        return 0
    end

    # Sanitize for SQL
    set -l safe_message (string replace -a "'" "''" -- "$message")
    set -l safe_suggestion (string replace -a "'" "''" -- "$suggestion")

    # Get last command ID
    set -l cmd_id (sqlite3 "$CAULDRON_DATABASE" "SELECT id FROM command_history WHERE session_id = '$CAULDRON_SESSION_ID' ORDER BY id DESC LIMIT 1;" 2>/dev/null)

    sqlite3 "$CAULDRON_DATABASE" "
        INSERT INTO proactive_alerts (alert_type, priority, message, suggestion, triggered_at, session_id, command_id)
        VALUES ('$alert_type', '$priority', '$safe_message', '$safe_suggestion', $timestamp, '$CAULDRON_SESSION_ID', $cmd_id);
    " 2>/dev/null

    return 0
end
