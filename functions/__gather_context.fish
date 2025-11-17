#!/usr/bin/env fish

function __gather_context -d "Gather context about the current working environment"
    set -l context_json "{"

    # Get current directory
    set -l cwd (pwd)
    set context_json "$context_json\"cwd\":\"$cwd\","

    # Git information
    if git rev-parse --git-dir >/dev/null 2>&1
        set -l git_root (git rev-parse --show-toplevel 2>/dev/null)
        set -l git_branch (git branch --show-current 2>/dev/null)
        set -l git_remote (git config --get remote.origin.url 2>/dev/null)
        set -l git_status (git status --short 2>/dev/null | wc -l | string trim)
        set -l has_changes "false"
        if test $git_status -gt 0
            set has_changes "true"
        end

        set context_json "$context_json\"git\":{"
        set context_json "$context_json\"root\":\"$git_root\","
        set context_json "$context_json\"branch\":\"$git_branch\","
        set context_json "$context_json\"remote\":\"$git_remote\","
        set context_json "$context_json\"has_changes\":$has_changes,"
        set context_json "$context_json\"uncommitted_files\":$git_status"
        set context_json "$context_json},"
    end

    # Detect project type and languages
    set -l project_info (__detect_project_type)
    if test -n "$project_info"
        set context_json "$context_json\"project\":$project_info,"
    end

    # Session information
    if set -q CAULDRON_SESSION_ID
        set context_json "$context_json\"session_id\":\"$CAULDRON_SESSION_ID\","
    end

    # Timestamp
    set -l timestamp (date +%s)
    set context_json "$context_json\"timestamp\":$timestamp"

    set context_json "$context_json}"

    echo $context_json
end

function __detect_project_type -d "Detect project type and primary language"
    set -l project_json "{"

    set -l detected_languages ""
    set -l primary_language ""
    set -l framework ""
    set -l package_manager ""

    # Check for Node.js/JavaScript/TypeScript
    if test -f package.json
        set detected_languages "javascript"
        set primary_language "javascript"
        set package_manager "npm"

        # Check for TypeScript
        if test -f tsconfig.json
            set detected_languages "typescript"
            set primary_language "typescript"
        end

        # Detect package manager
        if test -f pnpm-lock.yaml
            set package_manager "pnpm"
        else if test -f yarn.lock
            set package_manager "yarn"
        else if test -f package-lock.json
            set package_manager "npm"
        end

        # Detect framework
        if grep -q "\"next\":" package.json 2>/dev/null
            set framework "nextjs"
        else if grep -q "\"react\":" package.json 2>/dev/null
            set framework "react"
        else if grep -q "\"vue\":" package.json 2>/dev/null
            set framework "vue"
        else if grep -q "\"@angular/core\":" package.json 2>/dev/null
            set framework "angular"
        end
    end

    # Check for Python
    if test -f requirements.txt -o -f setup.py -o -f pyproject.toml
        if test -z "$primary_language"
            set primary_language "python"
        end
        set detected_languages "$detected_languages,python"

        if test -f pyproject.toml
            if grep -q "\\[tool.poetry\\]" pyproject.toml 2>/dev/null
                set package_manager "poetry"
            end
        end
    end

    # Check for Rust
    if test -f Cargo.toml
        if test -z "$primary_language"
            set primary_language "rust"
        end
        set detected_languages "$detected_languages,rust"
        set package_manager "cargo"
    end

    # Check for Go
    if test -f go.mod
        if test -z "$primary_language"
            set primary_language "go"
        end
        set detected_languages "$detected_languages,go"
        set package_manager "go"
    end

    # Check for Ruby
    if test -f Gemfile
        if test -z "$primary_language"
            set primary_language "ruby"
        end
        set detected_languages "$detected_languages,ruby"
        set package_manager "bundler"
    end

    # Check for Fish Shell
    if test -f fish_plugins -o -f fish_variables
        if test -z "$primary_language"
            set primary_language "fish"
        end
        set detected_languages "$detected_languages,fish"
    end

    # Build JSON
    if test -n "$primary_language"
        set project_json "$project_json\"primary_language\":\"$primary_language\","
    end

    if test -n "$detected_languages"
        # Clean up leading comma if present
        set detected_languages (string replace -r '^,' '' $detected_languages)
        set project_json "$project_json\"languages\":\"$detected_languages\","
    end

    if test -n "$framework"
        set project_json "$project_json\"framework\":\"$framework\","
    end

    if test -n "$package_manager"
        set project_json "$project_json\"package_manager\":\"$package_manager\","
    end

    # Remove trailing comma and close JSON
    set project_json (string replace -r ',$' '' $project_json)
    set project_json "$project_json}"

    # Only return if we detected something
    if test "$project_json" != "{}"
        echo $project_json
    end
end
