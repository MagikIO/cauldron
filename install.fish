#!/usr/bin/env fish

#####################
##### VARIABLES #####
#####################
# Path must exist for us to use
if not set -q CAULDRON_PATH
  set -Ux CAULDRON_PATH $HOME/.config/cauldron

  if not test -d $CAULDRON_PATH
    mkdir -p $CAULDRON_PATH
  end
end

if not set -q __CAULDRON_DOCUMENTATION_PATH
  set -Ux __CAULDRON_DOCUMENTATION_PATH $CAULDRON_PATH/docs

  if not test -d $__CAULDRON_DOCUMENTATION_PATH
    mkdir -p $__CAULDRON_DOCUMENTATION_PATH
  end
end

if not set -q CAULDRON_GIT_REPO
  set -Ux CAULDRON_GIT_REPO "https://github.com/MagikIO/cauldron.git"
end

# List of folders with functions
set CAULDRON_LOCAL_DIRS "alias" "cli" "config" "effects" "familiar" "internal" "setup" "text" "UI"
set script_dir (dirname (status --current-filename))

# Get sudo so we can update
sudo -v

# First we need to make sure we have cpfunc installed
if not functions -q cpfunc
  chmod +x $script_dir/functions/cpfunc.fish
  cp $script_dir/functions/cpfunc.fish ~/.config/fish/functions/cpfunc.fish
  source ~/.config/fish/functions/cpfunc.fish
end

if not set -q CAULDRON_DATABASE
  set -Ux CAULDRON_DATABASE $CAULDRON_PATH/data/cauldron.db
end

# First we need to make sure the DB exists and the var is set
if not test -f $CAULDRON_DATABASE
  # If init_cauldron_DB is not defined we need to cpfunc it
  if not functions -q init_cauldron_DB
    cpfunc $script_dir/internal/init_cauldron_DB.fish
  end

  # Now we init the cauldron DB
  init_cauldron_DB
end

# We have to patch their version of `installs` with our version
cpfunc $script_dir/functions/ -d
cp -r $script_dir/functions $CAULDRON_PATH/functions

# Copy and source all the needed functions
for dir in $CAULDRON_LOCAL_DIRS
    if not test -d $CAULDRON_PATH/$dir
        mkdir -p $CAULDRON_PATH/$dir
    end

    cp -r $script_dir/$dir $CAULDRON_PATH/$dir
    cpfunc $CAULDRON_PATH/$dir -d
end

# Install the one off scripts that are not part of the main CLI
cp -r $script_dir/packages $CAULDRON_PATH/packages
cpfunc $script_dir/packages/asdf -d
cpfunc $script_dir/packages/nvm -d
cpfunc $script_dir/packages/choose_packman.fish

# Now we recursively copy the data, docs, node, and setup directories
cp -r $script_dir/data $CAULDRON_PATH/data
cp -r $script_dir/docs $CAULDRON_PATH/docs
cp -r $script_dir/node $CAULDRON_PATH/node

# We need to create a few variables to make things easier later
set -Ux CAULDRON_PALETTES $CAULDRON_PATH/data/palettes.json
set -Ux CAULDRON_SPINNERS $CAULDRON_PATH/data/spinners.json
set -Ux CAULDRON_DATABASE $CAULDRON_PATH/data/cauldron.db

# Create the log files
if not test -f $CAULDRON_PATH/logs/cauldron.log
    touch $CAULDRON_PATH/logs/cauldron.log
end

set OS (uname -s)

# If brew is not installed we need it
if not command -q brew
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
end

# If pipx not installed 
if not command -q pipx
  if test $OS = "Darwin"
    brew install pipx
  else
    sudo apt update
    sudo apt install pipx
  end
    pipx ensurepath
    register-python-argcomplete --shell fish pipx >~/.config/fish/completions/pipx.fish
    pipx install terminaltexteffects --quiet
end

if not command -q gum
  brew install gum
end

cp $script_dir/dependencies.json $CAULDRON_PATH/dependencies.json

# Now we need to install the dependencies from the ./dependencies.json file
set apt_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.apt[]')
set brew_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.brew[]')
set snap_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.snap[]')

for dep in $apt_dependencies
  gum spin --spinner moon --title "Installing $dep..." -- fish -c "if not command -q \$dep; sudo apt install \$dep -y; end; if not command -q \$dep; set ERROR_MSG \"Failed to install: \$dep using the command 'sudo apt install \$dep -y'\"; echo \$ERROR_MSG >> \$CAULDRON_PATH/logs/cauldron.log; else; set VERSION (apt show \$dep | grep \"Version\" | cut -d \":\" -f 2 | tr -d \" \"); set DATE (date); sqlite3 \$CAULDRON_DATABASE \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('\$dep', '\$VERSION', '\$DATE')\"; end"
end

for dep in $brew_dependencies
  gum spin --spinner moon --title "Installing $dep..." -- fish -c "if not command -q \$dep; brew install \$dep; end; if not command -q \$dep; set ERROR_MSG \"Failed to install: \$dep using the command 'brew install \$dep'\"; echo \$ERROR_MSG >> \$CAULDRON_PATH/logs/cauldron.log; else; set VERSION (brew info \$dep | grep \"version\" | cut -d \" \" -f 1 | tr -d \"version:\"); set DATE (date); sqlite3 \$CAULDRON_DATABASE \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('\$dep', '\$VERSION', '\$DATE');\"; end"
end

for dep in $snap_dependencies
  gum spin --spinner moon --title "Installing $dep..." -- fish -c "if not command -q \$dep; sudo snap install \$dep; end; if not command -q \$dep; set ERROR_MSG \"Failed to install: \$dep using the command 'sudo snap install \$dep'\"; echo \$ERROR_MSG >> \$CAULDRON_PATH/logs/cauldron.log; else; set VERSION (snap info \$dep | grep \"installed\" | cut -d \":\" -f 2 | tr -d \" \"); set DATE (date); sqlite3 \$CAULDRON_DATABASE \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('\$$dep', '\$VERSION', '\$DATE');\"; end"
end

styled-banner "Installed!"

return 0
