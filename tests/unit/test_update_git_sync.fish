#!/usr/bin/env fish

# Unit tests for __update_git_sync
# Tests git synchronization logic

function test_git_sync_detects_up_to_date
  echo "Test: Detects when already up to date"
  
  # Setup: Create a test git repo
  set -l test_dir (mktemp -d)
  set -l test_repo "$test_dir/cauldron"
  
  git init "$test_repo" >/dev/null 2>&1
  cd "$test_repo"
  echo "test" > README.md
  git add README.md
  git commit -m "Initial commit" >/dev/null 2>&1
  git branch -M main
  
  set -gx CAULDRON_PATH $test_repo
  
  # Source and execute
  source update/__update_git_sync.fish
  __update_git_sync main 1 2>/dev/null
  set -l result $status
  
  # Verify returns 0 (up to date)
  if test $result -eq 0
    echo "  ✓ PASS: Returns 0 when up to date"
  else
    echo "  ✗ FAIL: Should return 0, got $result"
  end
  
  # Cleanup
  cd /
  rm -rf "$test_dir"
end

function test_git_sync_requires_branch_parameter
  echo "Test: Requires branch parameter"
  
  # Setup
  set -l test_dir (mktemp -d)
  mkdir -p "$test_dir/.git"
  set -gx CAULDRON_PATH $test_dir
  
  # Source and execute without branch
  source update/__update_git_sync.fish
  __update_git_sync 2>/dev/null
  set -l result $status
  
  # Verify returns error (2)
  if test $result -eq 2
    echo "  ✓ PASS: Returns error when branch missing"
  else
    echo "  ✗ FAIL: Should return 2, got $result"
  end
  
  # Cleanup
  rm -rf "$test_dir"
end

function test_git_sync_detects_non_git_repo
  echo "Test: Detects non-git repository"
  
  # Setup: Directory without .git
  set -l test_dir (mktemp -d)
  set -gx CAULDRON_PATH $test_dir
  
  # Source and execute
  source update/__update_git_sync.fish
  __update_git_sync main 1 2>/dev/null
  set -l result $status
  
  # Verify returns error (2)
  if test $result -eq 2
    echo "  ✓ PASS: Returns error for non-git repo"
  else
    echo "  ✗ FAIL: Should return 2, got $result"
  end
  
  # Cleanup
  rm -rf "$test_dir"
end

function test_git_sync_check_only_mode
  echo "Test: Check-only mode doesn't apply updates"
  
  # Setup: Create test repo
  set -l test_dir (mktemp -d)
  set -l test_repo "$test_dir/cauldron"
  
  git init "$test_repo" >/dev/null 2>&1
  cd "$test_repo"
  echo "test" > README.md
  git add README.md
  git commit -m "Initial" >/dev/null 2>&1
  
  set -gx CAULDRON_PATH $test_repo
  
  # Source function
  source update/__update_git_sync.fish
  
  # Test with check_only=1
  set -l initial_hash (git rev-parse HEAD)
  __update_git_sync main 1 2>/dev/null
  set -l final_hash (git rev-parse HEAD)
  
  # Verify hash unchanged
  if test "$initial_hash" = "$final_hash"
    echo "  ✓ PASS: Check-only mode doesn't modify repo"
  else
    echo "  ✗ FAIL: Repo was modified in check-only mode"
  end
  
  # Cleanup
  cd /
  rm -rf "$test_dir"
end

# Run all tests
echo "============================"
echo "Testing __update_git_sync"
echo "============================"
echo ""

test_git_sync_requires_branch_parameter
echo ""
test_git_sync_detects_non_git_repo
echo ""
test_git_sync_detects_up_to_date
echo ""
test_git_sync_check_only_mode
echo ""

echo "============================"
echo "Tests complete"
echo "============================"
