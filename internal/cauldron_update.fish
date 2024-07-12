#!/usr/bin/env fish

function cauldron_update -d 'Update Cauldron to the latest version'
  # Get sudo so we can update
  sudo -v

  # Path must exist for us to use
  if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.config/cauldron
  end

  # Make sure all vars are set
  fish -c "$CAULDRON_PATH/tools/__init_cauldron_vars.fish"

  # First we need to make sure the DB exists and the var is set
  if not test -f $CAULDRON_DATABASE
    fish -c "$CAULDRON_INTERNAL_TOOLS/__init_cauldron_DB.fish"
  end

  # Now we need to make sure the DB is up to date
  if test -f $CAULDRON_PATH/data/update.sql
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/update.sql
  end

  # Check their database to see what version they are on
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

  # Now we need to compare the two versions
  if test $SPLIT_LATEST_VERSION[1] -gt $SPLIT_CAULDRON_VERSION[1] || test $SPLIT_LATEST_VERSION[2] -gt $SPLIT_CAULDRON_VERSION[2] || test $SPLIT_LATEST_VERSION[3] -gt $SPLIT_CAULDRON_VERSION[3]
    # We need to update
    familiar "Updating to version $LATEST_VERSION"
  else
    # We are already up to date
    familiar "You are already up to date!"
    return 0;
  end

  fish -c "$CAULDRON_INTERNAL_TOOLS/__backup_cauldron_and_update.fish"

  # List of folders with functions
  set CAULDRON_LOCAL_DIRS "alias" "cli" "config" "effects" "functions" "familiar" "internal" "setup" "text" "UI"

  # Update all functions we provide
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

  fish -c "$CAULDRON_INTERNAL_TOOLS/__install_essential_tools.fish"

  # Now we need to update the DB's version
  sqlite3 $CAULDRON_DATABASE "INSERT OR REPLACE INTO cauldron (version) VALUES ('$LATEST_VERSION')"

  styled-banner "Updated!"

  return 0
end
