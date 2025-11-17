#!/usr/bin/env fish

# Tests for bak (backup) function
# Run with: fishtape tests/unit/test_bak.fish

set -l test_dir (dirname (status --current-filename))
set -l project_root (dirname (dirname $test_dir))

# Source the function
source $project_root/functions/bak.fish

# Test: Version flag
@test "bak --version returns version number" (
    set result (bak --version)
    string match -qr '^\d+\.\d+\.\d+$' $result
) $status -eq 0

@test "bak -v returns version number" (
    set result (bak -v)
    string match -qr '^\d+\.\d+\.\d+$' $result
) $status -eq 0

# Test: Help flag
@test "bak --help shows usage" (
    bak --help | grep -q "Usage:"
) $status -eq 0

@test "bak --help shows options" (
    bak --help | grep -q "Options:"
) $status -eq 0

@test "bak -h shows help" (
    bak -h | grep -q "Usage:"
) $status -eq 0

# Test: Error handling
@test "bak without arguments shows error" (
    bak 2>&1 | grep -q "must provide"
) $status -eq 0

@test "bak with non-existent file shows error" (
    bak /nonexistent/file/path 2>&1 | grep -q "does not exist"
) $status -eq 0

@test "bak with directory shows error" (
    set temp_dir (mktemp -d)
    set result (bak $temp_dir 2>&1 | grep -q "directory")
    rm -rf $temp_dir
    test $result -eq 0
) $status -eq 0

@test "bak with symlink shows error" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/original.txt"
    set temp_link "$temp_dir/link.txt"

    echo "test" > $temp_file
    ln -s $temp_file $temp_link

    set result (bak $temp_link 2>&1 | grep -q "symlink")
    rm -rf $temp_dir

    test $result -eq 0
) $status -eq 0

# Test: Backup creation
@test "bak creates .bak file" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/test.txt"

    echo "original content" > $temp_file
    bak $temp_file

    set result (test -f "$temp_file.bak")
    rm -rf $temp_dir

    test $result -eq 0
) $status -eq 0

@test "bak preserves original file content" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/test.txt"

    echo "original content" > $temp_file
    bak $temp_file

    set original (cat $temp_file)
    set backup (cat "$temp_file.bak")

    rm -rf $temp_dir

    test "$original" = "$backup"
) $status -eq 0

@test "bak renames existing .bak to .1.bak" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/test.txt"

    echo "version 1" > $temp_file
    bak $temp_file

    echo "version 2" > $temp_file
    bak $temp_file

    set has_numbered (test -f "$temp_file.1.bak")
    rm -rf $temp_dir

    test $has_numbered -eq 0
) $status -eq 0

@test "bak creates numbered backups in sequence" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/test.txt"

    # Create initial file and backups
    for i in (seq 1 3)
        echo "version $i" > $temp_file
        bak $temp_file
    end

    # Check we have the expected backup files
    set has_bak (test -f "$temp_file.bak")
    set has_1 (test -f "$temp_file.1.bak")
    set has_2 (test -f "$temp_file.2.bak")

    rm -rf $temp_dir

    test $has_bak -eq 0 -a $has_1 -eq 0 -a $has_2 -eq 0
) $status -eq 0

# Test: Verbose mode
@test "bak --verbose shows output" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/test.txt"

    echo "test" > $temp_file
    set output (bak --verbose $temp_file 2>&1)

    rm -rf $temp_dir

    test -n "$output"
) $status -eq 0

@test "bak -V shows verbose output" (
    set temp_dir (mktemp -d)
    set temp_file "$temp_dir/test.txt"

    echo "test" > $temp_file
    set output (bak -V $temp_file 2>&1)

    rm -rf $temp_dir

    test -n "$output"
) $status -eq 0
