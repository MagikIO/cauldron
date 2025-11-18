#!/usr/bin/env fish
# __proactive_pattern_detector.fish v1.0.0
# Detects repeated command patterns and suggests automation

function __proactive_pattern_detector --description "Detect repeated command patterns and suggest automation"
    if not test -f "$CAULDRON_DATABASE"
        return 0
    end

    # Get preferences
    set -l min_frequency (__get_preference "proactive.pattern_detector.min_frequency" "3")
    set -l lookback_commands (__get_preference "proactive.pattern_detector.lookback_commands" "100")

    # Analyze recent command sequences
    __detect_command_sequences $min_frequency $lookback_commands

    # Analyze repeated individual commands
    __detect_repeated_commands $min_frequency $lookback_commands

    # Analyze command chains (commands run together)
    __detect_command_chains $min_frequency $lookback_commands

    return 0
end

function __detect_command_sequences --argument-names min_freq lookback
    # Detect sequences like: git status, git add ., git commit
    # Look for patterns of 2-4 commands in sequence

    # Get recent command history
    set -l commands (sqlite3 "$CAULDRON_DATABASE" "
        SELECT command FROM command_history
        WHERE session_id = '$CAULDRON_SESSION_ID'
        ORDER BY timestamp DESC
        LIMIT $lookback;
    " 2>/dev/null)

    if test (count $commands) -lt 3
        return 0
    end

    # Look for 3-command sequences
    set -l sequences
    for i in (seq 1 (math "(count $commands) - 2"))
        set -l idx1 $i
        set -l idx2 (math "$i + 1")
        set -l idx3 (math "$i + 2")

        set -l cmd1 $commands[$idx1]
        set -l cmd2 $commands[$idx2]
        set -l cmd3 $commands[$idx3]

        set -l sequence "$cmd1 && $cmd2 && $cmd3"
        set -l sequence_hash (echo -n "$sequence" | md5sum | cut -d' ' -f1)

        # Check if this pattern exists
        set -l existing (sqlite3 "$CAULDRON_DATABASE" "
            SELECT frequency FROM command_patterns WHERE pattern_hash = '$sequence_hash';
        " 2>/dev/null)

        if test -n "$existing"
            # Increment frequency
            set -l new_freq (math "$existing + 1")
            sqlite3 "$CAULDRON_DATABASE" "
                UPDATE command_patterns
                SET frequency = $new_freq, last_seen = strftime('%s', 'now')
                WHERE pattern_hash = '$sequence_hash';
            " 2>/dev/null

            # Alert if hit threshold
            if test $new_freq -eq $min_freq
                __suggest_sequence_automation "$cmd1" "$cmd2" "$cmd3" $new_freq
            end
        else
            # Create new pattern
            set -l safe_sequence (string replace -a "'" "''" -- "$sequence")
            sqlite3 "$CAULDRON_DATABASE" "
                INSERT INTO command_patterns (pattern_hash, commands, frequency, first_seen, last_seen, session_id)
                VALUES ('$sequence_hash', '$safe_sequence', 1, strftime('%s', 'now'), strftime('%s', 'now'), '$CAULDRON_SESSION_ID');
            " 2>/dev/null
        end
    end

    return 0
end

function __detect_repeated_commands --argument-names min_freq lookback
    # Detect frequently repeated individual commands

    set -l repeated (sqlite3 "$CAULDRON_DATABASE" "
        SELECT command, COUNT(*) as count
        FROM command_history
        WHERE session_id = '$CAULDRON_SESSION_ID'
        GROUP BY command
        HAVING count >= $min_freq
        ORDER BY count DESC
        LIMIT 5;
    " 2>/dev/null)

    if test -z "$repeated"
        return 0
    end

    # Parse results and suggest aliases
    echo $repeated | while read -l line
        if test -z "$line"
            continue
        end

        # Parse command and count
        set -l parts (string split '|' -- "$line")
        if test (count $parts) -lt 2
            continue
        end

        set -l cmd $parts[1]
        set -l count $parts[2]

        # Skip very short/simple commands
        if test (string length "$cmd") -lt 5
            continue
        end

        # Check if we've already suggested this
        set -l cmd_hash (echo -n "$cmd" | md5sum | cut -d' ' -f1)
        set -l already_suggested (sqlite3 "$CAULDRON_DATABASE" "
            SELECT dismissed FROM command_patterns
            WHERE pattern_hash = '$cmd_hash' AND dismissed = 1;
        " 2>/dev/null)

        if test -n "$already_suggested"
            continue
        end

        # Suggest alias
        __suggest_alias "$cmd" $count
    end

    return 0
end

function __detect_command_chains --argument-names min_freq lookback
    # Detect commands that are always run together (within 10 seconds)

    # Get commands with timestamps
    set -l chain_candidates (sqlite3 "$CAULDRON_DATABASE" "
        SELECT c1.command, c2.command, COUNT(*) as frequency
        FROM command_history c1
        JOIN command_history c2 ON c2.timestamp - c1.timestamp BETWEEN 1 AND 10
            AND c2.session_id = c1.session_id
        WHERE c1.session_id = '$CAULDRON_SESSION_ID'
        GROUP BY c1.command, c2.command
        HAVING frequency >= $min_freq
        ORDER BY frequency DESC
        LIMIT 3;
    " 2>/dev/null)

    if test -z "$chain_candidates"
        return 0
    end

    echo $chain_candidates | while read -l line
        if test -z "$line"
            continue
        end

        set -l parts (string split '|' -- "$line")
        if test (count $parts) -lt 3
            continue
        end

        set -l cmd1 $parts[1]
        set -l cmd2 $parts[2]
        set -l freq $parts[3]

        __suggest_chain_automation "$cmd1" "$cmd2" $freq
    end

    return 0
end

function __suggest_sequence_automation --argument-names cmd1 cmd2 cmd3 frequency
    set -l suggestion "Create a function or alias for this sequence?"

    # Generate function name suggestion
    set -l func_name (__generate_function_name "$cmd1" "$cmd2" "$cmd3")

    set -l automation "function $func_name\n    $cmd1\n    and $cmd2\n    and $cmd3\nend"

    # Create alert
    set -l timestamp (date +%s)
    set -l message "Detected repeated sequence ($frequency times):\n   1. $cmd1\n   2. $cmd2\n   3. $cmd3"

    set -l safe_message (string replace -a "'" "''" -- "$message")
    set -l safe_suggestion (string replace -a "'" "''" -- "$suggestion\n\nSuggested function:\n$automation")

    sqlite3 "$CAULDRON_DATABASE" "
        INSERT INTO proactive_alerts (alert_type, priority, message, suggestion, triggered_at, session_id)
        VALUES ('pattern', 'low', '$safe_message', '$safe_suggestion', $timestamp, '$CAULDRON_SESSION_ID');
    " 2>/dev/null

    # Notify user
    familiar "I noticed you repeat this sequence:\n   $cmd1\n   $cmd2\n   $cmd3\n\n   Want me to create a function '$func_name'?" --paranoid 2>/dev/null

    return 0
end

function __suggest_alias --argument-names command frequency
    # Suggest an alias for a frequently used command

    # Generate alias name
    set -l alias_name (__generate_alias_name "$command")

    set -l message "You've run this command $frequency times: $command"
    set -l suggestion "Create an alias:\n   alias $alias_name='$command'"

    # Store alert
    set -l timestamp (date +%s)
    set -l safe_message (string replace -a "'" "''" -- "$message")
    set -l safe_suggestion (string replace -a "'" "''" -- "$suggestion")

    sqlite3 "$CAULDRON_DATABASE" "
        INSERT INTO proactive_alerts (alert_type, priority, message, suggestion, triggered_at, session_id)
        VALUES ('pattern', 'low', '$safe_message', '$safe_suggestion', $timestamp, '$CAULDRON_SESSION_ID');
    " 2>/dev/null

    return 0
end

function __suggest_chain_automation --argument-names cmd1 cmd2 frequency
    set -l message "Commands often run together ($frequency times):\n   $cmd1\n   $cmd2"
    set -l suggestion "Consider chaining: $cmd1 && $cmd2"

    # Store alert
    set -l timestamp (date +%s)
    set -l safe_message (string replace -a "'" "''" -- "$message")
    set -l safe_suggestion (string replace -a "'" "''" -- "$suggestion")

    sqlite3 "$CAULDRON_DATABASE" "
        INSERT INTO proactive_alerts (alert_type, priority, message, suggestion, triggered_at, session_id)
        VALUES ('pattern', 'low', '$safe_message', '$safe_suggestion', $timestamp, '$CAULDRON_SESSION_ID');
    " 2>/dev/null

    return 0
end

function __generate_function_name --argument-names cmd1 cmd2 cmd3
    # Try to generate a meaningful name from the commands

    # Git-specific patterns
    if string match -q 'git status*' -- "$cmd1"; and string match -q 'git add*' -- "$cmd2"; and string match -q 'git commit*' -- "$cmd3"
        echo "git_quick_commit"
        return
    end

    # Build patterns
    if string match -q '*build*' -- "$cmd1"; or string match -q '*build*' -- "$cmd2"
        echo "build_and_test"
        return
    end

    # Generic name
    echo "quick_workflow"
end

function __generate_alias_name --argument-names command
    # Generate a short alias name from the command

    # Git commands
    if string match -q 'git status' -- "$command"
        echo "gs"
    else if string match -q 'git log*' -- "$command"
        echo "gl"
    else if string match -q 'git diff*' -- "$command"
        echo "gd"
    else if string match -q 'docker ps*' -- "$command"
        echo "dps"
    else if string match -q 'npm run*' -- "$command"
        set -l script (string replace 'npm run ' '' -- "$command")
        echo "nr$script"
    else
        # Generic: take first letter of each word
        set -l words (string split ' ' -- "$command")
        set -l alias_chars
        for word in $words
            set -a alias_chars (string sub -l 1 -- "$word")
        end
        echo (string join '' $alias_chars)
    end
end
