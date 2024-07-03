#!/usr/bin/env fish

function spinner --description 'Show a spinner while a command is running' -a message -a command
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help V/verbose
    argparse -n spinner $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # If they asked for help, show it
    if set -q _flag_help
        echo "Usage: spinner [-v|--version] [-h|--help] [-v|--verbose] <message>"
        return 0
    end


    gum spin --spinner moon --title $message -- $command
end
