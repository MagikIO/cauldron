#!/usr/bin/env fish

# Tests for detectOS function
# Run with: fishtape tests/unit/test_detectOS.fish

set -l test_dir (dirname (status --current-filename))
set -l project_root (dirname (dirname $test_dir))

# Source the function
source $project_root/internal/detectOS.fish

# Test: Version flag
@test "detectOS --version returns version number" (
    set result (detectOS --version)
    string match -qr '^\d+\.\d+\.\d+$' $result
) $status -eq 0

@test "detectOS -v returns version number" (
    set result (detectOS -v)
    string match -qr '^\d+\.\d+\.\d+$' $result
) $status -eq 0

# Test: Help flag
@test "detectOS --help shows usage" (
    detectOS --help | grep -q "Usage:"
) $status -eq 0

@test "detectOS --help shows options" (
    detectOS --help | grep -q "Options:"
) $status -eq 0

@test "detectOS -h shows help" (
    detectOS -h | grep -q "Usage:"
) $status -eq 0

# Test: Cauldron category flag
@test "detectOS --cauldron shows category" (
    detectOS --cauldron | grep -q "Category:"
) $status -eq 0

@test "detectOS -z shows category" (
    detectOS -z | grep -q "Category: Internal"
) $status -eq 0

# Test: Basic functionality
@test "detectOS returns operating system" (
    set result (detectOS)
    string match -q "Operating System:*" $result
) $status -eq 0

@test "detectOS identifies current OS" (
    set result (detectOS)
    # Should return something valid
    test -n "$result"
) $status -eq 0

# Test: Verbose mode
@test "detectOS --verbose provides detailed output" (
    set result (detectOS --verbose)
    string match -q "Operating System:*" $result
) $status -eq 0

@test "detectOS -V provides detailed output" (
    set result (detectOS -V)
    string match -q "Operating System:*" $result
) $status -eq 0

# Test: Return codes
@test "detectOS returns 0 on success" (
    detectOS > /dev/null
) $status -eq 0

@test "detectOS --version returns 0" (
    detectOS --version > /dev/null
) $status -eq 0

@test "detectOS --help returns 0" (
    detectOS --help > /dev/null
) $status -eq 0

# Test: Platform detection logic
@test "detectOS on Linux contains valid OS name" (
    if test (uname -s) != "Darwin"
        set result (detectOS)
        # Should contain Operating System: followed by something
        string match -qr "Operating System: \w+" $result
    else
        # Skip on macOS
        true
    end
) $status -eq 0

@test "detectOS on macOS returns macOS" (
    if test (uname -s) = "Darwin"
        set result (detectOS)
        string match -q "*macOS*" $result
    else
        # Skip on Linux
        true
    end
) $status -eq 0
