#!/usr/bin/env fish

#####################
##### VARIABLES #####
#####################
if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.config/cauldron
end

# Where we are installing from
set CAULDRON_SETUP_PATH (dirname (status -f))

# List of folders with functions
set CAULDRON_LOCAL_DIRS bin alias config familiar functions text ui

# Now we need to install the dependencies
set CAULDRON_DEPENDENCIES $CAULDRON_PATH/setup/dependencies.json
set CAULDRON_BASE_PALETTES $CAULDRON_PATH/setup/palettes.json
set CAULDRON_BASE_DB $CAULDRON_PATH/setup/cauldron.db

# We have to patch their version of `installs` with our version
cpfunc ./functions/ -d

# Prep the environment for the installation

# Check if the sll base files are found
if test -f $CAULDRON_DEPENDENCIES -a -f $CAULDRON_BASE_PALETTES -a -f $CAULDRON_BASE_DB
    # And if so, we should quit if they share the same version
    set INSTALLED_VERSION (jq -r '.version' $CAULDRON_DEPENDENCIES)
    set LOCAL_VERSION (jq -r '.version' $CAULDRON_SETUP_PATH/dependencies.json)

    if test $INSTALLED_VERSION = $LOCAL_VERSION
        printf "Cauldron's files are up to date. \nChecking if dependencies need updated..\n\n"
    end
else 
    printf "Cauldron's base install files are not found. \nPlease re-pull the latest release from our github page and try again\n\n"
    return 1
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
