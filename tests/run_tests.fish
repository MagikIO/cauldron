#!/usr/bin/env fish

# Test Runner for Cauldron
# Usage: ./tests/run_tests.fish [--unit|--integration|--all]

set -l script_dir (dirname (status --current-filename))
set -l project_root (dirname $script_dir)

# Colors for output
set -l RED (set_color red)
set -l GREEN (set_color green)
set -l YELLOW (set_color yellow)
set -l BLUE (set_color blue)
set -l NORMAL (set_color normal)

echo "$BLUE══════════════════════════════════════════$NORMAL"
echo "$BLUE   Cauldron Test Runner$NORMAL"
echo "$BLUE══════════════════════════════════════════$NORMAL"
echo ""

# Parse arguments
set test_type "all"
if test (count $argv) -gt 0
    switch $argv[1]
        case "--unit" "-u"
            set test_type "unit"
        case "--integration" "-i"
            set test_type "integration"
        case "--all" "-a"
            set test_type "all"
        case "--help" "-h"
            echo "Usage: run_tests.fish [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -u, --unit         Run only unit tests"
            echo "  -i, --integration  Run only integration tests"
            echo "  -a, --all          Run all tests (default)"
            echo "  -h, --help         Show this help"
            exit 0
        case "*"
            echo "$RED""Error: Unknown option $argv[1]$NORMAL"
            exit 1
    end
end

# Check if Fishtape is installed
if not type -q fishtape
    echo "$YELLOW""Warning: Fishtape not found. Installing...$NORMAL"

    # Try to install Fisher first
    if not type -q fisher
        echo "Installing Fisher (Fish plugin manager)..."
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
        fisher install jorgebucaran/fisher 2>/dev/null
    end

    # Install Fishtape
    fisher install jorgebucaran/fishtape 2>/dev/null

    if not type -q fishtape
        echo "$RED""Error: Failed to install Fishtape$NORMAL"
        echo "Please install manually: fisher install jorgebucaran/fishtape"
        exit 1
    end
end

set -l total_tests 0
set -l passed_tests 0
set -l failed_tests 0

# Function to run tests in a directory
function run_test_suite
    set -l suite_name $argv[1]
    set -l suite_dir $argv[2]

    if test -d $suite_dir
        set test_files (ls $suite_dir/test_*.fish 2>/dev/null)

        if test (count $test_files) -eq 0
            echo "$YELLOW""No tests found in $suite_name$NORMAL"
            return
        end

        echo "$BLUE""Running $suite_name tests...$NORMAL"
        echo ""

        for test_file in $test_files
            set test_name (basename $test_file .fish)
            echo "$BLUE▶$NORMAL $test_name"

            # Run the test and capture output
            set output (fishtape $test_file 2>&1)
            set test_status $status

            # Parse TAP output for results
            set file_total (echo $output | grep -oE 'of [0-9]+' | tail -1 | grep -oE '[0-9]+')
            set file_passed (echo $output | grep -c "^ok ")
            set file_failed (echo $output | grep -c "^not ok ")

            if test -z "$file_total"
                set file_total 0
            end

            set total_tests (math $total_tests + $file_total)
            set passed_tests (math $passed_tests + $file_passed)
            set failed_tests (math $failed_tests + $file_failed)

            # Show individual test results
            if test $file_failed -gt 0
                echo "$RED  ✗ $file_failed failed$NORMAL"
                # Show failed test details
                echo $output | grep "^not ok " | sed 's/^/    /'
            else
                echo "$GREEN  ✓ $file_passed passed$NORMAL"
            end
        end
        echo ""
    else
        echo "$YELLOW""Directory $suite_dir not found$NORMAL"
    end
end

# Run tests based on type
switch $test_type
    case "unit"
        run_test_suite "Unit" "$script_dir/unit"
    case "integration"
        run_test_suite "Integration" "$script_dir/integration"
    case "all"
        run_test_suite "Unit" "$script_dir/unit"
        run_test_suite "Integration" "$script_dir/integration"
end

# Summary
echo "$BLUE══════════════════════════════════════════$NORMAL"
echo "$BLUE   Test Summary$NORMAL"
echo "$BLUE══════════════════════════════════════════$NORMAL"
echo "Total:  $total_tests"
echo "Passed: $GREEN$passed_tests$NORMAL"
echo "Failed: $RED$failed_tests$NORMAL"
echo ""

if test $failed_tests -gt 0
    echo "$RED""Some tests failed!$NORMAL"
    exit 1
else
    echo "$GREEN""All tests passed!$NORMAL"
    exit 0
end
