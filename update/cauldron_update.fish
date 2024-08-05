#!/usr/bin/env fish

function cauldron_update -d 'Update Cauldron to the latest version'
  set -l func_version "1.0.0"
  set cauldron_category "Update"
  set -l options v/version h/help
  argparse -n cauldron_update $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
    echo $func_version
    return 0
  end

  # if they asked for help just return it
  if set -q _flag_help
    echo "Usage: cauldron_update"
    echo "Version: $func_version"
    echo "Update Cauldron to the latest version"
    echo
    echo "Options:"
    echo "  -v, --version  Show the version number"
    echo "  -h, --help     Show this help message"
    return 0
  end

  # Get sudo so we can update
  sudo -v

  # If the path is only global, we want to unset it, so we can set it universally
  if set -qg CAULDRON_PATH
    set -eg CAULDRON_PATH
  end

  if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.config/cauldron
  end

  # Make sure the path exists
  if not test -d $CAULDRON_PATH
    echo " You must have Cauldron installed to update it, please run the install script instead"
    return 1
  end

  # Make sure all vars are set
  if not set -q __CAULDRON_DOCUMENTATION_PATH
    set -Ux __CAULDRON_DOCUMENTATION_PATH $CAULDRON_PATH/docs
  
    if not test -d $__CAULDRON_DOCUMENTATION_PATH
      mkdir -p $__CAULDRON_DOCUMENTATION_PATH
    end
  end
  
  if not set -q CAULDRON_GIT_REPO
    set -Ux CAULDRON_GIT_REPO "https://github.com/MagikIO/cauldron.git"
  end
  
  if not set -q CAULDRON_DATABASE
    set -Ux CAULDRON_DATABASE $CAULDRON_PATH/data/cauldron.db
  
    if not test -f $CAULDRON_DATABASE
      mkdir -p $CAULDRON_PATH/data
      touch $CAULDRON_DATABASE
    end
  end
  
  if not set -q CAULDRON_INTERNAL_TOOLS
    set -Ux CAULDRON_INTERNAL_TOOLS $CAULDRON_PATH/tools
  
    if not test -d $CAULDRON_INTERNAL_TOOLS
      mkdir -p $CAULDRON_INTERNAL_TOOLS
    end
  end

  if test -f $CAULDRON_PATH/data/schema.sql
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/schema.sql
  else
    echo "Failed to find the schema.sql file in the data folder, please file an issue on GitHub"
    return 1
  end

  # Now we need to make sure the DB is up to date
  if test -f $CAULDRON_PATH/data/update.sql
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/update.sql
  else 
    echo "Failed to find the update.sql file in the data folder, please file an issue on GitHub"
    return 1
  end

  if set -qg CAULDRON_VERSION
    set -eg CAULDRON_VERSION
  end

  if not set -q CAULDRON_VERSION
    set -Ux CAULDRON_VERSION (sqlite3 $CAULDRON_DATABASE "SELECT version FROM cauldron") 2> /dev/null

    if test -z $CAULDRON_VERSION
      set -gx CAULDRON_VERSION (git ls-remote --tags $CAULDRON_GIT_REPO | awk '{print $2}' | grep -o "v[0-9]*\.[0-9]*\.[0-9]*" | sort -V | tail -n 1 | sed 's/v//')
      sqlite3 $CAULDRON_DATABASE "INSERT OR REPLACE INTO cauldron (version) VALUES ('$CAULDRON_VERSION')"
    end
  end

  # Now we check the most recent version (will be in format of "1.0.0")
  set LATEST_VERSION (getLatestGithubReleaseTag MagikIO/cauldron | string trim --left 'v')

  # We should exit if CAULDRON_VERSION or LATEST_VERSION is not set or a empty string
  if test -z $CAULDRON_VERSION
    familiar "Failed to pull which version of Cauldron you are on from the db :( "
    return 1
  end

  if test -z $LATEST_VERSION
    familiar "Failed to pull the latest version of Cauldron from GitHub :( "
    return 1
  end

  # That will come out like "0.0.0" so we need to split it into an array, then compare each part
  set SPLIT_LATEST_VERSION (string split . $LATEST_VERSION)
  set SPLIT_CAULDRON_VERSION (string split . $CAULDRON_VERSION)

  # Now we need to compare the two versions
  if test $SPLIT_LATEST_VERSION[1] -gt $SPLIT_CAULDRON_VERSION[1] || test $SPLIT_LATEST_VERSION[2] -gt $SPLIT_CAULDRON_VERSION[2] || test $SPLIT_LATEST_VERSION[3] -gt $SPLIT_CAULDRON_VERSION[3]
    # We need to update
    familiar "Updating to version $LATEST_VERSION"
  else
    # We are already up to date
    familiar "You are already up to date!"
    return 0;
  end

  # Path must exist for us to use
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

  # List of folders with functions
  set CAULDRON_LOCAL_DIRS "alias" "cli" "config" "effects" "functions" "familiar" "internal" "setup" "text" "UI" "update"

  # Update all functions we provide
  for dir in $CAULDRON_LOCAL_DIRS
    cpfunc $CAULDRON_PATH/$dir/ -d
  end

  cpfunc $CAULDRON_PATH/packages/asdf/ -d
  cpfunc $CAULDRON_PATH/packages/nvm/ -d
  cpfunc $CAULDRON_PATH/packages/choose_packman.fish

  git config --global alias.visual-checkout '!fish $CAULDRON_PATH/update/visual_git_checkout.fish'

  # We need to make sure these variables are set
  set -Ux CAULDRON_PALETTES $CAULDRON_PATH/data/palettes.json
  set -Ux CAULDRON_SPINNERS $CAULDRON_PATH/data/spinners.json

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
  end

  if not command -q tte
    pipx ensurepath
    pipx install terminaltexteffects --quiet
  end

  if not command -q gum
    brew install gum
  end

  # As long as their is a dependencies.json file we will install the dependencies
    if test -f $CAULDRON_PATH/dependencies.json
      set apt_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.apt[]')
      set brew_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.brew[]')
      set snap_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.snap[]')
  
      for dep in $apt_dependencies
          gum spin --spinner moon --title "Installing $dep..." -- fish -c "
              if not type -q $dep
                  sudo apt install $dep -y
              end
              if not type -q $dep
                  set ERROR_MSG \"Failed to install: $dep using the command 'sudo apt install $dep -y'\"
                  echo $ERROR_MSG >> $CAULDRON_PATH/logs/cauldron.log
              else
                  set VERSION (apt show $dep | grep 'Version' | cut -d ':' -f 2 | tr -d ' ')
                  set DATE (date)
                  sqlite3 $CAULDRON_DATABASE \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('$dep', '$VERSION', '$DATE')\"
              end"
      end
      
      for dep in $brew_dependencies
          gum spin --spinner moon --title "Installing $dep..." -- fish -c "
              if not type -q $dep
                  brew install $dep
              end
              if not type -q $dep
                  set ERROR_MSG \"Failed to install: $dep using the command 'brew install $dep'\"
                  echo $ERROR_MSG >> $CAULDRON_PATH/logs/cauldron.log
              else
                  set VERSION (brew info $dep | grep 'version' | cut -d ' ' -f 1 | tr -d 'version:')
                  set DATE (date)
                  sqlite3 $CAULDRON_DATABASE \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('$dep', '$VERSION', '$DATE')\"
              end"
      end
      
      for dep in $snap_dependencies
          gum spin --spinner moon --title "Installing $dep..." -- fish -c "
              if not type -q $dep
                  sudo snap install $dep
              end
              if not type -q $dep
                  set ERROR_MSG \"Failed to install: $dep using the command 'sudo snap install $dep'\"
                  echo $ERROR_MSG >> $CAULDRON_PATH/logs/cauldron.log
              else
                  set VERSION (snap info $dep | grep 'installed' | cut -d ':' -f 2 | tr -d ' ')
                  set DATE (date)
                  sqlite3 $CAULDRON_DATABASE \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('$dep', '$VERSION', '$DATE')\"
              end"
      end
  end

  # Now we need to update the DB's version
  sqlite3 $CAULDRON_DATABASE "INSERT OR REPLACE INTO cauldron (version) VALUES ('$LATEST_VERSION')"

  styled-banner "Updated!"

  return 0
end
