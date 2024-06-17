#!/usr/bin/env fish

#####################
##### VARIABLES #####
#####################
if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.config/cauldron
end

# List of folders with functions
set -g CAULDRON_LOCAL_DIRS bin alias config familiar functions text UI

# First we need to make sure we have cpfunc installed
if not command -q cpfunc
    cp ./functions/cpfunc.fish ~/.config/fish/functions/cpfunc.fish
    chmod +x ~/.config/fish/functions/cpfunc.fish
end

# We have to patch their version of `installs` with our version
cpfunc ./functions/ -d

for dir in $CAULDRON_LOCAL_DIRS
    if not test -d $CAULDRON_PATH/$dir
        mkdir -p $CAULDRON_PATH/$dir
    end

    cpfunc ./$dir -d
end

# Create the log files
if not test -f $CAULDRON_PATH/logs/cauldron.log
    touch ./logs/cauldron.log
end

# Move over the palettes and cauldron.
mkdir -p $CAULDRON_PATH/user
cp ./setup/palettes.json $CAULDRON_PATH/user/palettes.json
cp ./setup/cauldron.db $CAULDRON_PATH/user/cauldron.db

# If pipx not installed 
if not command -q pipx
    sudo apt install pipx
    pipx ensurepath
    register-python-argcomplete --shell fish pipx >~/.config/fish/completions/pipx.fish
    pipx install terminaltexteffects
end

if not command -q gum
    brew install gum
end


function cauldron_mise_en_place
    # Now we parse the local json file (dependencies.json) and install the dependencies
    # This file will look like:
    # {
    #    "version": "1.0.0",
    #    "apt": ["cowsay", "cowthink", "python3-pip", "jp2a", "linuxlogo", "fortune", "pv", "cbonsai"],
    #    "brew": ["glow"],
    #    "snap": [
    #      "lolcat-c"
    #    ],
    # }
    set -l APT_DEPENDENCIES (jq -r '.apt[]' ./setup/dependencies.json)
    set -l BREW_DEPENDENCIES (jq -r '.brew[]' ./setup/dependencies.json)
    set -l SNAP_DEPENDENCIES (jq -r '.snap[]' ./setup/dependencies.json)

    # Install the dependencies
    echo -e (badge green 'APT') (underline 'Installing')": $APT_DEPENDENCIES \n"
    installs $APT_DEPENDENCIES

    echo -e \n(badge blue 'BREW') (underline 'Installing')": $BREW_DEPENDENCIES \n"
    installs -b $BREW_DEPENDENCIES

    echo -e (badge yellow 'SNAP') (underline 'Installing')": $SNAP_DEPENDENCIES \n"
    installs -s $SNAP_DEPENDENCIES
    printf "Dependencies installed/updated successfully \n"

    return 0
end

cauldron_mise_en_place
return 0
