#!/usr/bin/env fish

#####################
##### VARIABLES #####
#####################
set -Ux CAULDRON_PATH $HOME/.config/cauldron
set CAULDRON_SETUP_PATH (dirname (status -f))
# functions are up a directory from set up path in functions fodler
set -Ux CAULDRON_LOCAL_FUNCTIONS (dirname $CAULDRON_SETUP_PATH)/functions

# Prep the environment for the installation
function cauldron_plating
    set -gx CAULDRON_DEPENDENCIES $CAULDRON_PATH/dependencies.json

    # Check if the cauldron dependencies file exists
    if test -f $CAULDRON_DEPENDENCIES
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
        touch $CAULDRON_PATH/config/cauldron.json
    end

    # Create the log files
    if not test -f $CAULDRON_PATH/logs/cauldron.log
        touch $CAULDRON_PATH/logs/cauldron.log
    end

    # Create the data files
    if not test -f $CAULDRON_PATH/data/cauldron.db
        touch $CAULDRON_PATH/data/cauldron.db
    end

    # Copy the local functions
    cpfunc ../functions -d

    # Copy the dependencies file
    cp $CAULDRON_SETUP_PATH/dependencies.json $CAULDRON_DEPENDENCIES

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

cauldron_plating
cauldron_mise_en_place
return 0
