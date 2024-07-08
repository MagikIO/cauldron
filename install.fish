#!/usr/bin/env fish

#####################
##### VARIABLES #####
#####################
if not set -q CAULDRON_PATH
  set -Ux CAULDRON_PATH $HOME/.config/cauldron
end
if not set -q __CAULDRON_DOCUMENTATION_PATH
  set -Ux __CAULDRON_DOCUMENTATION_PATH $CAULDRON_PATH/docs
end

# List of folders with functions
set CAULDRON_LOCAL_DIRS alias cli config effects familiar internal packages setup text UI

# First we need to make sure we have cpfunc installed
if not functions -q cpfunc
  cp ./functions/cpfunc.fish ~/.config/fish/functions/cpfunc.fish
  chmod +x ~/.config/fish/functions/cpfunc.fish
  source ~/.config/fish/functions/cpfunc.fish
end

# We have to patch their version of `installs` with our version
cpfunc ./functions/ -d

# Copy and source all the needed functions
for dir in $CAULDRON_LOCAL_DIRS
    if not test -d $CAULDRON_PATH/$dir
        mkdir -p $CAULDRON_PATH/$dir
    end

    cp -r ./$dir $CAULDRON_PATH/$dir
    cpfunc ./$dir -d
end

# Now we recursively copy the data, docs, node, and setup directories
cp -r ./data $CAULDRON_PATH/data
cp -r ./docs $CAULDRON_PATH/docs
cp -r ./node $CAULDRON_PATH/node

# We need to create a few variables to make things easier later
set -Ux CAULDRON_PALETTES $CAULDRON_PATH/data/palettes.json
set -UX CAULDRON_SPINNERS $CAULDRON_PATH/data/spinners.json
set -UX CAULDRON_DATABASE $CAULDRON_PATH/data/cauldron.db

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



return 0
