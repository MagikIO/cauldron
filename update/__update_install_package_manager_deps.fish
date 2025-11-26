#!/usr/bin/env fish

function __update_install_package_manager_deps -d 'Install dependencies from dependencies.json'
  # Parses dependencies.json and installs apt/brew/snap packages
  # Returns: 0 on success

  set -l debug_log "/tmp/cauldron_update_debug.log"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_package_manager_deps: Starting" >> $debug_log

  if not test -f $CAULDRON_PATH/dependencies.json
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_package_manager_deps: No dependencies.json found" >> $debug_log
    return 0
  end

  set -l apt_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.apt[]')
  set -l brew_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.brew[]')
  set -l snap_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.snap[]')

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_package_manager_deps: APT deps: $apt_dependencies" >> $debug_log
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_package_manager_deps: Brew deps: $brew_dependencies" >> $debug_log
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_package_manager_deps: Snap deps: $snap_dependencies" >> $debug_log

  sudo -v

  # Create temp directory for parallel job status
  set -l temp_dir (mktemp -d)
  set -l apt_log "$temp_dir/apt.log"
  set -l snap_log "$temp_dir/snap.log"
  set -l apt_status "$temp_dir/apt_status"
  set -l snap_status "$temp_dir/snap_status"
  set -l apt_deps "$temp_dir/apt_deps.txt"
  set -l snap_deps "$temp_dir/snap_deps.txt"

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
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_package_manager_deps: Installing Brew packages" >> $debug_log
    set -l missing_deps
    for dep in $brew_dependencies
      if not type -q $dep
        set -a missing_deps $dep
      end
    end

    if test (count $missing_deps) -gt 0
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_package_manager_deps: Missing Brew deps: $missing_deps" >> $debug_log
      # Run brew synchronously with normal terminal output
      set -x HOMEBREW_NO_AUTO_UPDATE 1
      brew install $missing_deps 2>> $debug_log
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_package_manager_deps: Brew install completed" >> $debug_log
    end

    # Save brew dependency info to database
    for dep in $brew_dependencies
      if type -q $dep
        set -l VERSION (brew info $dep 2>/dev/null | head -n 1 | grep -o '[0-9]\+\.[0-9]\+[^ ]*' | head -n 1)
        set -l DATE (date)
        sqlite3 $CAULDRON_DATABASE "INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('$dep', '$VERSION', '$DATE')" 2>/dev/null
      end
    end
    echo "  ✓ Brew packages installed"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_package_manager_deps: Brew database updated" >> $debug_log
    echo ""
  end

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_package_manager_deps: Starting parallel APT/Snap jobs" >> $debug_log

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
    set -l apt_pid $last_pid
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
    set -l snap_pid $last_pid
  else
    echo 'done' > $snap_status
  end

  # Show progress while waiting for APT and Snap to complete
  set -l apt_done 0
  set -l snap_done 0

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

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_package_manager_deps: Completed successfully" >> $debug_log
  return 0
end
