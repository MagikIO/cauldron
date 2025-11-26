#!/usr/bin/env fish

# Unit tests for __update_install_functions
# Tests function file copying logic

function test_install_functions_copies_files
  echo "Test: Copies function files to config directory"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron "$test_home/.cauldron"
  set -l test_config "$test_home/.config/cauldron"
  
  # Create source directory with test files
  mkdir -p "$test_cauldron/functions"
  mkdir -p "$test_cauldron/cli"
  echo "function test1; end" > "$test_cauldron/functions/test1.fish"
  echo "function test2; end" > "$test_cauldron/functions/test2.fish"
  echo "function test3; end" > "$test_cauldron/cli/test3.fish"
  
  set -gx CAULDRON_PATH $test_cauldron
  set -gx CAULDRON_CONFIG_DIR $test_config
  
  # Source and execute
  source update/__update_install_functions.fish
  set -l count (__update_install_functions)
  
  # Verify files were copied
  if test -f "$test_config/functions/test1.fish" -a -f "$test_config/functions/test2.fish" -a -f "$test_config/functions/test3.fish"
    echo "  ✓ PASS: All files copied"
  else
    echo "  ✗ FAIL: Not all files copied"
  end
  
  # Verify count is correct (3 files)
  if test "$count" = "3"
    echo "  ✓ PASS: Correct count returned ($count)"
  else
    echo "  ✗ FAIL: Wrong count (expected 3, got $count)"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

function test_install_functions_handles_empty_directories
  echo "Test: Handles empty source directories"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron "$test_home/.cauldron"
  set -l test_config "$test_home/.config/cauldron"
  
  # Create empty source directory
  mkdir -p "$test_cauldron/functions"
  
  set -gx CAULDRON_PATH $test_cauldron
  set -gx CAULDRON_CONFIG_DIR $test_config
  
  # Source and execute
  source update/__update_install_functions.fish
  set -l count (__update_install_functions)
  
  # Verify returns 0 for empty
  if test "$count" = "0"
    echo "  ✓ PASS: Returns 0 for empty directories"
  else
    echo "  ✗ FAIL: Expected 0, got $count"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

function test_install_functions_creates_target_directory
  echo "Test: Creates target directory if missing"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron "$test_home/.cauldron"
  set -l test_config "$test_home/.config/cauldron"
  
  mkdir -p "$test_cauldron/functions"
  echo "test" > "$test_cauldron/functions/test.fish"
  
  set -gx CAULDRON_PATH $test_cauldron
  set -gx CAULDRON_CONFIG_DIR $test_config
  
  # Don't create target directory
  # Source and execute
  source update/__update_install_functions.fish
  __update_install_functions >/dev/null
  
  # Verify target directory was created
  if test -d "$test_config/functions"
    echo "  ✓ PASS: Target directory created"
  else
    echo "  ✗ FAIL: Target directory not created"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

function test_install_functions_overwrites_existing
  echo "Test: Overwrites existing files"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron "$test_home/.cauldron"
  set -l test_config "$test_home/.config/cauldron"
  
  mkdir -p "$test_cauldron/functions"
  mkdir -p "$test_config/functions"
  
  echo "new content" > "$test_cauldron/functions/test.fish"
  echo "old content" > "$test_config/functions/test.fish"
  
  set -gx CAULDRON_PATH $test_cauldron
  set -gx CAULDRON_CONFIG_DIR $test_config
  
  # Source and execute
  source update/__update_install_functions.fish
  __update_install_functions >/dev/null
  
  # Verify file was overwritten
  set -l content (cat "$test_config/functions/test.fish")
  if test "$content" = "new content"
    echo "  ✓ PASS: File overwritten with new content"
  else
    echo "  ✗ FAIL: File not overwritten (content: $content)"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

# Run all tests
echo "===================================="
echo "Testing __update_install_functions"
echo "===================================="
echo ""

test_install_functions_copies_files
echo ""
test_install_functions_handles_empty_directories
echo ""
test_install_functions_creates_target_directory
echo ""
test_install_functions_overwrites_existing
echo ""

echo "===================================="
echo "Tests complete"
echo "===================================="
