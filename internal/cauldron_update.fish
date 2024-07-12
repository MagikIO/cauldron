#!/usr/bin/env fish

function cauldron_update -d 'Update Cauldron to the latest version'
  # Path must exist for us to use
  if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.config/cauldron

    if not test -d $CAULDRON_PATH
      mkdir -p $CAULDRON_PATH
    end
  end

  # First we need to make sure the DB exists and the var is set
  if not test -f $CAULDRON_DATABASE
    # If init_cauldron_DB is not defined we need to cpfunc it
    if not functions -q init_cauldron_DB
      cpfunc $CAULDRON_PATH/internal/init_cauldron_DB.fish
    end

    # Now we init the cauldron DB
    init_cauldron_DB
  end

  # Now we need to make sure the DB is up to date
  if test -f $CAULDRON_PATH/data/update.sql
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/update.sql
  end

  # Check their database to see what version they are on
  # CREATE TABLE "cauldron" ("version"	TEXT NOT NULL COLLATE RTRIM, PRIMARY KEY("version"));
  set -gx CAULDRON_VERSION (sqlite3 $CAULDRON_DATABASE "SELECT version FROM cauldron")

  # Now we check the most recent version
  set LATEST_VERSION (git ls-remote --tags $CAULDRON_GIT_REPO | awk '{print $2}' | grep -o "v[0-9]*\.[0-9]*\.[0-9]*" | sort -V | tail -n 1 | sed 's/v//')
  # We should exit if CAULDRON_VERSION or LATEST_VERSION is not set or a empty string
  if test -z $CAULDRON_VERSION
    familiar "Failed to get the current version of Cauldron"
    return 1
  end

  if test -z $LATEST_VERSION
    familiar "Failed to get the latest version of Cauldron"
    return 1
  end

  # That will come out like "0.0.0" so we need to split it into an array, then compare each part
  set SPLIT_LATEST_VERSION (string split . $LATEST_VERSION)
  set SPLIT_CAULDRON_VERSION (string split . $CAULDRON_VERSION)

  # Get sudo so we can update
  sudo -v

  # Now we need to compare the two versions
  if test $SPLIT_LATEST_VERSION[1] -gt $SPLIT_CAULDRON_VERSION[1] || test $SPLIT_LATEST_VERSION[2] -gt $SPLIT_CAULDRON_VERSION[2] || test $SPLIT_LATEST_VERSION[3] -gt $SPLIT_CAULDRON_VERSION[3]
    # We need to update
    familiar "Updating to version $LATEST_VERSION"
  else
    # We are already up to date
    familiar "You are already up to date!"
    return 0;
  end

  # Make sure the documentation path is set
  if not set -q __CAULDRON_DOCUMENTATION_PATH
    set -Ux __CAULDRON_DOCUMENTATION_PATH $CAULDRON_PATH/docs

    # Make sure it exists
    if not test -d $__CAULDRON_DOCUMENTATION_PATH
      mkdir -p $__CAULDRON_DOCUMENTATION_PATH
    end
  end

  if not set -q CAULDRON_GIT_REPO
    set -Ux CAULDRON_GIT_REPO "https://github.com/MagikIO/cauldron.git"
  end

  ./$CAULDRON_PATH/internal/__cauldron_backup_user_data.fish

  # List of folders with functions
  set CAULDRON_LOCAL_DIRS "alias" "cli" "config" "effects" "functions" "familiar" "internal" "setup" "text" "UI"

  # Copy and source all the needed functions
  for dir in $CAULDRON_LOCAL_DIRS
    cpfunc $CAULDRON_PATH/$dir/ -d
  end

  cpfunc $CAULDRON_PATH/packages/asdf/ -d
  cpfunc $CAULDRON_PATH/packages/nvm/ -d
  cpfunc $CAULDRON_PATH/packages/choose_packman.fish

  # We need to make sure these variables are set
  set -Ux CAULDRON_PALETTES $CAULDRON_PATH/data/palettes.json
  set -Ux CAULDRON_SPINNERS $CAULDRON_PATH/data/spinners.json
  set -Ux CAULDRON_DATABASE $CAULDRON_PATH/data/cauldron.db

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

  # Now we need to update the DB's version
  sqlite3 $CAULDRON_DATABASE "INSERT OR REPLACE INTO cauldron (version) VALUES ('$LATEST_VERSION')"

  styled-banner "Updated!"

  return 0
end
