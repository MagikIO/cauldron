#!/usr/bin/env fish

function recall -d "Recall conversation history with your familiar"
    # Version Number
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help l/limit= a/all f/format= s/search=
    argparse -n recall $options -- $argv

    if set -q _flag_version
        echo $func_version
        return
    end

    if set -q _flag_help
        echo "Usage: recall [OPTIONS]"
        echo "Version: $func_version"
        echo "Recall your conversation history with your familiar"
        echo
        echo "Options:"
        echo "  -v, --version       Show the version number"
        echo "  -h, --help          Show this help message"
        echo "  -l, --limit N       Limit results to N conversations (default: 10)"
        echo "  -a, --all           Show all conversations, not just current session"
        echo "  -f, --format TYPE   Output format: text, json (default: text)"
        echo "  -s, --search TERM   Search for conversations containing TERM"
        echo
        echo "Examples:"
        echo "  recall                    # Show last 10 conversations from this session"
        echo "  recall -l 20              # Show last 20 conversations"
        echo "  recall -a                 # Show conversations from all sessions"
        echo "  recall -s 'typescript'    # Search for conversations about typescript"
        echo "  recall -f json            # Output as JSON"
        return
    end

    # Check dependencies
    if not set -q CAULDRON_DATABASE
        echo "Error: Memory system not initialized. Run '__init_memory' first."
        return 1
    end

    if not command -q sqlite3
        echo "Error: sqlite3 is not installed"
        return 1
    end

    # Set defaults
    set -l limit 10
    if set -q _flag_limit
        set limit $_flag_limit
    end

    set -l scope "session"
    if set -q _flag_all
        set scope "all"
    end

    set -l format "text"
    if set -q _flag_format
        set format $_flag_format
    end

    # Get conversation history
    if set -q _flag_search
        # Search for conversations
        set search_term (string replace -a "'" "''" $_flag_search)

        if test "$format" = "json"
            sqlite3 -json $CAULDRON_DATABASE "
                SELECT
                    id,
                    timestamp,
                    query,
                    response,
                    command_type,
                    datetime(timestamp, 'unixepoch', 'localtime') as formatted_time
                FROM conversation_history
                WHERE query LIKE '%$search_term%' OR response LIKE '%$search_term%'
                ORDER BY timestamp DESC
                LIMIT $limit;
            "
        else
            set results (sqlite3 $CAULDRON_DATABASE "
                SELECT
                    datetime(timestamp, 'unixepoch', 'localtime'),
                    query,
                    substr(response, 1, 100)
                FROM conversation_history
                WHERE query LIKE '%$search_term%' OR response LIKE '%$search_term%'
                ORDER BY timestamp DESC
                LIMIT $limit;
            " 2>/dev/null)

            if test -n "$results"
                echo "Found conversations matching '$_flag_search':"
                echo ""
                echo $results | while read -l line
                    echo $line | awk -F '|' '{printf "[%s]\nQ: %s\nA: %s...\n\n", $1, $2, $3}'
                end
            else
                echo "No conversations found matching '$_flag_search'"
            end
        end
    else
        # Get regular conversation history
        if test "$format" = "json"
            __get_conversation_history $limit $scope
        else
            set results (__get_conversation_history $limit $scope 2>/dev/null)

            if test -n "$results"
                # Parse and display in a readable format
                echo "Recent conversations:"
                echo ""
                echo $results | jq -r '.[] | "[" + .formatted_time + "]\nQ: " + .query + "\nA: " + (.response[:100]) + "...\n"' 2>/dev/null

                if test $status -ne 0
                    # Fallback if jq fails
                    echo $results
                end
            else
                if test "$scope" = "session"
                    echo "No conversation history found for this session."
                else
                    echo "No conversation history found."
                end
            end
        end
    end
end
