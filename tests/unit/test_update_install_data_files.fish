#!/usr/bin/env fish

# Unit tests for __update_install_data_files
# Tests data file copying logic

function test_install_data_files_copies_palettes
  echo "Test: Copies palettes.json"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron "$test_home/.cauldron"
  set -l test_config "$test_home/.config/cauldron"
  
  mkdir -p "$test_cauldron/data"
  echo '{"palettes": []}' > "$test_cauldron/data/palettes.json"
  
  set -gx CAULDRON_PATH $test_cauldron
  set -gx CAULDRON_CONFIG_DIR $test_config
  
  # Source and execute
  source update/__update_install_data_files.fish
  __update_install_data_files
  
  # Verify
  if test -f "$test_config/data/palettes.json"
    echo "  ✓ PASS: palettes.json copied"
  else
    echo "  ✗ FAIL: palettes.json not copied"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

function test_install_data_files_copies_spinners
  echo "Test: Copies spinners.json"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron "$test_home/.cauldron"
  set -l test_config "$test_home/.config/cauldron"
  
  mkdir -p "$test_cauldron/data"
  echo '{"spinners": []}' > "$test_cauldron/data/spinners.json"
  
  set -gx CAULDRON_PATH $test_cauldron
  set -gx CAULDRON_CONFIG_DIR $test_config
  
  # Source and execute
  source update/__update_install_data_files.fish
  __update_install_data_files
  
  # Verify
  if test -f "$test_config/data/spinners.json"
    echo "  ✓ PASS: spinners.json copied"
  else
    echo "  ✗ FAIL: spinners.json not copied"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

function test_install_data_files_creates_directory
  echo "Test: Creates data directory if missing"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron "$test_home/.cauldron"
  set -l test_config "$test_home/.config/cauldron"
  
  mkdir -p "$test_cauldron/data"
  echo '{}' > "$test_cauldron/data/palettes.json"
  
  set -gx CAULDRON_PATH $test_cauldron
  set -gx CAULDRON_CONFIG_DIR $test_config
  
  # Don't create target directory
  # Source and execute
  source update/__update_install_data_files.fish
  __update_install_data_files
  
  # Verify directory created
  if test -d "$test_config/data"
    echo "  ✓ PASS: data directory created"
  else
    echo "  ✗ FAIL: data directory not created"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

function test_install_data_files_handles_missing_source
  echo "Test: Handles missing source files gracefully"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron "$test_home/.cauldron"
  set -l test_config "$test_home/.config/cauldron"
  
  # Don't create any source files
  mkdir -p "$test_cauldron"
  
  set -gx CAULDRON_PATH $test_cauldron
  set -gx CAULDRON_CONFIG_DIR $test_config
  
  # Source and execute
  source update/__update_install_data_files.fish
  __update_install_data_files
  set -l result $status
  
  # Verify returns success even with no files
  if test $result -eq 0
    echo "  ✓ PASS: Returns 0 even with missing files"
  else
    echo "  ✗ FAIL: Should return 0, got $result"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

# Run all tests
echo "======================================="
echo "Testing __update_install_data_files"
echo "======================================="
echo ""

test_install_data_files_copies_palettes
echo ""
test_install_data_files_copies_spinners
echo ""
test_install_data_files_creates_directory
echo ""
test_install_data_files_handles_missing_source
echo ""

echo "======================================="
echo "Tests complete"
echo "======================================="
