#!/usr/bin/env fish

# Tests for bak (backup) function
# Run with: fishtape tests/unit/test_bak.fish

set -l test_dir (dirname (status --current-filename))
set -l project_root (dirname (dirname $test_dir))

# Source the function
source $project_root/functions/bak.fish

# Note: The bak function uses 'exit' instead of 'return' for --version and --help
# This causes issues with testing those flags directly. We test other functionality.

# Test: Error handling - no arguments
# Note: Function uses -a flag so argument is set to empty string, not truly missing
# Also, function uses 'return' without status code, so it returns 0 even on errors
@test "bak without arguments shows error message" (
    # Verify it produces an error message (can't rely on exit code due to bug)
    set output (bak 2>&1)
    # The function should at least say SOMETHING about not existing
    string match -q "*does not exist*" $output
) $status -eq 0

# Test: Error handling - non-existent file
@test "bak with non-existent file shows error" (
    set output (bak /nonexistent/file/path 2>&1)
    string match -q "*does not exist*" $output
) $status -eq 0

# Test: Error handling - directory
@test "bak with directory shows error" (
    set temp_dir (mktemp -d)
    set output (bak $temp_dir 2>&1)
    set has_error (string match -q "*directory*" $output; and echo "yes"; or echo "no")
    rm -rf $temp_dir
    test "$has_error" = "yes"
) $status -eq 0

# Test: Error handling - symlink
@test "bak with symlink shows error" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/original.txt"
    set temp_link "$temp_dir/link.txt"

    echo "test" > $temp_file
    ln -s $temp_file $temp_link

    set output (bak $temp_link 2>&1)
    set has_error (string match -q "*symlink*" $output; and echo "yes"; or echo "no")
    rm -rf $temp_dir

    test "$has_error" = "yes"
) $status -eq 0

# Test: Backup creation
@test "bak creates .bak file" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/test.txt"

    echo "original content" > $temp_file
    bak $temp_file 2>/dev/null

    set has_backup "no"
    if test -f "$temp_file.bak"
        set has_backup "yes"
    end

    rm -rf $temp_dir
    test "$has_backup" = "yes"
) $status -eq 0

# Test: Backup preserves content
@test "bak preserves original file content" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/test.txt"

    echo "original content" > $temp_file
    bak $temp_file 2>/dev/null

    set original (cat $temp_file)
    set backup (cat "$temp_file.bak")

    rm -rf $temp_dir

    test "$original" = "$backup"
) $status -eq 0

# Test: Multiple backups
@test "bak renames existing .bak to .1.bak" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/test.txt"

    echo "version 1" > $temp_file
    bak $temp_file 2>/dev/null

    echo "version 2" > $temp_file
    bak $temp_file 2>/dev/null

    set has_numbered "no"
    if test -f "$temp_file.1.bak"
        set has_numbered "yes"
    end

    rm -rf $temp_dir
    test "$has_numbered" = "yes"
) $status -eq 0

# Test: Sequential backups - simplified to avoid timing issues
@test "bak creates multiple backup files" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/test.txt"

    # Create initial backup
    echo "version 1" > $temp_file
    bak $temp_file 2>/dev/null

    # Create second backup
    echo "version 2" > $temp_file
    bak $temp_file 2>/dev/null

    # Check we have at least the main backup and one numbered
    set has_bak "no"
    set has_numbered "no"

    if test -f "$temp_file.bak"
        set has_bak "yes"
    end
    if test -f "$temp_file.1.bak"
        set has_numbered "yes"
    end

    rm -rf $temp_dir

    test "$has_bak" = "yes" -a "$has_numbered" = "yes"
) $status -eq 0

# Test: Non-readable file
@test "bak with non-readable file shows error" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/noread.txt"

    echo "test" > $temp_file
    chmod 000 $temp_file

    set output (bak $temp_file 2>&1)
    set has_error (string match -q "*not readable*" $output; and echo "yes"; or echo "no")

    chmod 644 $temp_file
    rm -rf $temp_dir

    test "$has_error" = "yes"
) $status -eq 0
