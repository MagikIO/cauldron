#!/usr/bin/env fish

function __cauldron_system_update_step -d 'Update the system using apt'
    # Version Number
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help
    argparse -n __cauldron_system_update_step $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help just return it
    if set -q _flag_help
        echo (bold "__cauldron_system_update_step")
        echo "Version: $func_version"
        echo
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        return 0
    end

    # Update the system
    sudo apt update
    sudo apt upgrade -y

    return 0
end
