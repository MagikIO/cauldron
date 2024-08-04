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
    echo (date) >$log_file

    # Get sudo so we can update
    sudo -v

    # This script is designed to be run whenever VScode is opened
    # Check if aquarium is installed
    __cauldron_aquarium_update_step

    # Make sure we know their preferred node packman
    choose_packman -s

    # Update asdf
    if command -q asdf
        __cauldron_asdf_update_step
    end

    git fetch

    print_separator "🌳 Choose what branch you'd like to work on 🌳"
    git visual-checkout
    git pull

    print_separator "✂️ Trimming unneeded branches ✂️"
    git gone

    print_separator "🆙 Updating your system & your brews ⚗️"
    gum spin --spinner moon --title "Updating System..." -- fish -c "$CAULDRON_PATH/update/__cauldron_system_update_step.fish"

    # Update Yarn and local dependencies
    gum spin --spinner moon --title "Updating node_modules..." -- fish -c "yarn && yarn up"

    print_separator "🧶 Upgrading dependencies 🧶"
    yarn upgrade-interactive

    return 0
end
