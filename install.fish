#!/usr/bin/env fish

#####################
##### VARIABLES #####
#####################
set script_dir (dirname (status --current-filename))

# Get sudo so we can update
sudo -v

# Path must exist for us to use
if not set -q CAULDRON_PATH
  set -Ux CAULDRON_PATH $HOME/.config/cauldron
  # Make sure the path exists
  if not test -d $CAULDRON_PATH
    mkdir -p $CAULDRON_PATH
  end
end

if not test -d $CAULDRON_PATH/tools
  # Make the tools folder and move over internal tools
  mkdir -p $CAULDRON_PATH/tools
end

# Copy the tools over
cp -rf $script_dir/tools/* $CAULDRON_PATH/tools/
set -Ux CAULDRON_INTERNAL_TOOLS $CAULDRON_PATH/tools

# Make sure all vars are set
$CAULDRON_INTERNAL_TOOLS/__init_cauldron_vars.fish

# First we need to make sure we have cpfunc installed
if not functions -q cpfunc
  chmod +x $script_dir/functions/cpfunc.fish
  cp $script_dir/functions/cpfunc.fish ~/.config/fish/functions/cpfunc.fish
  source ~/.config/fish/functions/cpfunc.fish
end

# First we need to make sure the DB exists and the var is set
if not test -f $CAULDRON_DATABASE
  $CAULDRON_INTERNAL_TOOLS/__init_cauldron_DB.fish
end

# List of folders with functions
set CAULDRON_LOCAL_DIRS "alias" "cli" "config" "effects" "familiar" "internal" "setup" "text" "UI" "update"

# We have to patch their version of `installs` with our version
cpfunc $script_dir/functions/ -d
cp -rf $script_dir/functions/* $CAULDRON_PATH/functions/

# Copy and source all the needed functions
for dir in $CAULDRON_LOCAL_DIRS
  if not test -d $CAULDRON_PATH/$dir
    mkdir -p $CAULDRON_PATH/$dir
  end

  cp -rf $script_dir/$dir/* $CAULDRON_PATH/$dir/
  cpfunc $CAULDRON_PATH/$dir/ -d
end

# Install the one off scripts that are not part of the main CLI
cp -rf $script_dir/packages/* $CAULDRON_PATH/packages/
cpfunc $CAULDRON_PATH/packages/asdf/ -d
cpfunc $CAULDRON_PATH/packages/nvm/ -d
cpfunc $CAULDRON_PATH/packages/choose_packman.fish

# Now we recursively copy the data, docs, node, and setup directories
cp -rf $script_dir/data/* $CAULDRON_PATH/data/
cp -rf $script_dir/docs/* $CAULDRON_PATH/docs/
cp -rf $script_dir/node/* $CAULDRON_PATH/node/

# We need to create a few variables to make things easier later
set -Ux CAULDRON_PALETTES $CAULDRON_PATH/data/palettes.json
set -Ux CAULDRON_SPINNERS $CAULDRON_PATH/data/spinners.json
set -Ux CAULDRON_DATABASE $CAULDRON_PATH/data/cauldron.db

# Create the log files
if not test -f $CAULDRON_PATH/logs/cauldron.log
  mkdir -p $CAULDRON_PATH/logs
  touch $CAULDRON_PATH/logs/cauldron.log
end

cp $script_dir/dependencies.json $CAULDRON_PATH/dependencies.json

$CAULDRON_INTERNAL_TOOLS/__install_essential_tools.fish


# Reload PATH
source ~/.config/fish/config.fish

styled-banner "Installed!"

return 0
