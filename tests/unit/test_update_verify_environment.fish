#!/usr/bin/env fish

# Unit tests for __update_verify_environment
# Tests environment variable validation and correction

function test_verify_environment_creates_missing_directories
  echo "Test: Creates missing directories"
  
  # Setup: Create temp test environment
  set -l test_home (mktemp -d)
  set -l test_cauldron_path "$test_home/.cauldron"
  set -l test_config_dir "$test_home/.config/cauldron"
  
  # Create the install directory but not config
  mkdir -p "$test_cauldron_path"
  
  # Override environment temporarily
  set -l old_home $HOME
  set -gx HOME $test_home
  set -gx CAULDRON_PATH $test_cauldron_path
  set -e CAULDRON_CONFIG_DIR
  
  # Source the function
  source update/__update_verify_environment.fish
  
  # Execute
  __update_verify_environment
  set -l result $status
  
  # Verify
  if test $result -eq 0 -a -d "$test_config_dir"
    echo "  ✓ PASS: Config directory created"
  else
    echo "  ✗ FAIL: Config directory not created (exit: $result)"
  end
  
  # Cleanup
  set -gx HOME $old_home
  rm -rf "$test_home"
end

function test_verify_environment_fixes_incorrect_paths
  echo "Test: Fixes incorrect environment variables"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l correct_path "$test_home/.cauldron"
  mkdir -p "$correct_path"
  
  # Set incorrect path
  set -gx CAULDRON_PATH "/wrong/path"
  set -gx HOME $test_home
  
  # Source and execute
  source update/__update_verify_environment.fish
  __update_verify_environment
  
  # Verify it was corrected
  if test "$CAULDRON_PATH" = "$correct_path"
    echo "  ✓ PASS: CAULDRON_PATH corrected"
  else
    echo "  ✗ FAIL: CAULDRON_PATH not corrected (got: $CAULDRON_PATH)"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

function test_verify_environment_fails_without_install_dir
  echo "Test: Returns error when install directory missing"
  
  # Setup: Don't create install directory
  set -l test_home (mktemp -d)
  set -gx HOME $test_home
  set -gx CAULDRON_PATH "$test_home/.cauldron"
  
  # Source and execute
  source update/__update_verify_environment.fish
  __update_verify_environment 2>/dev/null
  set -l result $status
  
  # Verify it fails
  if test $result -eq 1
    echo "  ✓ PASS: Returns error code 1"
  else
    echo "  ✗ FAIL: Should return 1, got $result"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

function test_verify_environment_creates_database_file
  echo "Test: Creates database file if missing"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron_path "$test_home/.cauldron"
  set -l test_config_dir "$test_home/.config/cauldron"
  set -l test_db "$test_config_dir/data/cauldron.db"
  
  mkdir -p "$test_cauldron_path"
  
  set -gx HOME $test_home
  set -gx CAULDRON_PATH $test_cauldron_path
  set -e CAULDRON_DATABASE
  
  # Source and execute
  source update/__update_verify_environment.fish
  __update_verify_environment
  
  # Verify
  if test -f "$test_db"
    echo "  ✓ PASS: Database file created"
  else
    echo "  ✗ FAIL: Database file not created"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

# Run all tests
echo "==================================="
echo "Testing __update_verify_environment"
echo "==================================="
echo ""

test_verify_environment_creates_missing_directories
echo ""
test_verify_environment_fixes_incorrect_paths
echo ""
test_verify_environment_fails_without_install_dir
echo ""
test_verify_environment_creates_database_file
echo ""

echo "==================================="
echo "Tests complete"
echo "==================================="
