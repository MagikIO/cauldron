#!/usr/bin/env fish

# Tests for cpfunc function
# Run with: fishtape tests/unit/test_cpfunc.fish

set -l test_dir (dirname (status --current-filename))
set -l project_root (dirname (dirname $test_dir))

# Source the function
source $project_root/functions/cpfunc.fish

# Test: Version flag returns version number
@test "cpfunc --version returns version number" (
    set result (cpfunc --version)
    string match -qr '^\d+\.\d+\.\d+$' $result
) $status -eq 0

@test "cpfunc -v returns version number" (
    set result (cpfunc -v)
    string match -qr '^\d+\.\d+\.\d+$' $result
) $status -eq 0

# Test: Help flag shows help text
@test "cpfunc --help shows usage" (
    cpfunc --help | grep -q "Usage:"
) $status -eq 0

@test "cpfunc --help shows options" (
    cpfunc --help | grep -q "Options:"
) $status -eq 0

@test "cpfunc --help shows examples" (
    cpfunc --help | grep -q "Examples:"
) $status -eq 0

@test "cpfunc -h shows help" (
    cpfunc -h | grep -q "Usage:"
) $status -eq 0

# Test: Error handling - missing arguments
# Note: The function uses -a flag which sets path_to_function even when empty
# This causes basename error before the proper error check
@test "cpfunc without arguments returns error" (
    # Suppress stderr (basename error), check for the actual error message
    set output (cpfunc 2>&1)
    # Should contain the proper error message
    string match -q "*must provide*" $output
) $status -eq 0

# Test: Error handling - flag before path
@test "cpfunc with flag first returns error" (
    set output (cpfunc -d 2>&1)
    string match -q "*must provide*" $output
) $status -eq 0

# Test: Directory validation
@test "cpfunc -d with non-directory returns error" (
    set temp_file (mktemp)
    set output (cpfunc $temp_file -d 2>&1)
    set has_error (string match -q "*not a directory*" $output; and echo "yes"; or echo "no")
    rm -f $temp_file
    test "$has_error" = "yes"
) $status -eq 0

# Test: File copying (using temp directory)
@test "cpfunc copies single file correctly" (
    set temp_dir (mktemp -d)
    set test_func "$temp_dir/test_func.fish"

    # Create a simple test function
    echo 'function test_func; echo "test"; end' > $test_func

    # Mock the fish functions directory
    set original_home $HOME
    set -gx HOME $temp_dir
    mkdir -p $HOME/.config/fish/functions

    # Run cpfunc
    cpfunc $test_func 2>/dev/null

    # Check file was copied
    set copied "no"
    if test -f $HOME/.config/fish/functions/test_func.fish
        set copied "yes"
    end

    # Cleanup
    set -gx HOME $original_home
    rm -rf $temp_dir

    test "$copied" = "yes"
) $status -eq 0

@test "cpfunc makes file executable" (
    set temp_dir (mktemp -d)
    set test_func "$temp_dir/executable_test.fish"

    # Create non-executable file
    echo 'function executable_test; end' > $test_func
    chmod -x $test_func

    # Mock home
    set original_home $HOME
    set -gx HOME $temp_dir
    mkdir -p $HOME/.config/fish/functions

    # Run cpfunc
    cpfunc $test_func 2>/dev/null

    # Check original is now executable
    set is_exec "no"
    if test -x $test_func
        set is_exec "yes"
    end

    # Cleanup
    set -gx HOME $original_home
    rm -rf $temp_dir

    test "$is_exec" = "yes"
) $status -eq 0

@test "cpfunc extracts function name correctly" (
    set temp_dir (mktemp -d)
    set test_func "$temp_dir/my_custom_function.fish"

    echo 'function my_custom_function; end' > $test_func

    set original_home $HOME
    set -gx HOME $temp_dir
    mkdir -p $HOME/.config/fish/functions

    cpfunc $test_func 2>/dev/null

    # Should create my_custom_function.fish, not the full path
    set correct_name "no"
    if test -f $HOME/.config/fish/functions/my_custom_function.fish
        set correct_name "yes"
    end

    set -gx HOME $original_home
    rm -rf $temp_dir

    test "$correct_name" = "yes"
) $status -eq 0

# Test: Handling of relative paths
@test "cpfunc handles relative paths" (
    set temp_dir (mktemp -d)
    set original_pwd (pwd)
    cd $temp_dir

    echo 'function relative_test; end' > relative_test.fish

    set original_home $HOME
    set -gx HOME $temp_dir
    mkdir -p $HOME/.config/fish/functions

    cpfunc relative_test.fish 2>/dev/null

    set has_file "no"
    if test -f $HOME/.config/fish/functions/relative_test.fish
        set has_file "yes"
    end

    set -gx HOME $original_home
    cd $original_pwd
    rm -rf $temp_dir

    test "$has_file" = "yes"
) $status -eq 0
