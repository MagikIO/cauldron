#!/usr/bin/env fish

# Test Setup Script for Cauldron
# This script installs Fishtape and prepares the test environment

set -l script_dir (dirname (status --current-filename))
set -l project_root (dirname $script_dir)

echo "Setting up Cauldron test environment..."

# Install Fisher (Fish plugin manager) if not present
if not functions -q fisher
    echo "Installing Fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher 2>/dev/null
end

# Install Fishtape
if not functions -q fishtape
    echo "Installing Fishtape..."
    fisher install jorgebucaran/fishtape
end

# Set up test environment variables
set -gx CAULDRON_TEST_MODE true
set -gx CAULDRON_PATH $project_root
set -gx CAULDRON_DATABASE $project_root/tests/fixtures/test.db
set -gx CAULDRON_PALETTES $project_root/data/palettes.json
set -gx CAULDRON_SPINNERS $project_root/data/spinners.json
set -gx CAULDRON_INTERNAL_TOOLS $project_root/tools

# Create test database directory
mkdir -p $project_root/tests/fixtures

# Source all functions for testing
for dir in functions familiar UI text internal
    if test -d $project_root/$dir
        for file in $project_root/$dir/*.fish
            source $file 2>/dev/null
        end
    end
end

echo "Test environment ready!"
echo "Run tests with: fishtape tests/unit/*.fish"
