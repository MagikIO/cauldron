#!/usr/bin/env fish

#####################
##### VARIABLES #####
#####################
set -Ux CAULDRON_PATH $HOME/.config/cauldron
set CAULDRON_SETUP_PATH (dirname (status -f))
# functions are up a directory from set up path in functions fodler
set CAULDRON_LOCAL_FUNCTIONS (dirname $CAULDRON_SETUP_PATH)/functions
set CAULDRON_LOCAL_BIN_FNs ./bin

# Prep the environment for the installation
function cauldron_plating
    set -gx CAULDRON_DEPENDENCIES $CAULDRON_PATH/dependencies.json

    # Check if the cauldron dependencies file exists and if the pallete.json exists
    if test -f $CAULDRON_DEPENDENCIES -a -f $CAULDRON_PATH/config/palettes.json
        # And if so, we should quit if they share the same version
        set INSTALLED_VERSION (jq -r '.version' $CAULDRON_DEPENDENCIES)
        set LOCAL_VERSION (jq -r '.version' $CAULDRON_SETUP_PATH/dependencies.json)

        if test $INSTALLED_VERSION = $LOCAL_VERSION
            printf "Cauldron's files are up to date. \nChecking if dependencies need updated..\n\n"
            return 0
        end
    end

    # Create the directory structure
    mkdir -p $CAULDRON_PATH
    mkdir -p $CAULDRON_PATH/bin
    mkdir -p $CAULDRON_PATH/commands
    mkdir -p $CAULDRON_PATH/config
    mkdir -p $CAULDRON_PATH/data
    mkdir -p $CAULDRON_PATH/logs
    mkdir -p $CAULDRON_PATH/scripts
    mkdir -p $CAULDRON_PATH/tmp
    mkdir -p $CAULDRON_PATH/tools

    # Create the configuration files
    if not test -f $CAULDRON_PATH/config/cauldron.json
        cp $CAULDRON_SETUP_PATH/cauldron.json $CAULDRON_PATH/config/cauldron.json
    end

    # If they dont have `palettes.json` yet move it over
    if not test -f $CAULDRON_PATH/config/palettes.json
        cp $CAULDRON_SETUP_PATH/palettes.json $CAULDRON_PATH/config/palettes.json
    end

    # Create the log files
    if not test -f $CAULDRON_PATH/logs/cauldron.log
        touch $CAULDRON_PATH/logs/cauldron.log
    end

    # Create the data files
    if not test -f $CAULDRON_PATH/data/cauldron.db
        touch $CAULDRON_PATH/data/cauldron.db
    end

    # Copy the dependencies file
    cp $CAULDRON_SETUP_PATH/dependencies.json $CAULDRON_DEPENDENCIES

    # Loop through each function in the bin folder and copy it over
    for file in (ls $CAULDRON_LOCAL_BIN_FNs)
        cp $CAULDRON_LOCAL_BIN_FNs/$file $CAULDRON_PATH/bin/$file
    end


    return 0
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
    set -l APT_DEPENDENCIES (jq -r '.apt[]' $CAULDRON_SETUP_PATH/dependencies.json)
    set -l BREW_DEPENDENCIES (jq -r '.brew[]' $CAULDRON_SETUP_PATH/dependencies.json)
    set -l SNAP_DEPENDENCIES (jq -r '.snap[]' $CAULDRON_SETUP_PATH/dependencies.json)

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


# We have to patch their version of `installs` with our version
cpfunc ./functions/ -d

cauldron_plating
cauldron_mise_en_place
return 0
