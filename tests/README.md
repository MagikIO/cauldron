# Cauldron Test Suite

This directory contains the testing infrastructure for Cauldron using [Fishtape](https://github.com/jorgebucaran/fishtape), a TAP-producing test runner for Fish shell.

## Table of Contents

- [Quick Start](#quick-start)
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Writing Tests](#writing-tests)
- [CI/CD Integration](#cicd-integration)
- [Test Categories](#test-categories)
- [Best Practices](#best-practices)

---

## Quick Start

```bash
# Install test dependencies
./tests/setup.fish

# Run all tests
./tests/run_tests.fish

# Run only unit tests
./tests/run_tests.fish --unit

# Run only integration tests
./tests/run_tests.fish --integration

# Run a specific test file
fishtape tests/unit/test_bak.fish
```

---

## Test Structure

```
tests/
├── README.md           # This file
├── setup.fish          # Test environment setup
├── run_tests.fish      # Test runner script
├── unit/               # Unit tests for individual functions
│   ├── test_bak.fish
│   ├── test_cpfunc.fish
│   ├── test_detectOS.fish
│   └── test_text_formatting.fish
├── integration/        # Integration tests
│   └── test_installation.fish
└── fixtures/           # Test fixtures and mock data
    └── test.db         # Test database (generated)
```

---

## Running Tests

### Using the Test Runner

The `run_tests.fish` script provides a convenient way to run all tests:

```bash
# Run all tests
./tests/run_tests.fish

# Run unit tests only
./tests/run_tests.fish --unit

# Run integration tests only
./tests/run_tests.fish --integration

# Get help
./tests/run_tests.fish --help
```

### Using Fishtape Directly

For more control, run Fishtape directly:

```bash
# Run a single test file
fishtape tests/unit/test_bak.fish

# Run all unit tests
fishtape tests/unit/test_*.fish

# Run with verbose TAP output
fishtape tests/unit/test_bak.fish 2>&1 | tee results.tap
```

### Expected Output

Tests use TAP (Test Anything Protocol) format:

```
TAP version 13
ok 1 - bak --version returns version number
ok 2 - bak -v returns version number
ok 3 - bak --help shows usage
...
1..15
# tests 15 pass 15 fail 0
```

---

## Writing Tests

### Basic Test Structure

```fish
#!/usr/bin/env fish

# Source the function to test
source /path/to/function.fish

# Test with @test macro
@test "description of test" (
    # Test code here
    set result (function_to_test)
    test "$result" = "expected"
) $status -eq 0
```

### Test Patterns

#### Testing Return Values

```fish
@test "function returns expected value" (
    set result (my_function "input")
    test "$result" = "expected output"
) $status -eq 0
```

#### Testing Exit Codes

```fish
@test "function returns 0 on success" (
    my_function "valid input" > /dev/null
) $status -eq 0

@test "function returns 1 on error" (
    my_function "invalid input" > /dev/null 2>&1
    test $status -eq 1
) $status -eq 0
```

#### Testing File Operations

```fish
@test "function creates file" (
    set temp_dir (mktemp -d)
    my_function $temp_dir/test.txt
    set result (test -f $temp_dir/test.txt)
    rm -rf $temp_dir
    test $result -eq 0
) $status -eq 0
```

#### Testing Error Messages

```fish
@test "function shows error for invalid input" (
    my_function "invalid" 2>&1 | grep -q "Error:"
) $status -eq 0
```

#### Testing Flags

```fish
@test "function --help shows usage" (
    my_function --help | grep -q "Usage:"
) $status -eq 0

@test "function --version returns version" (
    set result (my_function --version)
    string match -qr '^\d+\.\d+\.\d+$' $result
) $status -eq 0
```

### Using Fixtures

Place test data in `tests/fixtures/`:

```fish
set -l fixtures_dir (dirname (status --current-filename))/../fixtures

@test "loads fixture data" (
    set data (cat $fixtures_dir/sample.json)
    test -n "$data"
) $status -eq 0
```

### Cleanup

Always clean up temporary resources:

```fish
@test "test with cleanup" (
    set temp_file (mktemp)

    # Test code
    echo "test" > $temp_file
    set result (cat $temp_file)

    # Cleanup
    rm -f $temp_file

    test "$result" = "test"
) $status -eq 0
```

---

## CI/CD Integration

### GitHub Actions

Tests run automatically on:
- Push to `master` or `main`
- Pull requests to `master` or `main`
- Manual workflow dispatch

The workflow (`.github/workflows/test.yml`) includes:

1. **Fish Shell Tests** - Run on multiple Fish versions (3.6.1, 3.7.0)
2. **TypeScript Linting** - ESLint and type checking
3. **JSON Validation** - Verify all JSON files
4. **Shell Script Analysis** - Check Fish syntax
5. **Security Scan** - Audit dependencies

### Viewing Results

- Check the Actions tab on GitHub for test results
- Each PR shows test status checks
- Job summaries provide test statistics

### Local CI Simulation

```bash
# Simulate CI environment locally
export CAULDRON_PATH=$PWD
export CAULDRON_DATABASE=$PWD/tests/fixtures/test.db
./tests/run_tests.fish
```

---

## Test Categories

### Unit Tests (`tests/unit/`)

Test individual functions in isolation:

- **test_bak.fish** - File backup functionality
- **test_cpfunc.fish** - Function copying
- **test_detectOS.fish** - OS detection
- **test_text_formatting.fish** - Text styling (bold, italic, underline)

Each unit test should:
- Test a single function
- Be independent of other tests
- Use mocks/fixtures when needed
- Clean up after itself

### Integration Tests (`tests/integration/`)

Test component interactions:

- **test_installation.fish** - Verify installation structure

Integration tests should:
- Test how components work together
- Verify file structure integrity
- Check configuration validity

---

## Best Practices

### 1. Test Naming

Use descriptive names that explain what is being tested:

```fish
# Good
@test "bak creates .bak file when no backup exists"

# Bad
@test "test1"
```

### 2. One Assertion Per Test

Each test should verify one specific behavior:

```fish
# Good
@test "bak --version returns version" (...)
@test "bak --help shows usage" (...)

# Bad
@test "bak flags work" (...)  # Tests multiple things
```

### 3. Arrange-Act-Assert Pattern

```fish
@test "function behavior" (
    # Arrange
    set input "test data"

    # Act
    set result (my_function $input)

    # Assert
    test "$result" = "expected"
) $status -eq 0
```

### 4. Test Edge Cases

```fish
@test "handles empty input" (...)
@test "handles special characters" (...)
@test "handles very long input" (...)
```

### 5. Use Descriptive Failures

```fish
@test "error message is helpful" (
    set output (my_function 2>&1)
    string match -q "*specific error*" $output
) $status -eq 0
```

### 6. Isolate Tests

Don't let tests depend on each other:

```fish
# Good: Each test is independent
@test "test A" (
    set temp (mktemp)
    # ... test ...
    rm $temp
) $status -eq 0

@test "test B" (
    set temp (mktemp)
    # ... test ...
    rm $temp
) $status -eq 0
```

### 7. Mock External Dependencies

```fish
# Mock home directory for testing
set original_home $HOME
set -gx HOME (mktemp -d)
# ... test ...
set -gx HOME $original_home
```

---

## Adding New Tests

1. Create a new test file in the appropriate directory:
   ```bash
   touch tests/unit/test_new_function.fish
   ```

2. Add the test structure:
   ```fish
   #!/usr/bin/env fish

   set -l test_dir (dirname (status --current-filename))
   set -l project_root (dirname (dirname $test_dir))

   # Source function
   source $project_root/path/to/function.fish

   # Add tests
   @test "description" (
       # test code
   ) $status -eq 0
   ```

3. Run your new test:
   ```bash
   fishtape tests/unit/test_new_function.fish
   ```

4. Commit with the tested function.

---

## Troubleshooting

### Fishtape Not Found

```bash
# Install Fisher and Fishtape
curl -sL https://git.io/fisher | source
fisher install jorgebucaran/fishtape
```

### Tests Pass Locally but Fail in CI

- Check Fish shell version compatibility
- Ensure no hardcoded paths
- Verify environment variables are set

### Flaky Tests

- Avoid timing-dependent tests
- Don't rely on external services
- Use deterministic test data

---

## Resources

- [Fishtape Documentation](https://github.com/jorgebucaran/fishtape)
- [TAP Specification](https://testanything.org/)
- [Fish Shell Testing Best Practices](https://fishshell.com/docs/current/index.html)

---

## Contributing Tests

When adding new functions to Cauldron:

1. Write tests for the function
2. Ensure all tests pass locally
3. Include tests in your PR
4. Document any special test requirements

Good test coverage helps maintain code quality and catch regressions early!
