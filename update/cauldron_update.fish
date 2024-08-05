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
  if test -f $CAULDRON_PATH/tools/__init_cauldron_vars.fish
    ./$CAULDRON_PATH/tools/__init_cauldron_vars.fish
  else
    echo " You seem to be missing one of our internal tools (__init_cauldron_vars.fish), please file a bug report on GitHub"
    return 1
  end

  if test -f $CAULDRON_PATH/tools/__init_cauldron_DB.fish
    # First we need to make sure the DB exists and the var is set
    if not test -f $CAULDRON_DATABASE
      ./$CAULDRON_PATH/tools/__init_cauldron_DB.fish
    end
  else
    echo " You seem to be missing one of our internal tools (__init_cauldron_DB.fish), please file a bug report on GitHub"
    return 1
  end

  # Now we need to make sure the DB is up to date
  if test -f $CAULDRON_PATH/data/update.sql
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/update.sql
  end

  if set -qg CAULDRON_VERSION
    set -eg CAULDRON_VERSION
  end

  # Check their database to see what version they are on
  set -Ux CAULDRON_VERSION (sqlite3 $CAULDRON_DATABASE "SELECT version FROM cauldron")

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

  if test -f $CAULDRON_PATH/tools/__backup_cauldron_and_update.fish
    ./$CAULDRON_PATH/tools/__backup_cauldron_and_update.fish
  else
    echo " You seem to be missing one of our internal tools (__backup_cauldron_and_update.fish), please file a bug report on GitHub"
    return 1
  end

  # List of folders with functions
  set CAULDRON_LOCAL_DIRS "alias" "cli" "config" "effects" "functions" "familiar" "internal" "setup" "text" "UI" "update"

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

  ./$CAULDRON_PATH/tools/__install_essential_tools.fish

  # Now we need to update the DB's version
  sqlite3 $CAULDRON_DATABASE "INSERT OR REPLACE INTO cauldron (version) VALUES ('$LATEST_VERSION')"

  styled-banner "Updated!"

  return 0
end
