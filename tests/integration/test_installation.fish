#!/usr/bin/env fish

# Integration tests for Cauldron installation and setup
# Run with: fishtape tests/integration/test_installation.fish

set -l test_dir (dirname (status --current-filename))
set -l project_root (dirname (dirname $test_dir))

# Test: Required files exist
@test "install.fish exists" (
    test -f $project_root/install.fish
) $status -eq 0

@test "install.fish is executable" (
    test -x $project_root/install.fish
) $status -eq 0

@test "package.json exists" (
    test -f $project_root/package.json
) $status -eq 0

@test "dependencies.json exists" (
    test -f $project_root/dependencies.json
) $status -eq 0

# Test: Required directories exist
@test "functions directory exists" (
    test -d $project_root/functions
) $status -eq 0

@test "familiar directory exists" (
    test -d $project_root/familiar
) $status -eq 0

@test "UI directory exists" (
    test -d $project_root/UI
) $status -eq 0

@test "text directory exists" (
    test -d $project_root/text
) $status -eq 0

@test "data directory exists" (
    test -d $project_root/data
) $status -eq 0

@test "tools directory exists" (
    test -d $project_root/tools
) $status -eq 0

@test "internal directory exists" (
    test -d $project_root/internal
) $status -eq 0

# Test: Data files exist
@test "palettes.json exists" (
    test -f $project_root/data/palettes.json
) $status -eq 0

@test "spinners.json exists" (
    test -f $project_root/data/spinners.json
) $status -eq 0

@test "schema.sql exists" (
    test -f $project_root/data/schema.sql
) $status -eq 0

# Test: Core functions exist
@test "cpfunc.fish exists" (
    test -f $project_root/functions/cpfunc.fish
) $status -eq 0

@test "installs.fish exists" (
    test -f $project_root/functions/installs.fish
) $status -eq 0

@test "bak.fish exists" (
    test -f $project_root/functions/bak.fish
) $status -eq 0

@test "node_init.fish exists" (
    test -f $project_root/functions/node_init.fish
) $status -eq 0

# Test: Familiar system exists
@test "familiar.fish exists" (
    test -f $project_root/familiar/familiar.fish
) $status -eq 0

@test "f-says.fish exists" (
    test -f $project_root/familiar/f-says.fish
) $status -eq 0

@test "f-thinks.fish exists" (
    test -f $project_root/familiar/f-thinks.fish
) $status -eq 0

# Test: CLI exists
@test "cauldron.fish CLI exists" (
    test -f $project_root/cli/cauldron.fish
) $status -eq 0

# Test: Internal tools exist
@test "__init_cauldron_DB.fish exists" (
    test -f $project_root/tools/__init_cauldron_DB.fish
) $status -eq 0

@test "__init_cauldron_vars.fish exists" (
    test -f $project_root/tools/__init_cauldron_vars.fish
) $status -eq 0

@test "__install_essential_tools.fish exists" (
    test -f $project_root/tools/__install_essential_tools.fish
) $status -eq 0

# Test: JSON files are valid
@test "palettes.json is valid JSON" (
    cat $project_root/data/palettes.json | python3 -m json.tool > /dev/null 2>&1
) $status -eq 0

@test "spinners.json is valid JSON" (
    cat $project_root/data/spinners.json | python3 -m json.tool > /dev/null 2>&1
) $status -eq 0

@test "dependencies.json is valid JSON" (
    cat $project_root/dependencies.json | python3 -m json.tool > /dev/null 2>&1
) $status -eq 0

@test "package.json is valid JSON" (
    cat $project_root/package.json | python3 -m json.tool > /dev/null 2>&1
) $status -eq 0

# Test: Cow files exist for familiar
@test "at least one .cow file exists" (
    set cow_files (ls $project_root/data/*.cow 2>/dev/null | count)
    test $cow_files -gt 0
) $status -eq 0

# Test: Documentation exists
@test "README.md exists" (
    test -f $project_root/README.md
) $status -eq 0

@test "CHANGELOG.md exists" (
    test -f $project_root/CHANGELOG.md
) $status -eq 0

@test "LICENSE exists" (
    test -f $project_root/LICENSE
) $status -eq 0

@test "docs directory exists" (
    test -d $project_root/docs
) $status -eq 0

# Test: TypeScript components exist
@test "node/index.ts exists" (
    test -f $project_root/node/index.ts
) $status -eq 0

@test "node/Cauldron.ts exists" (
    test -f $project_root/node/Cauldron.ts
) $status -eq 0

@test "node/DB.ts exists" (
    test -f $project_root/node/DB.ts
) $status -eq 0

@test "tsconfig.json exists" (
    test -f $project_root/tsconfig.json
) $status -eq 0
