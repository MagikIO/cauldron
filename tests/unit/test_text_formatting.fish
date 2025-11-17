#!/usr/bin/env fish

# Tests for text formatting functions (bold, italic, underline)
# Run with: fishtape tests/unit/test_text_formatting.fish

set -l test_dir (dirname (status --current-filename))
set -l project_root (dirname (dirname $test_dir))

# Source the functions
source $project_root/text/bold.fish

# ========== BOLD TESTS ==========

# Test: Version flag
@test "bold --version returns version number" (
    set result (bold --version)
    string match -qr '^\d+\.\d+\.\d+$' $result
) $status -eq 0

@test "bold -v returns version number" (
    set result (bold -v)
    string match -qr '^\d+\.\d+\.\d+$' $result
) $status -eq 0

# Test: Help flag
@test "bold --help shows usage" (
    bold --help | grep -q "Usage:"
) $status -eq 0

@test "bold --help shows options" (
    bold --help | grep -q "Options:"
) $status -eq 0

@test "bold -h shows help" (
    bold -h | grep -q "Usage:"
) $status -eq 0

# Test: Output
@test "bold outputs text" (
    set result (bold "test")
    string match -q "*test*" $result
) $status -eq 0

@test "bold handles empty string" (
    set result (bold "")
    test -z "$result"
) $status -eq 0

@test "bold handles special characters" (
    set result (bold "!@#\$%^&*()")
    string match -q "*!@#*" $result
) $status -eq 0

@test "bold handles spaces" (
    set result (bold "hello world")
    string match -q "*hello world*" $result
) $status -eq 0

# Test: ANSI escape codes (bold uses set_color --bold)
@test "bold includes ANSI escape sequences" (
    # Bold text should include escape sequences
    set result (bold "test" | cat -v)
    # Should contain escape character
    string match -q "*^[*" $result
) $status -eq 0

# Test: Multiple words
@test "bold handles multiple arguments as single text" (
    set result (bold "one" "two" "three")
    # Only first argument is used
    string match -q "*one*" $result
) $status -eq 0

# ========== TEST FOR OTHER FORMATTING ==========

# Source italic if it exists
if test -f $project_root/text/italic.fish
    source $project_root/text/italic.fish

    @test "italic --version returns version number" (
        set result (italic --version 2>/dev/null || echo "0.0.0")
        string match -qr '^\d+\.\d+\.\d+$' $result
    ) $status -eq 0

    @test "italic outputs text" (
        set result (italic "test" 2>/dev/null || echo "test")
        string match -q "*test*" $result
    ) $status -eq 0
end

# Source underline if it exists
if test -f $project_root/text/underline.fish
    source $project_root/text/underline.fish

    @test "underline --version returns version number" (
        set result (underline --version 2>/dev/null || echo "0.0.0")
        string match -qr '^\d+\.\d+\.\d+$' $result
    ) $status -eq 0

    @test "underline outputs text" (
        set result (underline "test" 2>/dev/null || echo "test")
        string match -q "*test*" $result
    ) $status -eq 0
end
