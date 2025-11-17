#!/usr/bin/env fish

function __get_conversation_history -d "Retrieve conversation history" -a limit scope
    # Check dependencies
    if not set -q CAULDRON_DATABASE
        return 1
    end

    if not command -q sqlite3
        return 1
    end

    # Set default limit
    if test -z "$limit"
        set limit 10
    end

    # Set scope: 'session' (current session only) or 'all' (all sessions)
    if test -z "$scope"
        set scope "session"
    end

    # Build query based on scope
    if test "$scope" = "session"
        # Get conversation history for current session only
        if not set -q CAULDRON_SESSION_ID
            return 1
        end

        sqlite3 -json $CAULDRON_DATABASE "
            SELECT
                id,
                timestamp,
                query,
                response,
                command_type,
                datetime(timestamp, 'unixepoch', 'localtime') as formatted_time
            FROM conversation_history
            WHERE session_id = '$CAULDRON_SESSION_ID'
            ORDER BY timestamp DESC
            LIMIT $limit;
        "
    else
        # Get conversation history across all sessions
        sqlite3 -json $CAULDRON_DATABASE "
            SELECT
                ch.id,
                ch.timestamp,
                ch.query,
                ch.response,
                ch.command_type,
                ch.session_id,
                s.working_directory,
                datetime(ch.timestamp, 'unixepoch', 'localtime') as formatted_time
            FROM conversation_history ch
            LEFT JOIN sessions s ON ch.session_id = s.session_id
            ORDER BY ch.timestamp DESC
            LIMIT $limit;
        "
    end
end
