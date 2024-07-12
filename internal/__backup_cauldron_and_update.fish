#!/usr/bin/env fish

function __backup_cauldron_and_update
  # Path must exist for us to use
  if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.config/cauldron

    if not test -d $CAULDRON_PATH
      familiar "Cauldron is not installed correctly, please run the install script"
    end
  end
  if not set -q CAULDRON_GIT_REPO
    set -Ux CAULDRON_GIT_REPO "https://github.com/MagikIO/cauldron.git"
  end

  # First we need to create a temporary directory to back up your Cauldron data folder
  set tmp_dir (mktemp -d)

  # Next we need to backup their data folder by copying it to a temp folder
  if test -d $CAULDRON_PATH/data
    cp -r $CAULDRON_PATH/data/* $tmp_dir/
  end

  # Now we remove everything in the base folder so we can clone the latest
  rm -rf $CAULDRON_PATH/
  mkdir -p $CAULDRON_PATH

  # Now we clone the latest version of the repo
  if command -v gum > /dev/null
    gum spin --spinner moon --title "Adding new ingredients to your cauldron..." -- fish -c "git clone $CAULDRON_GIT_REPO $CAULDRON_PATH"
  else
    git clone $CAULDRON_GIT_REPO $CAULDRON_PATH
  end

  # Now we copy the data folder back
  if test -d $tmp_dir
    # Copy the data folder back
    cp -r $tmp_dir/* $CAULDRON_PATH/data/
  end

  # Now we remove the temp folder
  rm -rf $tmp_dir
end
