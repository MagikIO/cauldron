#!/usr/bin/env fish

function cauldron_update -d 'Update Cauldron to the latest version'
  set -l func_version "2.0.0"
  set cauldron_category "Update"
  set -l options v/version h/help c/check-only b/branch=
  argparse -n cauldron_update $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
    echo $func_version
    return 0
  end

  # if they asked for help just return it
  if set -q _flag_help
    echo "Usage: cauldron_update [OPTIONS]"
    echo "Version: $func_version"
    echo "Update Cauldron to the latest version"
    echo
    echo "Options:"
    echo "  -v, --version       Show the version number"
    echo "  -h, --help          Show this help message"
    echo "  -c, --check-only    Check for updates without applying"
    echo "  -b, --branch NAME   Update to specific branch (default: main)"
    echo
    echo "Examples:"
    echo "  cauldron_update                 # Update to latest version"
    echo "  cauldron_update --check-only    # Check for updates"
    echo "  cauldron_update --branch dev    # Update to dev branch"
    return 0
  end

  # Set branch (default to main if not specified)
  set -l branch (set -q _flag_branch && echo $_flag_branch || echo "main")

  # Get sudo so we can update
  sudo -v

  # ============================================================================
  # VARIABLE VERIFICATION AND CORRECTION
  # Ensure all Cauldron paths are set correctly to prevent confusion between
  # install directory (~/.cauldron) and config directory (~/.config/cauldron)
  # ============================================================================

  # Set install directory (where git repo lives)
  if set -qg CAULDRON_PATH
    set -eg CAULDRON_PATH
  end

  if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.cauldron
  else if test "$CAULDRON_PATH" != "$HOME/.cauldron"
    # Fix incorrect CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.cauldron
  end

  # Make sure the install path exists
  if not test -d $CAULDRON_PATH
    echo "Error: Cauldron installation directory not found at $CAULDRON_PATH"
    echo "You must have Cauldron installed to update it, please run the install script instead"
    return 1
  end

  # Set config directory (where user data lives)
  if set -qg CAULDRON_CONFIG_DIR
    set -eg CAULDRON_CONFIG_DIR
  end

  if not set -q CAULDRON_CONFIG_DIR
    set -Ux CAULDRON_CONFIG_DIR $HOME/.config/cauldron
  else if test "$CAULDRON_CONFIG_DIR" != "$HOME/.config/cauldron"
    # Fix incorrect CAULDRON_CONFIG_DIR
    set -Ux CAULDRON_CONFIG_DIR $HOME/.config/cauldron
  end

  # Create config directory if it doesn't exist
  if not test -d $CAULDRON_CONFIG_DIR
    mkdir -p $CAULDRON_CONFIG_DIR
  end

  # Verify other required variables
  if not set -q __CAULDRON_DOCUMENTATION_PATH
    set -Ux __CAULDRON_DOCUMENTATION_PATH $CAULDRON_PATH/docs
  end

  if not test -d $__CAULDRON_DOCUMENTATION_PATH
    mkdir -p $__CAULDRON_DOCUMENTATION_PATH
  end

  if not set -q CAULDRON_GIT_REPO
    set -Ux CAULDRON_GIT_REPO "https://github.com/MagikIO/cauldron.git"
  end

  # Database should be in config directory, NOT install directory
  if set -qg CAULDRON_DATABASE
    set -eg CAULDRON_DATABASE
  end

  if not set -q CAULDRON_DATABASE
    set -Ux CAULDRON_DATABASE $CAULDRON_CONFIG_DIR/data/cauldron.db
  else if test "$CAULDRON_DATABASE" != "$CAULDRON_CONFIG_DIR/data/cauldron.db"
    # Fix incorrect database path
    set -Ux CAULDRON_DATABASE $CAULDRON_CONFIG_DIR/data/cauldron.db
  end

  if not test -f $CAULDRON_DATABASE
    mkdir -p $CAULDRON_CONFIG_DIR/data
    touch $CAULDRON_DATABASE
  end

  # Data files should be in config directory
  if set -qg CAULDRON_PALETTES
    set -eg CAULDRON_PALETTES
  end

  if not set -q CAULDRON_PALETTES
    set -Ux CAULDRON_PALETTES $CAULDRON_CONFIG_DIR/data/palettes.json
  else if test "$CAULDRON_PALETTES" != "$CAULDRON_CONFIG_DIR/data/palettes.json"
    set -Ux CAULDRON_PALETTES $CAULDRON_CONFIG_DIR/data/palettes.json
  end

  if set -qg CAULDRON_SPINNERS
    set -eg CAULDRON_SPINNERS
  end

  if not set -q CAULDRON_SPINNERS
    set -Ux CAULDRON_SPINNERS $CAULDRON_CONFIG_DIR/data/spinners.json
  else if test "$CAULDRON_SPINNERS" != "$CAULDRON_CONFIG_DIR/data/spinners.json"
    set -Ux CAULDRON_SPINNERS $CAULDRON_CONFIG_DIR/data/spinners.json
  end

  # Internal tools are in install directory
  if not set -q CAULDRON_INTERNAL_TOOLS
    set -Ux CAULDRON_INTERNAL_TOOLS $CAULDRON_PATH/tools
  else if test "$CAULDRON_INTERNAL_TOOLS" != "$CAULDRON_PATH/tools"
    set -Ux CAULDRON_INTERNAL_TOOLS $CAULDRON_PATH/tools
  end

  if not test -d $CAULDRON_INTERNAL_TOOLS
    mkdir -p $CAULDRON_INTERNAL_TOOLS
  end

  # ============================================================================
  # GIT-BASED UPDATE WORKFLOW
  # Use git to safely update instead of destructive rm+clone
  # ============================================================================

  echo "🔮 Cauldron Update System"
  echo ""

  # Verify we're in a git repository
  if not test -d "$CAULDRON_PATH/.git"
    echo "Error: Cauldron installation is not a git repository"
    echo "This may be an old installation format. Please reinstall using:"
    echo "  curl -fsSL https://raw.githubusercontent.com/MagikIO/cauldron/main/install.sh | bash"
    return 1
  end

  # Fetch latest changes
  echo "→ Checking for updates on branch '$branch'..."
  git -C "$CAULDRON_PATH" fetch origin $branch 2>/dev/null

  # Check if updates are available
  set -l local_hash (git -C "$CAULDRON_PATH" rev-parse HEAD)
  set -l remote_hash (git -C "$CAULDRON_PATH" rev-parse origin/$branch 2>/dev/null)

  if test "$local_hash" = "$remote_hash"
    echo "✓ Cauldron is already up to date!"
    return 0
  end

  # Show what will change
  echo ""
  echo "Updates available:"
  echo ""
  git -C "$CAULDRON_PATH" log --oneline --decorate --graph HEAD..origin/$branch | head -n 10

  if set -q _flag_check_only
    echo ""
    echo "Run 'cauldron_update' to apply these updates"
    return 0
  end

  echo ""
  read -l -P "Apply updates? [y/N] " confirm

  if test "$confirm" != "y" -a "$confirm" != "Y"
    echo "Update cancelled"
    return 0
  end

  # Create backup before updating (using migration system if available)
  echo ""
  echo "→ Creating backup..."

  if functions -q __run_migrations
    if not __run_migrations --backup-only
      echo "Warning: Backup failed, but continuing..."
    end
  else
    # Fallback: manual backup
    set -l backup_dir "$CAULDRON_CONFIG_DIR/backups"
    mkdir -p "$backup_dir"
    set -l timestamp (date +%Y%m%d_%H%M%S)
    if test -f "$CAULDRON_DATABASE"
      cp "$CAULDRON_DATABASE" "$backup_dir/cauldron_$timestamp.db" 2>/dev/null
    end
  end

  # Stash local changes
  echo "→ Stashing local changes..."
  git -C "$CAULDRON_PATH" stash push -m "Cauldron auto-update stash (date +%Y%m%d_%H%M%S)" 2>/dev/null

  # Pull updates
  echo "→ Pulling latest changes..."
  if not git -C "$CAULDRON_PATH" pull origin $branch --rebase
    echo "Error: Failed to pull updates"
    echo "Your local changes have been stashed"
    echo "Run 'cd $CAULDRON_PATH && git stash pop' to restore them"
    return 1
  end

  echo "✓ Code updated successfully"

  # ============================================================================
  # PARALLEL INSTALLATION TASKS
  # Run core updates (functions, data, migrations) and Node.js in parallel
  # ============================================================================

  # Show all pending installation tasks
  echo ""
  echo "📦 Installation Tasks:"
  echo "  • Updating functions and data files"
  echo "  • Running database migrations"
  echo "  • Initializing personality system"
  if test -f "$CAULDRON_PATH/package.json"
    echo "  • Updating Node.js dependencies"
  end
  echo ""

  # Create temp directory for parallel job status
  set -l temp_dir (mktemp -d)
  set -l functions_dir "$CAULDRON_CONFIG_DIR/functions"
  mkdir -p "$functions_dir"

  # Job 1: Core update chain (functions → data → migrations → personality)
  # This must be sequential due to dependencies
  set -l core_status "$temp_dir/core_status"
  set -l core_log "$temp_dir/core_log"

  fish -c "
    set -l updated_count 0

    # Copy all function directories
    set -l function_dirs alias cli config effects functions familiar internal setup text UI update
    for dir in \$function_dirs
      if test -d '$CAULDRON_PATH'/\$dir
        for func_file in '$CAULDRON_PATH'/\$dir/*.fish
          if test -f \$func_file
            cp -f \$func_file '$functions_dir/' 2>/dev/null
            set updated_count (math \$updated_count + 1)
          end
        end
      end
    end

    # Copy package functions
    if test -d '$CAULDRON_PATH/packages/asdf'
      for func_file in '$CAULDRON_PATH'/packages/asdf/*.fish
        if test -f \$func_file
          cp -f \$func_file '$functions_dir/' 2>/dev/null
          set updated_count (math \$updated_count + 1)
        end
      end
    end

    if test -d '$CAULDRON_PATH/packages/nvm'
      for func_file in '$CAULDRON_PATH'/packages/nvm/*.fish
        if test -f \$func_file
          cp -f \$func_file '$functions_dir/' 2>/dev/null
          set updated_count (math \$updated_count + 1)
        end
      end
    end

    if test -f '$CAULDRON_PATH/packages/choose_packman.fish'
      cp -f '$CAULDRON_PATH/packages/choose_packman.fish' '$functions_dir/' 2>/dev/null
      set updated_count (math \$updated_count + 1)
    end

    echo \"functions:\$updated_count\" >> '$core_log'

    # Copy data files
    set -l data_dir '$CAULDRON_CONFIG_DIR/data'
    mkdir -p \$data_dir
    if test -f '$CAULDRON_PATH/data/palettes.json'
      cp -f '$CAULDRON_PATH/data/palettes.json' \$data_dir/palettes.json 2>/dev/null
    end
    if test -f '$CAULDRON_PATH/data/spinners.json'
      cp -f '$CAULDRON_PATH/data/spinners.json' \$data_dir/spinners.json 2>/dev/null
    end
    echo 'data:ok' >> '$core_log'

    # Run migrations (if available)
    if test -f '$functions_dir/__run_migrations.fish'
      source '$functions_dir/__run_migrations.fish'
      if __run_migrations 2>&1 | tail -n 20 >> '$core_log'
        echo 'migrations:ok' >> '$core_log'
      else
        echo 'migrations:failed' >> '$core_log'
      end
    else
      # Fallback to direct SQL execution if migrations not available
      if test -f '$CAULDRON_PATH/data/schema.sql'
        sqlite3 '$CAULDRON_DATABASE' < '$CAULDRON_PATH/data/schema.sql' 2>/dev/null
      end
      if test -f '$CAULDRON_PATH/data/update.sql'
        sqlite3 '$CAULDRON_DATABASE' < '$CAULDRON_PATH/data/update.sql' 2>/dev/null
      end
      echo 'migrations:fallback' >> '$core_log'
    end

    # Initialize personality system
    if test -f '$functions_dir/__init_personality_system.fish'
      source '$functions_dir/__init_personality_system.fish'
    end
    if test -f '$functions_dir/__ensure_builtin_personalities.fish'
      source '$functions_dir/__ensure_builtin_personalities.fish'
    end
    if functions -q __init_personality_system
      __init_personality_system 2>/dev/null
      echo 'personality:ok' >> '$core_log'
    else
      echo 'personality:skip' >> '$core_log'
    end

    echo 'done' > '$core_status'
  " &
  set -l core_pid $last_pid

  # Job 2: Node.js dependencies (can run in parallel with core updates)
  set -l node_status "$temp_dir/node_status"
  set -l node_log "$temp_dir/node_log"
  set -l has_nodejs 0

  if test -f "$CAULDRON_PATH/package.json"
    set has_nodejs 1
    fish -c "
      if command -q pnpm
        cd '$CAULDRON_PATH' && pnpm install >> '$node_log' 2>&1
        echo 'pnpm:ok' >> '$node_log'
      else if command -q npm
        cd '$CAULDRON_PATH' && npm install >> '$node_log' 2>&1
        echo 'npm:ok' >> '$node_log'
      else
        echo 'none:skip' >> '$node_log'
      end
      echo 'done' > '$node_status'
    " &
    set -l node_pid $last_pid
  end

  # Wait for jobs to complete with status updates
  set -l core_done 0
  set -l node_done 0

  echo "⏳ Installing in parallel..."

  while test $core_done -eq 0 -o \( $has_nodejs -eq 1 -a $node_done -eq 0 \)
    # Check core job
    if test $core_done -eq 0 -a -f "$core_status"
      set core_done 1
      echo "  ✓ Core updates completed"
    end

    # Check node job
    if test $has_nodejs -eq 1 -a $node_done -eq 0 -a -f "$node_status"
      set node_done 1
      echo "  ✓ Node.js dependencies completed"
    end

    # Still waiting, show progress
    if test $core_done -eq 0 -o \( $has_nodejs -eq 1 -a $node_done -eq 0 \)
      sleep 0.5
    end
  end

  echo ""
  echo "📋 Installation Summary:"

  # Parse and display core results
  if test -f "$core_log"
    set -l func_count (grep '^functions:' "$core_log" | cut -d: -f2)
    if test -n "$func_count"
      echo "  ✓ Updated $func_count functions"
    end

    if grep -q '^data:ok' "$core_log"
      echo "  ✓ Data files updated"
    end

    if grep -q '^migrations:ok' "$core_log"
      echo "  ✓ Database migrations completed"
    else if grep -q '^migrations:failed' "$core_log"
      echo "  ⚠ Migrations failed - database backed up"
      echo "    You may need to run 'cauldron_repair' to fix issues"
    else if grep -q '^migrations:fallback' "$core_log"
      echo "  ✓ Database updated (fallback mode)"
    end

    if grep -q '^personality:ok' "$core_log"
      echo "  ✓ Personality system initialized"
    end
  end

  # Parse and display node results
  if test $has_nodejs -eq 1 -a -f "$node_log"
    if grep -q 'pnpm:ok' "$node_log"
      echo "  ✓ Node dependencies updated (pnpm)"
    else if grep -q 'npm:ok' "$node_log"
      echo "  ✓ Node dependencies updated (npm)"
    else if grep -q 'none:skip' "$node_log"
      echo "  ⚠ No package manager found (skipped Node.js dependencies)"
    end
  end

  # Cleanup temp files
  rm -rf "$temp_dir" 2>/dev/null

  # Set git alias
  git config --global alias.visual-checkout '!fish $CAULDRON_PATH/update/visual_git_checkout.fish'

  # ============================================================================
  # SYSTEM DEPENDENCIES
  # Install required system packages (brew, pipx, tte, gum, etc.)
  # ============================================================================

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

  # Install uv for Python script running (needed for richify)
  if not command -q uv
    echo "→ Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1
    # Ensure uv is in path for current session
    set -gx PATH $HOME/.cargo/bin $PATH
  end

  # Install richify for markdown streaming
  if not test -d $HOME/.local/share/richify
    echo "→ Installing richify for enhanced markdown streaming..."
    git clone --depth 1 https://github.com/gianlucatruda/richify.git $HOME/.local/share/richify >/dev/null 2>&1
    chmod +x $HOME/.local/share/richify/richify.py

    # Create symlink in ~/.local/bin
    mkdir -p $HOME/.local/bin
    ln -sf $HOME/.local/share/richify/richify.py $HOME/.local/bin/richify
    echo "  ✓ Richify installed"
  else if not command -q richify
    # Richify directory exists but symlink might be missing
    mkdir -p $HOME/.local/bin
    ln -sf $HOME/.local/share/richify/richify.py $HOME/.local/bin/richify
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
      set snap_log "$temp_dir/snap.log"
      set apt_status "$temp_dir/apt_status"
      set snap_status "$temp_dir/snap_status"
      set apt_deps "$temp_dir/apt_deps.txt"
      set snap_deps "$temp_dir/snap_deps.txt"

      echo ""
      echo "Installing dependencies..."
      echo "  APT packages: $apt_dependencies"
      echo "  Brew packages: $brew_dependencies"
      echo "  Snap packages: $snap_dependencies"
      echo ""

      # Install Brew dependencies first (synchronously, with terminal output)
      # Brew is run synchronously because it has issues running in background
      if test (count $brew_dependencies) -gt 0
        echo "→ Installing Brew packages..."
        set -l missing_deps
        for dep in $brew_dependencies
          if not type -q $dep
            set -a missing_deps $dep
          end
        end

        if test (count $missing_deps) -gt 0
          # Run brew synchronously with normal terminal output
          set -x HOMEBREW_NO_AUTO_UPDATE 1
          brew install $missing_deps
        end

        # Save brew dependency info to database
        for dep in $brew_dependencies
          if type -q $dep
            set VERSION (brew info $dep 2>/dev/null | head -n 1 | grep -o '[0-9]\+\.[0-9]\+[^ ]*' | head -n 1)
            set DATE (date)
            sqlite3 $CAULDRON_DATABASE "INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('$dep', '$VERSION', '$DATE')" 2>/dev/null
          end
        end
        echo "  ✓ Brew packages installed"
        echo ""
      end

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
            sudo apt install -y \$missing_deps >> '$apt_log' 2>&1 < /dev/null
          end

          # Collect dependency info to write to DB later (avoid concurrent DB writes)
          for dep in $apt_dependencies
            if type -q \$dep
              set VERSION (apt show \$dep 2>/dev/null | grep 'Version' | cut -d ':' -f 2 | tr -d ' ')
              set DATE (date)
              echo \"\$dep|\$VERSION|\$DATE\" >> '$apt_deps'
            else
              echo \"Failed to install: \$dep\" >> '$apt_log'
            end
          end
          echo 'done' > '$apt_status'
        " < /dev/null &
        set apt_pid $last_pid
      else
        echo 'done' > $apt_status
      end

      # Job 2: Install all Snap dependencies in parallel
      if test (count $snap_dependencies) -gt 0
        fish -c "
          for dep in $snap_dependencies
            if not type -q \$dep
              sudo snap install \$dep >> '$snap_log' 2>&1 < /dev/null
            end

            if type -q \$dep
              set VERSION (snap info \$dep 2>/dev/null | grep 'installed' | cut -d ':' -f 2 | tr -d ' ')
              set DATE (date)
              echo \"\$dep|\$VERSION|\$DATE\" >> '$snap_deps'
            else
              echo \"Failed to install: \$dep\" >> '$snap_log'
            end
          end
          echo 'done' > '$snap_status'
        " < /dev/null &
        set snap_pid $last_pid
      else
        echo 'done' > $snap_status
      end

      # Show progress while waiting for APT and Snap to complete
      set apt_done 0
      set snap_done 0

      echo "⏳ Installing APT and Snap packages in parallel..."

      # Wait for background jobs with timeout protection
      set -l max_iterations 600  # 5 minutes max (600 * 0.5s)
      set -l iterations 0

      while test $apt_done -eq 0 -o $snap_done -eq 0
        if test $apt_done -eq 0 -a -f "$apt_status"
          set apt_done 1
          echo "  ✓ APT dependencies completed"
        end

        if test $snap_done -eq 0 -a -f "$snap_status"
          set snap_done 1
          echo "  ✓ Snap dependencies completed"
        end

        if test $apt_done -eq 0 -o $snap_done -eq 0
          sleep 0.5
          set iterations (math $iterations + 1)

          # Timeout protection
          if test $iterations -ge $max_iterations
            echo ""
            echo "⚠ Warning: Dependency installation timed out after 5 minutes"
            if test $apt_done -eq 0
              echo "  APT job may still be running in background"
            end
            if test $snap_done -eq 0
              echo "  Snap job may still be running in background"
            end
            break
          end
        end
      end

      # Now write all dependency info to database (sequential to avoid deadlock)
      # Note: Brew dependencies are already written to DB synchronously above
      if test -f "$apt_deps"
        while read -l line
          set -l parts (string split '|' $line)
          if test (count $parts) -eq 3
            sqlite3 $CAULDRON_DATABASE "INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('$parts[1]', '$parts[2]', '$parts[3]')" 2>/dev/null
          end
        end < "$apt_deps"
      end

      if test -f "$snap_deps"
        while read -l line
          set -l parts (string split '|' $line)
          if test (count $parts) -eq 3
            sqlite3 $CAULDRON_DATABASE "INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('$parts[1]', '$parts[2]', '$parts[3]')" 2>/dev/null
          end
        end < "$snap_deps"
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

  # ============================================================================
  # COMPLETION
  # Show what changed and prompt user to restart shell
  # ============================================================================

  echo ""
  echo "✨ Cauldron updated successfully!"
  echo ""
  echo "Changes applied:"
  git -C "$CAULDRON_PATH" log --oneline --decorate $local_hash..$remote_hash

  echo ""
  echo "Please restart your Fish shell to use the updated version:"
  echo "  exec fish"

  return 0
end
