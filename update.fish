#!/usr/bin/env fish

if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.config/cauldron
    mkdir -p $CAULDRON_PATH
end

# First lets udpate all of our cauldron functions

# We will start with cpfunc since it is used to install the rest
if not command -q cpfunc
    cp ./functions/cpfunc.fish ~/.config/fish/functions/cpfunc.fish
    chmod +x ~/.config/fish/functions/cpfunc.fish
    source ~/.config/fish/functions/cpfunc.fish
end

# Next we will just update all of our functions
cpfunc ./cli -d
cpfunc ./config -d
cpfunc ./effects -d
cpfunc ./familiar -d
cpfunc ./functions -d
cpfunc ./internal -d
cpfunc ./text -d
cpfunc ./UI -d
cpfunc "./docs/__cauldron_help.fish"
cpfunc "./docs/__cauldron_install_help.fish"

# Now lets copy all of our functions and documentation to the $CAULDRON_PATH except the .git folder
rsync -av --exclude '.git' ./ $CAULDRON_PATH/


f-says "Cauldron has been updated to the latest version!"
