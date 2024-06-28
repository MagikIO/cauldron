#!/usr/bin/env fish

function update_repo
      # Version Number
    set -l func_version "1.3.0"
    # Flag options
    set -l options v/version h/help
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

    # This script is designed to be run whenever VScode is opened
    # Check if aquarium is installed
    install_aquarium

    # Make sure we know their preferred node packman
    choose_packman -s

    # If asdf is their preferred version manager, we need to make sure it's installed and set the node version
    if test $cauldron_packman_pref = "asdf"
        # First we need to see if they have asdf installed
        if not type -q asdf
            install_asdf
        end
        # Then we need to set the node version
        asdf_update_node
    end

    # If they prefer nvm
    if test $cauldron_packman_pref = nvm
        # We need to set the node version
        nvm_update_node
    end

    print_separator "⬆️ Updating Branch ⬆️"
    git fetch

    print_separator "🌳 Choose what branch you'd like to work on 🌳"
    git visual-checkout
    git pull

    print_separator "✂️ Trimming unneeded branches ✂️"
    git gone

    print_separator "🆙 Updating your system 🆙"
    sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoclean

    # Update Homebrew
    print_separator "⚗️ Updating Homebrew ⚗️"
    brew update && brew upgrade && brew cleanup && brew doctor

    print_separator "🧶 Rolling up most recent ball of yarn 🧶"
    yarn && yarn up

    print_separator "🧶 Upgrading dependencies 🧶"
    yarn upgrade-interactive

    return 0
end
