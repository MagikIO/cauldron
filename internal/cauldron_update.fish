#!/usr/bin/env fish

function cauldron_update
  set script_dir (dirname (status --current-filename))

  # First we need to make sure the DB exists and the var is set
  if not test -f $CAULDRON_DATABASE
    # If init_cauldron_DB is not defined we need to cpfunc it
    if not functions -q init_cauldron_DB
      cpfunc $script_dir/internal/init_cauldron_DB.fish
    end

    # Now we init the cauldron DB
    init_cauldron_DB
  end

  # Copy over the schema file
  cp $script_dir/data/schema.sql $CAULDRON_PATH/data/schema.sql

  # Invoke the schema just in case it is not there
  sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/schema.sql

  # Now we need to make sure the DB is up to date
  if test -f $CAULDRON_PATH/data/update.sql
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/update.sql
  end

  # Check their database to see what version they are on
  # CREATE TABLE "cauldron" ("version"	TEXT NOT NULL COLLATE RTRIM, PRIMARY KEY("version"));
  set -Ux CAULDRON_VERSION (sqlite3 $CAULDRON_DATABASE "SELECT version FROM cauldron")

  # Now we check the most recent version
  set LATEST_VERSION (git ls-remote --tags $CAULDRON_GIT_REPO | awk '{print $2}' | grep -o "v[0-9]*\.[0-9]*\.[0-9]*" | sort -V | tail -n 1 | sed 's/v//')
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

  # Path must exist for us to use
  if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.config/cauldron

    if not test -d $CAULDRON_PATH
      mkdir -p $CAULDRON_PATH
    end
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

  # First we need to create a temporary directory to back up their data folder
  set tmp_dir (mktemp -d)

  # Next we need to backup their data folder by copying it to a temp folder
  if test -d $CAULDRON_PATH/data
    # Make sure the temp folder exists
    mkdir -p $tmp_dir/data

    # Copy the data folder to the temp folder
    mv $CAULDRON_PATH/data $tmp_dir/data
  end

  # Now we remove everything in the base folder so we can clone the latest version
  rm -rf $CAULDRON_PATH/*

  # Now we clone the latest version of the repo
  git clone $CAULDRON_GIT_REPO $CAULDRON_PATH

  # Now we copy the data folder back
  if test -d $tmp_dir/data
    # Make sure the data folder exists
    mkdir -p $CAULDRON_PATH/data

    mv $tmp_dir/data $CAULDRON_PATH/data
  end

  # Now we remove the temp folder
  rm -rf $tmp_dir

  # List of folders with functions
  set CAULDRON_LOCAL_DIRS "alias" "cli" "config" "effects" "functions" "familiar" "internal" "setup" "text" "UI"

  # Copy and source all the needed functions
  for dir in $CAULDRON_LOCAL_DIRS
    if not test -d $CAULDRON_PATH/$dir
        mkdir -p $CAULDRON_PATH/$dir
    end

    cp -r $script_dir/$dir $CAULDRON_PATH/$dir
    cpfunc $CAULDRON_PATH/$dir -d
  end

  # Install the one off scripts that are not part of the main CLI
  mkdir -p $CAULDRON_PATH/packages
  cp -r $script_dir/packages $CAULDRON_PATH/packages
  cpfunc $CAULDRON_PATH/packages/asdf -d
  cpfunc $CAULDRON_PATH/packages/nvm -d
  cpfunc $CAULDRON_PATH/packages/choose_packman.fish

  # Now we recursively copy the essential doc pieces
  mkdir -p $CAULDRON_PATH/docs
  cp -r $script_dir/docs $CAULDRON_PATH/docs
  mkdir -p $CAULDRON_PATH/node
  cp -r $script_dir/node $CAULDRON_PATH/node

  # We need to create a few variables to make things easier later
  set -Ux CAULDRON_PALETTES $CAULDRON_PATH/data/palettes.json
  set -Ux CAULDRON_SPINNERS $CAULDRON_PATH/data/spinners.json
  set -Ux CAULDRON_DATABASE $CAULDRON_PATH/data/cauldron.db

  # Create the log files
  if not test -f $CAULDRON_PATH/logs/cauldron.log
    mkdir -p $CAULDRON_PATH/logs
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

  # Now we need to install the dependencies from the ./dependencies.json file
  set apt_dependencies (cat $script_dir/dependencies.json | jq -r '.apt[]')
  set brew_dependencies (cat $script_dir/dependencies.json | jq -r '.brew[]')
  set snap_dependencies (cat $script_dir/dependencies.json | jq -r '.snap[]')

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
end
