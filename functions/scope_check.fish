#!/usr/bin/env fish

function scope_check
    # Get the variable name from the command line arguments
    set varname $argv[1]

    # Check if the variable is universal
    if set -qU $varname
        echo "$varname is a universal variable"
        return 0
    end

    # Check if the variable is global
    if set -qg $varname
        echo "$varname is a global variable"
        return 0
    end

    # Check if the variable is local
    if set -ql $varname
        echo "$varname is a local variable"
        return 0
    end

    # Check if the variable is a function
    if functions -q $varname
        echo "$varname is a function"
        return 0
    end

    # Check if the variable is an environment variable
    if set -q $varname
        echo "$varname is an environment variable"
        return 0
    end

    # Check if the variable is a command
    if which $varname
        echo "$varname is a command"
        return 0
    end

    echo "No scope found for $varname"
    return 0
end
