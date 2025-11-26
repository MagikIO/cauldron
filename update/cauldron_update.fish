#!/usr/bin/env fish

function cauldron_update -d 'Update Cauldron to the latest version'
  set -l func_version "2.1.5"
  set cauldron_category "Update"
  set -l options v/version h/help c/check-only b/branch= skip-git-sync
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
  # STEP 1: VERIFY ENVIRONMENT
  # ============================================================================
  
  if not __update_verify_environment
    return 1
  end

  # ============================================================================
  # STEP 2: GIT SYNCHRONIZATION
  # ============================================================================
  
  # Skip git sync if this is a re-execution after code update
  if not set -q _flag_skip_git_sync
    set -l check_only_flag (set -q _flag_check_only && echo "1" || echo "0")
    __update_git_sync $branch $check_only_flag
    set -l git_status $status

    echo "DEBUG: git_status = $git_status" >&2

    switch $git_status
      case 0
        # Already up to date
        return 0
      case 1
        # Updates available (check-only mode)
        return 0
      case 2
        # Error occurred
        return 1
      case 3
        # User cancelled
        return 0
      case 4
        # Successfully updated - re-execute with new code
        echo "DEBUG: Entered case 4 block" >&2
        echo ""
        echo "🔄 Reloading updated script..."
        
        # Build args to pass through
        set -l reexec_args --skip-git-sync
        if set -q _flag_branch
          set -a reexec_args --branch $_flag_branch
        end
        
        # Re-execute with updated code
        echo "DEBUG: About to exec with args: $reexec_args" >&2
        exec fish -c "source '$CAULDRON_PATH/update/cauldron_update.fish'; cauldron_update $reexec_args"
        echo "DEBUG: This line should never appear (exec failed)" >&2
    end
  end

  # ============================================================================
  # STEP 3: PARALLEL INSTALLATION TASKS
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
  set -l core_status "$temp_dir/core_status"
  set -l core_log "$temp_dir/core_log"

  # Job 1: Core update chain (functions → data → migrations → personality)
  # This must be sequential due to dependencies
  fish -c "
    # Copy functions
    set -l func_count (__update_install_functions)
    echo \"functions:\$func_count\" >> '$core_log'

    # Copy data files
    __update_install_data_files
    echo 'data:ok' >> '$core_log'

    # Run migrations (if available)
    set -l functions_dir '$CAULDRON_CONFIG_DIR/functions'
    if test -f '\$functions_dir/__run_migrations.fish'
      source '\$functions_dir/__run_migrations.fish'
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
    if test -f '\$functions_dir/__init_personality_system.fish'
      source '\$functions_dir/__init_personality_system.fish'
    end
    if test -f '\$functions_dir/__ensure_builtin_personalities.fish'
      source '\$functions_dir/__ensure_builtin_personalities.fish'
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
      __update_install_nodejs '$node_log'
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
  # STEP 4: SYSTEM DEPENDENCIES
  # Install required system packages (brew, pipx, tte, gum, etc.)
  # ============================================================================

  __update_install_system_deps

  # ============================================================================
  # STEP 5: PACKAGE MANAGER DEPENDENCIES
  # Install apt/brew/snap packages from dependencies.json
  # ============================================================================
  
  __update_install_package_manager_deps

  # ============================================================================
  # COMPLETION
  # Show what changed and prompt user to restart shell
  # ============================================================================

  echo ""
  echo "✨ Cauldron updated successfully!"
  echo ""
  echo "Please restart your Fish shell to use the updated version:"
  echo "  exec fish"

  return 0
end
