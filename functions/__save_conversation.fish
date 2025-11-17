#!/usr/bin/env fish

function __save_conversation -d "Save a conversation to the database" -a query response command_type
    # Check dependencies
    if not set -q CAULDRON_DATABASE
        return 1
    end

    if not command -q sqlite3
        return 1
    end

    # Ensure we have a session ID
    if not set -q CAULDRON_SESSION_ID
        __init_session
    end

    # Set defaults
    if test -z "$command_type"
        set command_type "ask"
    end

    # Gather context
    set -l context_snapshot (__gather_context)

    # Escape single quotes in query and response for SQL
    set query (string replace -a "'" "''" $query)
    set response (string replace -a "'" "''" $response)
    set context_snapshot (string replace -a "'" "''" $context_snapshot)

    # Insert conversation into database
    sqlite3 $CAULDRON_DATABASE "
        INSERT INTO conversation_history (session_id, timestamp, query, response, context_snapshot, command_type, success)
        VALUES ('$CAULDRON_SESSION_ID', strftime('%s', 'now'), '$query', '$response', '$context_snapshot', '$command_type', 1);
    " 2>/dev/null

    if test $status -eq 0
        return 0
    else
        return 1
    end
end
