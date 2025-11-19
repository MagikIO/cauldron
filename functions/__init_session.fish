#!/usr/bin/env fish

function __init_session -d "Initialize a new terminal session in the database"
    # Check dependencies
    if not set -q CAULDRON_DATABASE
        return 1
    end

    if not command -q sqlite3
        return 1
    end

    # Generate a unique session ID (use fish PID + timestamp)
    set -g CAULDRON_SESSION_ID (string join "" (date +%s) "_" $fish_pid)

    # Get current working directory and try to find git root
    set cwd (pwd)
    set project_path $cwd

    # Try to find git root
    if git rev-parse --show-toplevel >/dev/null 2>&1
        set project_path (git rev-parse --show-toplevel 2>/dev/null)
    end

    # Insert session into database
    sqlite3 $CAULDRON_DATABASE "
        INSERT INTO sessions (session_id, started_at, working_directory, project_path, shell_pid)
        VALUES ('$CAULDRON_SESSION_ID', strftime('%s', 'now'), '$cwd', '$project_path', $fish_pid);
    " 2>/dev/null

    # Set up session end handler
    function __end_session_handler --on-event fish_exit
        __end_session
    end

    return 0
end
