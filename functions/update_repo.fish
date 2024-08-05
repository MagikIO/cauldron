#!/usr/bin/env fish

function update_repo
    # Version Number
    set -l func_version "1.5.0"
    set cauldron_category Functions
    # Flag options
    set -l options v/version h/help z/cauldron
    argparse -n update_repo $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help just return it
    if set -q _flag_help
        echo "Usage: update_repo"
        echo "Version: $func_version"
        echo "Update the repository and dependencies"
        echo
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        return
    end

    # If they asked for the cauldron, just return it
    if set -q _flag_cauldron
        echo $cauldron_category
        return
    end

    # Create a log file to pipe the output to
    mkdir -p $CAULDRON_PATH/logs
    set log_file $CAULDRON_PATH/logs/repo_update.txt
    touch $log_file

    # Reset the log file and add a date stamp
    print_separator " Update Repo Script Results " >>$log_file
    echo "Run on "(date) >>$log_file

    # Get sudo so we can update
    print_separator " Aquarium "
    echo (badge blue "Aquarium") "Updating Aquarium" >>$log_file
    sudo -v

    # This script is designed to be run whenever VScode is opened
    # Check if aquarium is installed
    __cauldron_aquarium_update_step
    cat $CAULDRON_PATH/logs/aqua_update.txt >>$log_file
    echo >>$log_file

    print_separator " ASDF "
    echo (badge blue "ASDF") "Updating ASDF" >>$log_file

    # Make sure we know their preferred node packman
    choose_packman -s

    # Update asdf
    if command -q asdf
        __cauldron_asdf_update_step
    end

    cat $CAULDRON_PATH/logs/asdf_update.txt >>$log_file
    echo >>$log_file

    print_separator " Git "
    echo (badge purple "Git") "Updating the repository" >>$log_file
    git fetch --all --prune --tags --quiet >>$log_file
    git visual-checkout >>$log_file
    echo (badge purple "Git") "Moved to branch '"(bold (git branch --show-current))"'"
    git pull --rebase --autostash --quiet >>$log_file
    echo (badge purple "Git") "Grabbed most recent changes from remote"
    git gone
    echo (badge purple "Git") "Trimmed unneeded branches for you"
    echo >>$log_file

    print_separator " System "
    echo (badge yellow "System") "Updating the system" >>$log_file
    gum spin --spinner moon --title "Updating System..." -- "sudo apt update --fix-missing >> $log_file && sudo apt -y upgrade >> $log_file"
    sudo apt -y autoclean >>$log_file
    echo (badge green "Success") "Finished upgrading the system" >>$log_file
    echo >>$log_file

    print_separator " Homebrew "
    echo (badge black "Homebrew") "Updating Homebrew" >>$log_file
    gum spin --spinner moon --title "Updating Homebrew..." -- "brew update >> $log_file && brew upgrade >> $log_file && brew cleanup >> $log_file && brew doctor >> $log_file"
    echo (badge green "Success") "Finished upgrading Homebrew" >>$log_file

    print_separator " Yarn "
    echo (badge green "Yarn") "Updating Yarn and local dependencies" >>$log_file
    # Update Yarn and local dependencies
    gum spin --spinner moon --title "Installing the most recent version of the your modules from remote..." -- fish -c "yarn install >> $log_file"
    yarn upgrade-interactive

    gum pager <$log_file

    return 0
end
