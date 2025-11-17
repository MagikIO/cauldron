#!/usr/bin/env fish

function __init_memory -d "Initialize the familiar memory system in the database"
    # Check if CAULDRON_DATABASE is set
    if not set -q CAULDRON_DATABASE
        echo "Error: CAULDRON_DATABASE environment variable is not set"
        return 1
    end

    # Check if sqlite3 is available
    if not command -q sqlite3
        echo "Error: sqlite3 is not installed"
        return 1
    end

    # Check if the database file exists
    if not test -f $CAULDRON_DATABASE
        echo "Error: Database file does not exist at $CAULDRON_DATABASE"
        return 1
    end

    # Check if the memory schema file exists
    set schema_file "$CAULDRON_PATH/data/memory_schema.sql"
    if not test -f $schema_file
        echo "Error: Memory schema file not found at $schema_file"
        return 1
    end

    # Apply the memory schema to the database
    echo "Initializing familiar memory system..."

    if sqlite3 $CAULDRON_DATABASE < $schema_file
        echo "✓ Memory system initialized successfully"

        # Initialize the current session
        __init_session

        return 0
    else
        echo "✗ Failed to initialize memory system"
        return 1
    end
end
