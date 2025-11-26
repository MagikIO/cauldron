#!/usr/bin/env fish

# Master test runner for all update function unit tests

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   Cauldron Update Function Unit Test Suite            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

set -l test_dir (dirname (status -f))
set -l total_tests 0
set -l passed_tests 0
set -l failed_tests 0
set -l skipped_tests 0

# Function to run a test file and collect results
function run_test_file
  set -l test_file $argv[1]
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Running: "(basename $test_file)
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Run test and capture output
  set -l test_output (fish $test_file 2>&1)
  echo $test_output
  
  # Count results (handle multiline output properly)
  set -l pass_count (printf '%s\n' $test_output | grep -c "✓ PASS")
  set -l fail_count (printf '%s\n' $test_output | grep -c "✗ FAIL")
  set -l skip_count (printf '%s\n' $test_output | grep -c "⊘ SKIP")
  
  set total_tests (math $total_tests + $pass_count + $fail_count + $skip_count)
  set passed_tests (math $passed_tests + $pass_count)
  set failed_tests (math $failed_tests + $fail_count)
  set skipped_tests (math $skipped_tests + $skip_count)
end

# Run all test files
set -l test_files \
  "$test_dir/test_update_verify_environment.fish" \
  "$test_dir/test_update_git_sync.fish" \
  "$test_dir/test_update_install_functions.fish" \
  "$test_dir/test_update_install_data_files.fish" \
  "$test_dir/test_update_install_nodejs.fish" \
  "$test_dir/test_update_install_deps.fish"

for test_file in $test_files
  if test -f $test_file
    run_test_file $test_file
  else
    echo "Warning: Test file not found: $test_file"
  end
end

# Print summary
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   Test Summary                                         ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "  Total Tests:   $total_tests"
echo "  ✓ Passed:      $passed_tests"
echo "  ✗ Failed:      $failed_tests"
echo "  ⊘ Skipped:     $skipped_tests"
echo ""

if test $failed_tests -eq 0
  echo "🎉 All tests passed!"
  if test $total_tests -gt 0
    set -l pass_rate (math "($passed_tests / $total_tests) * 100")
    echo "   Pass rate: "(math --scale=1 $pass_rate)"%"
  end
  echo ""
  exit 0
else
  echo "❌ Some tests failed"
  if test $total_tests -gt 0
    set -l pass_rate (math "($passed_tests / $total_tests) * 100")
    echo "   Pass rate: "(math --scale=1 $pass_rate)"%"
  end
  echo ""
  exit 1
end
