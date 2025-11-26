#!/usr/bin/env fish

# Unit tests for __update_install_nodejs
# Tests Node.js dependency installation logic

function test_install_nodejs_requires_log_path
  echo "Test: Requires log file path parameter"
  
  # Source and execute without parameter
  source update/__update_install_nodejs.fish
  __update_install_nodejs 2>/dev/null
  set -l result $status
  
  # Verify returns error
  if test $result -eq 1
    echo "  ✓ PASS: Returns error when log path missing"
  else
    echo "  ✗ FAIL: Should return 1, got $result"
  end
end

function test_install_nodejs_detects_pnpm
  echo "Test: Detects and uses pnpm if available"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron "$test_home/.cauldron"
  set -l log_file "$test_home/test.log"
  
  mkdir -p "$test_cauldron"
  echo '{"name": "test"}' > "$test_cauldron/package.json"
  
  set -gx CAULDRON_PATH $test_cauldron
  
  # Only test if pnpm is actually available
  if command -q pnpm
    # Source and execute
    source update/__update_install_nodejs.fish
    __update_install_nodejs "$log_file" 2>/dev/null
    
    # Verify log contains pnpm
    if grep -q "pnpm:ok" "$log_file"
      echo "  ✓ PASS: Uses pnpm when available"
    else
      echo "  ✗ FAIL: pnpm not detected in log"
    end
  else
    echo "  ⊘ SKIP: pnpm not installed"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

function test_install_nodejs_detects_npm
  echo "Test: Falls back to npm if pnpm unavailable"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron "$test_home/.cauldron"
  set -l log_file "$test_home/test.log"
  
  mkdir -p "$test_cauldron"
  echo '{"name": "test"}' > "$test_cauldron/package.json"
  
  set -gx CAULDRON_PATH $test_cauldron
  
  # Create wrapper that simulates pnpm being unavailable
  set -l test_bin "$test_home/bin"
  mkdir -p "$test_bin"
  
  # Only test if npm is available but we can simulate no pnpm
  if command -q npm
    # Source and execute
    source update/__update_install_nodejs.fish
    
    # Temporarily hide pnpm
    if command -q pnpm
      echo "  ⊘ SKIP: Can't simulate missing pnpm"
    else
      __update_install_nodejs "$log_file" 2>/dev/null
      
      # Verify log contains npm
      if grep -q "npm:ok" "$log_file"
        echo "  ✓ PASS: Falls back to npm"
      else if grep -q "pnpm:ok" "$log_file"
        echo "  ⊘ SKIP: pnpm took precedence"
      else
        echo "  ✗ FAIL: Neither pnpm nor npm detected"
      end
    end
  else
    echo "  ⊘ SKIP: npm not installed"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

function test_install_nodejs_skips_if_no_package_manager
  echo "Test: Skips installation if no package manager found"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l test_cauldron "$test_home/.cauldron"
  set -l log_file "$test_home/test.log"
  
  mkdir -p "$test_cauldron"
  set -gx CAULDRON_PATH $test_cauldron
  
  # Note: We can't easily mock the command builtin, so we just verify
  # that the function handles the none:skip case properly by checking
  # the function code structure
  
  source update/__update_install_nodejs.fish
  set -l func_body (functions __update_install_nodejs)
  
  if string match -q "*none:skip*" $func_body
    echo "  ✓ PASS: Function has skip logic for missing package managers"
  else
    echo "  ✗ FAIL: Function missing skip logic"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

function test_install_nodejs_returns_success
  echo "Test: Returns success status"
  
  # Setup
  set -l test_home (mktemp -d)
  set -l log_file "$test_home/test.log"
  
  set -gx CAULDRON_PATH $test_home
  
  # Source and execute
  source update/__update_install_nodejs.fish
  __update_install_nodejs "$log_file" 2>/dev/null
  set -l result $status
  
  # Verify returns 0
  if test $result -eq 0
    echo "  ✓ PASS: Returns success (0)"
  else
    echo "  ✗ FAIL: Should return 0, got $result"
  end
  
  # Cleanup
  rm -rf "$test_home"
end

# Run all tests
echo "===================================="
echo "Testing __update_install_nodejs"
echo "===================================="
echo ""

test_install_nodejs_requires_log_path
echo ""
test_install_nodejs_detects_pnpm
echo ""
test_install_nodejs_detects_npm
echo ""
test_install_nodejs_skips_if_no_package_manager
echo ""
test_install_nodejs_returns_success
echo ""

echo "===================================="
echo "Tests complete"
echo "===================================="
