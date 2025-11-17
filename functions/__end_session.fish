#!/usr/bin/env fish

function __end_session -d "End the current terminal session in the database"
    # Check if we have a session ID
    if not set -q CAULDRON_SESSION_ID
        return 1
    end

    # Check dependencies
    if not set -q CAULDRON_DATABASE
        return 1
    end

    if not command -q sqlite3
        return 1
    end

    # Update the session end time
    sqlite3 $CAULDRON_DATABASE "
        UPDATE sessions
        SET ended_at = strftime('%s', 'now')
        WHERE session_id = '$CAULDRON_SESSION_ID';
    " 2>/dev/null

    return 0
end
