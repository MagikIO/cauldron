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
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/schema.sql 2> /dev/null
  else
    echo "Failed to find the schema.sql file in the data folder, please file an issue on GitHub"
    return 1
  end

  # Now we need to make sure the DB is up to date
  if test -f $CAULDRON_PATH/data/update.sql
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/update.sql 2> /dev/null
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
  set LATEST_VERSION (getLatestGithubReleaseTag MagikIO/cauldron | string replace -r '^v' '')

  # We should exit if CAULDRON_VERSION or LATEST_VERSION is not set or a empty string
  if test -z $CAULDRON_VERSION
    if set -qg CAULDRON_FAMILIAR
      set -eg CAULDRON_FAMILIAR
    end
    set -Ux CAULDRON_FAMILIAR suse
    familiar "Failed to pull which version of Cauldron you are on from the db :( "
    return 1
  end

  if test -z $LATEST_VERSION
    if set -qg CAULDRON_FAMILIAR
      set -eg CAULDRON_FAMILIAR
    end
    set -Ux CAULDRON_FAMILIAR suse
    familiar "Failed to pull the latest version of Cauldron from GitHub :( "
    return 1
  end

  # That will come out like "0.0.0" so we need to split it into an array, then compare each part
  set SPLIT_LATEST_VERSION (string split . $LATEST_VERSION)
  set SPLIT_CAULDRON_VERSION (string split . $CAULDRON_VERSION)

  # Now we need to compare the two versions
  if test $SPLIT_LATEST_VERSION[1] -gt $SPLIT_CAULDRON_VERSION[1] || test $SPLIT_LATEST_VERSION[2] -gt $SPLIT_CAULDRON_VERSION[2] || test $SPLIT_LATEST_VERSION[3] -gt $SPLIT_CAULDRON_VERSION[3]
    if set -qg CAULDRON_FAMILIAR
      set -eg CAULDRON_FAMILIAR
    end
    set -Ux CAULDRON_FAMILIAR suse
    # We need to update
    familiar "Updating to version $LATEST_VERSION"
  else
    if set -qg CAULDRON_FAMILIAR
      set -eg CAULDRON_FAMILIAR
    end
    set -Ux CAULDRON_FAMILIAR suse
    # We are already up to date
    familiar "You are already up to date!"
    return 0;
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
  git clone $CAULDRON_GIT_REPO $CAULDRON_PATH

  # Now we copy the data folder back
  if test -d $tmp_dir
    # Copy the data folder back
    cp -r $tmp_dir/* $CAULDRON_PATH/data/
  end

  # Now we remove the temp folder
  rm -rf $tmp_dir

  # Re-run schema and update migrations with the newly cloned files
  # This ensures any new schema changes or migrations are applied to the restored database
  if test -f $CAULDRON_PATH/data/schema.sql
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/schema.sql 2> /dev/null
  end

  if test -f $CAULDRON_PATH/data/update.sql
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/update.sql 2> /dev/null
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

  # Ensure tte is installed and working (reinstall if broken)
  if not command -q tte
    pipx ensurepath
    pipx install terminaltexteffects --quiet
  else
    # Check if tte actually works (module might be broken)
    if not tte --version >/dev/null 2>&1
      pipx reinstall terminaltexteffects --quiet
    end
  end

  if not command -q gum
    brew install gum
  end

  # As long as their is a dependencies.json file we will install the dependencies
    if test -f $CAULDRON_PATH/dependencies.json
      set apt_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.apt[]')
      set brew_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.brew[]')
      set snap_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.snap[]')

      sudo -v

      # Create temp directory for parallel job status
      set temp_dir (mktemp -d)
      set apt_log "$temp_dir/apt.log"
      set brew_log "$temp_dir/brew.log"
      set snap_log "$temp_dir/snap.log"
      set apt_status "$temp_dir/apt_status"
      set brew_status "$temp_dir/brew_status"
      set snap_status "$temp_dir/snap_status"

      # Job 1: Install all APT dependencies in parallel
      if test (count $apt_dependencies) -gt 0
        fish -c "
          set -l missing_deps
          for dep in $apt_dependencies
            if not type -q \$dep
              set -a missing_deps \$dep
            end
          end

          if test (count \$missing_deps) -gt 0
            sudo apt install -y \$missing_deps >> '$apt_log' 2>&1
          end

          # Log installed dependencies to database
          for dep in $apt_dependencies
            if type -q \$dep
              set VERSION (apt show \$dep 2>/dev/null | grep 'Version' | cut -d ':' -f 2 | tr -d ' ')
              set DATE (date)
              sqlite3 '$CAULDRON_DATABASE' \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('\$dep', '\$VERSION', '\$DATE')\"
            else
              echo \"Failed to install: \$dep\" >> '$apt_log'
            end
          end
          echo 'done' > '$apt_status'
        " &
        set apt_pid $last_pid
      else
        echo 'done' > $apt_status
      end

      # Job 2: Install all Brew dependencies in parallel
      if test (count $brew_dependencies) -gt 0
        fish -c "
          set -l missing_deps
          for dep in $brew_dependencies
            if not type -q \$dep
              set -a missing_deps \$dep
            end
          end

          if test (count \$missing_deps) -gt 0
            brew install \$missing_deps >> '$brew_log' 2>&1
          end

          # Log installed dependencies to database
          for dep in $brew_dependencies
            if type -q \$dep
              set VERSION (brew info \$dep 2>/dev/null | head -n 1 | grep -o '[0-9]\+\.[0-9]\+[^ ]*' | head -n 1)
              set DATE (date)
              sqlite3 '$CAULDRON_DATABASE' \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('\$dep', '\$VERSION', '\$DATE')\"
            else
              echo \"Failed to install: \$dep\" >> '$brew_log'
            end
          end
          echo 'done' > '$brew_status'
        " &
        set brew_pid $last_pid
      else
        echo 'done' > $brew_status
      end

      # Job 3: Install all Snap dependencies in parallel
      if test (count $snap_dependencies) -gt 0
        fish -c "
          for dep in $snap_dependencies
            if not type -q \$dep
              sudo snap install \$dep >> '$snap_log' 2>&1
            end

            if type -q \$dep
              set VERSION (snap info \$dep 2>/dev/null | grep 'installed' | cut -d ':' -f 2 | tr -d ' ')
              set DATE (date)
              sqlite3 '$CAULDRON_DATABASE' \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('\$dep', '\$VERSION', '\$DATE')\"
            else
              echo \"Failed to install: \$dep\" >> '$snap_log'
            end
          end
          echo 'done' > '$snap_status'
        " &
        set snap_pid $last_pid
      else
        echo 'done' > $snap_status
      end

      # Show progress while waiting for all package managers to complete
      set apt_done 0
      set brew_done 0
      set snap_done 0

      echo ""
      echo "Installing dependencies in parallel..."
      echo "  APT packages: $apt_dependencies"
      echo "  Brew packages: $brew_dependencies"
      echo "  Snap packages: $snap_dependencies"
      echo ""

      while test $apt_done -eq 0 -o $brew_done -eq 0 -o $snap_done -eq 0
        if test $apt_done -eq 0 -a -f "$apt_status"
          set apt_done 1
          echo "  ✓ APT dependencies completed"
        end

        if test $brew_done -eq 0 -a -f "$brew_status"
          set brew_done 1
          echo "  ✓ Brew dependencies completed"
        end

        if test $snap_done -eq 0 -a -f "$snap_status"
          set snap_done 1
          echo "  ✓ Snap dependencies completed"
        end

        if test $apt_done -eq 0 -o $brew_done -eq 0 -o $snap_done -eq 0
          sleep 0.5
        end
      end

      echo ""
      echo "✓ All dependencies installed!"

      # Show any errors from logs
      if test -f "$apt_log" -a -s "$apt_log"
        if grep -q "Failed to install" "$apt_log"
          echo ""
          echo "⚠ APT warnings/errors:"
          grep "Failed to install" "$apt_log"
        end
      end

      if test -f "$brew_log" -a -s "$brew_log"
        if grep -q "Failed to install" "$brew_log"
          echo ""
          echo "⚠ Brew warnings/errors:"
          grep "Failed to install" "$brew_log"
        end
      end

      if test -f "$snap_log" -a -s "$snap_log"
        if grep -q "Failed to install" "$snap_log"
          echo ""
          echo "⚠ Snap warnings/errors:"
          grep "Failed to install" "$snap_log"
        end
      end

      # Cleanup temp files
      rm -rf "$temp_dir" 2>/dev/null
  end

  # Now we need to update the DB's version
  sqlite3 $CAULDRON_DATABASE "INSERT OR REPLACE INTO cauldron (version) VALUES ('$LATEST_VERSION')"

  # Use simple banner if styled-banner fails (tte might not be ready yet)
  if command -q tte
    styled-banner "Updated!"
  else
    banner "Updated!"
  end

  echo ""
  echo "Cauldron has been updated to version $LATEST_VERSION"
  echo "Restart your shell to use the updated version: exec fish"

  return 0
end
