#!/usr/bin/env fish

# Quick verification that the refactored cauldron_update structure is sound

echo "╔════════════════════════════════════════════════════════╗"
echo "║   Cauldron Update Refactoring Verification            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

set -l tests_passed 0
set -l tests_failed 0

# Test 1: All helper functions exist
echo "Test 1: Verifying all helper functions exist..."
set -l expected_files \
  "update/__update_verify_environment.fish" \
  "update/__update_git_sync.fish" \
  "update/__update_install_functions.fish" \
  "update/__update_install_data_files.fish" \
  "update/__update_install_nodejs.fish" \
  "update/__update_install_system_deps.fish" \
  "update/__update_install_package_manager_deps.fish"

set -l all_exist 1
for file in $expected_files
  if test -f $file
    echo "  ✓ "(basename $file)
  else
    echo "  ✗ Missing: "(basename $file)
    set all_exist 0
  end
end

if test $all_exist -eq 1
  echo "  PASS: All helper functions created"
  set tests_passed (math $tests_passed + 1)
else
  echo "  FAIL: Some helper functions missing"
  set tests_failed (math $tests_failed + 1)
end

echo ""

# Test 2: Main function calls helpers
echo "Test 2: Verifying main function uses helpers..."
set -l main_file "update/cauldron_update.fish"

if not test -f $main_file
  echo "  FAIL: Main file not found"
  set tests_failed (math $tests_failed + 1)
else
  set -l main_content (cat $main_file)
  
  set -l has_verify (string match -q "*__update_verify_environment*" $main_content; echo $status)
  set -l has_git_sync (string match -q "*__update_git_sync*" $main_content; echo $status)
  set -l has_install_funcs (string match -q "*__update_install_functions*" $main_content; echo $status)
  set -l has_install_data (string match -q "*__update_install_data_files*" $main_content; echo $status)
  set -l has_install_nodejs (string match -q "*__update_install_nodejs*" $main_content; echo $status)
  set -l has_system_deps (string match -q "*__update_install_system_deps*" $main_content; echo $status)
  set -l has_pkg_deps (string match -q "*__update_install_package_manager_deps*" $main_content; echo $status)
  
  if test $has_verify -eq 0 -a $has_git_sync -eq 0 -a $has_install_funcs -eq 0 -a $has_install_data -eq 0 -a $has_install_nodejs -eq 0 -a $has_system_deps -eq 0 -a $has_pkg_deps -eq 0
    echo "  ✓ All helper functions called"
    echo "  PASS: Main function properly refactored"
    set tests_passed (math $tests_passed + 1)
  else
    echo "  ✗ Some helper functions not called:"
    test $has_verify -ne 0 && echo "    - __update_verify_environment"
    test $has_git_sync -ne 0 && echo "    - __update_git_sync"
    test $has_install_funcs -ne 0 && echo "    - __update_install_functions"
    test $has_install_data -ne 0 && echo "    - __update_install_data_files"
    test $has_install_nodejs -ne 0 && echo "    - __update_install_nodejs"
    test $has_system_deps -ne 0 && echo "    - __update_install_system_deps"
    test $has_pkg_deps -ne 0 && echo "    - __update_install_package_manager_deps"
    echo "  FAIL: Main function not fully refactored"
    set tests_failed (math $tests_failed + 1)
  end
end

echo ""

# Test 3: File size reduction
echo "Test 3: Verifying file size reduction..."
set -l main_lines (wc -l < $main_file)
echo "  Main file: $main_lines lines"

if test $main_lines -lt 400
  echo "  ✓ Main file reduced from ~705 to $main_lines lines"
  echo "  PASS: Significant size reduction achieved"
  set tests_passed (math $tests_passed + 1)
else
  echo "  ⚠ Main file still has $main_lines lines (expected < 400)"
  echo "  FAIL: Size reduction goal not met"
  set tests_failed (math $tests_failed + 1)
end

echo ""

# Test 4: Unit tests exist
echo "Test 4: Verifying unit tests exist..."
set -l test_files \
  "tests/unit/test_update_verify_environment.fish" \
  "tests/unit/test_update_git_sync.fish" \
  "tests/unit/test_update_install_functions.fish" \
  "tests/unit/test_update_install_data_files.fish" \
  "tests/unit/test_update_install_nodejs.fish" \
  "tests/unit/test_update_install_deps.fish"

set -l all_test_files_exist 1
for file in $test_files
  if test -f $file
    echo "  ✓ "(basename $file)
  else
    echo "  ✗ Missing: "(basename $file)
    set all_test_files_exist 0
  end
end

if test $all_test_files_exist -eq 1
  echo "  PASS: All unit test files created"
  set tests_passed (math $tests_passed + 1)
else
  echo "  FAIL: Some unit test files missing"
  set tests_failed (math $tests_failed + 1)
end

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   Verification Summary                                 ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "  Tests Passed:  $tests_passed / 4"
echo "  Tests Failed:  $tests_failed / 4"
echo ""

if test $tests_failed -eq 0
  echo "✅ Refactoring verification successful!"
  echo ""
  echo "Summary of changes:"
  echo "  • Created 7 internal helper functions in update/"
  echo "  • Reduced main function from ~705 to ~$main_lines lines"
  echo "  • Created 6 unit test files"
  echo "  • Improved testability and maintainability"
  exit 0
else
  echo "❌ Refactoring verification failed"
  exit 1
end
