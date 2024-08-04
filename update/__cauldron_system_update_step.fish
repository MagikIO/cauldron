#!/usr/bin/env fish

function __cauldron_system_update_step
    # version
    set -l func_version "1.0.0"

    # category
    set __cauldron_category Update

    # flag options
    set -l options v/version h/help z/cauldron
    argparse -n __cauldron_system_update_step $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo (bold "System Update") " - v$func_version"
        echo ""
        echo "Update the system and dependencies"
        echo ""
        echo (bold "Options:")
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo "  -z, --cauldron Show the category of the function"
        echo ""
        echo (bold "Usage:")
        echo "__cauldron_system_update_step [OPTIONS]"
        return 0
    end

    # If the cauldron flag is set, then we need to return the Cauldron category
    if set -q _flag_cauldron
        echo $__cauldron_category
        return 0
    end

    # Create a log file to pipe the output to
    mkdir -p $CAULDRON_PATH/logs
    set log_file $CAULDRON_PATH/logs/system_update.txt
    touch $log_file

    # Reset the log file and add a date stamp
    echo (date -u) >$log_file

    echo (badge yellow System) "Updating the system" >>$log_file
    sudo apt update --fix-missing 2>>$log_file
    sudo apt -y upgrade 2>>$log_file
    sudo apt -y autoclean 2>>$log_file

    echo (badge green Success) "Finished upgrading the system" >>$log_file

    echo (badge pink Homebrew) "Updating Homebrew" >>$log_file
    brew update 2>>$log_file
    brew upgrade 2>>$log_file
    brew cleanup 2>>$log_file
    brew doctor 2>>$log_file

    echo (badge green Success) "Finished upgrading Homebrew" >>$log_file

    return 0
end
__cauldron_system_update_step
