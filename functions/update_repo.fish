#!/usr/bin/env fish

function update_repo
    # Version Number
    set -l func_version "1.5.0"
    set cauldron_category "Functions"
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

    # Get sudo so we can update
    sudo -v

    # This script is designed to be run whenever VScode is opened
    # Check if aquarium is installed
    if not functions -q aquarium
      print_center "🐠 Filling Aquarium 🐠"
      # Remove the old aquarium (if it exists)
      if test -d ~/.cache/aquarium
        rm -rf ~/.cache/aquarium
      end

      # Make sure the folder exist
      mkdir -p ~/.cache/aquarium

      # Clone the aquarium repo
      git clone https://github.com/anandamideio/aquarium.git ~/.cache/aquarium

      # Install the aquarium
      pushd ~/.cache/aquarium/bin/
      ./bin/install
      popd
    end

    # Make sure we know their preferred node packman
    choose_packman -s

    # If asdf is their preferred version manager, we need to make sure it's installed and set the node version
    if test $cauldron_packman_pref = "asdf"; or test $cauldron_packman_pref = "none"; or test $cauldron_packman_pref = "asdf_preferred"
        # First we need to see if they have asdf installed
        if not type -q asdf
            install_asdf
        end
        # Then we need to set the node version
        gum spin --spinner moon --title "Updating Node..." -- fish -c asdf_update_node
        gum spin --spinner moon --title "Updating Ruby..." -- fish -c asdf_update_ruby
        gum spin --spinner moon --title "Updating Go..." -- fish -c asdf_update_go
    end

    # If they prefer nvm
    if test $cauldron_packman_pref = nvm
        # We need to set the node version
        gum spin --spinner moon --title "Updating Node..." -- fish -c nvm_update_node
    end

    print_separator "⬆️ Updating Branch ⬆️"
    git fetch

    print_separator "🌳 Choose what branch you'd like to work on 🌳"
    git visual-checkout
    git pull

    print_separator "✂️ Trimming unneeded branches ✂️"
    git gone

    print_separator "🆙 Updating your system 🆙"
    gum spin --spinner moon --title "Updating System..." -- fish -c "sudo apt -y update && sudo apt -y upgrade && sudo apt -y autoclean"

    # Update Homebrew
    print_separator "⚗️ Updating Homebrew ⚗️"
    gum spin --spinner moon --title "Updating System..." -- fish -c "brew update && brew upgrade && brew cleanup && brew doctor"

    print_separator "🧶 Rolling up most recent ball of yarn 🧶"
    gum spin --spinner moon --title "Updating node_modules..." -- fish -c "yarn && yarn up"

    print_separator "🧶 Upgrading dependencies 🧶"
    yarn upgrade-interactive

    return 0
end
