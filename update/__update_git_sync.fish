#!/usr/bin/env fish

function __update_git_sync -d 'Synchronize Cauldron installation with remote repository'
  # Parameters:
  #   $argv[1] - branch name (required)
  #   $argv[2] - check-only flag (optional, "1" for check-only mode)
  # 
  # Returns:
  #   0 - Already up to date
  #   1 - Updates available (check-only mode)
  #   2 - Error occurred
  #   3 - User cancelled update

  set -l branch $argv[1]
  set -l check_only $argv[2]

  if test -z "$branch"
    echo "Error: Branch name required"
    return 2
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
    return 2
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

  if test "$check_only" = "1"
    echo ""
    echo "Run 'cauldron_update' to apply these updates"
    return 1
  end

  echo ""
  read -l -P "Apply updates? [y/N] " confirm

  if test "$confirm" != "y" -a "$confirm" != "Y"
    echo "Update cancelled"
    return 3
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
    return 2
  end

  echo "✓ Code updated successfully"
  
  # Store local and remote hashes for completion message
  set -g __UPDATE_LOCAL_HASH $local_hash
  set -g __UPDATE_REMOTE_HASH $remote_hash

  return 0
end
