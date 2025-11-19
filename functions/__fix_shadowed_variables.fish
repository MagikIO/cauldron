#!/usr/bin/env fish

function __fix_shadowed_variables --description "Find and fix shadowed variables, resetting them at the correct scope"
    # This function looks for variables that exist at multiple scopes (shadowed)
    # and removes duplicates, ensuring they're set at the appropriate scope

    set -l func_version "1.0.0"
    set __cauldron_category "Internal"

    # Flag options
    set -l options "v/version" "h/help" "d/dry-run" "verbose"
    argparse -n __fix_shadowed_variables $options -- $argv

    if set -q _flag_version
        echo $func_version
        return 0
    end

    if set -q _flag_help
        echo "Usage: __fix_shadowed_variables [OPTIONS]"
        echo ""
        echo "Find and fix shadowed variables in Fish shell environment"
        echo ""
        echo "Options:"
        echo "  -d, --dry-run  Show what would be fixed without making changes"
        echo "  --verbose      Show detailed output"
        echo "  -h, --help     Show this help message"
        echo "  -v, --version  Show version number"
        echo ""
        echo "Description:"
        echo "  This function identifies variables that are set at multiple scopes"
        echo "  (e.g., both global and universal) and consolidates them to the"
        echo "  correct scope based on Cauldron conventions:"
        echo "    - Universal (-Ux): Core Cauldron paths and configuration"
        echo "    - Global (-gx): Session-specific settings"
        echo "    - Local (-l): Function-scoped temporary variables"
        return 0
    end

    set -l verbose 0
    if set -q _flag_verbose
        set verbose 1
    end

    set -l dry_run 0
    if set -q _flag_dry_run
        set dry_run 1
        echo "Running in dry-run mode (no changes will be made)"
        echo ""
    end

    # Define which Cauldron variables should be at which scope
    # Format: variable_name:preferred_scope
    set -l cauldron_var_scopes \
        "CAULDRON_PATH:U" \
        "CAULDRON_DATABASE:U" \
        "CAULDRON_PALETTES:U" \
        "CAULDRON_SPINNERS:U" \
        "CAULDRON_INTERNAL_TOOLS:U" \
        "CAULDRON_GIT_REPO:U" \
        "__CAULDRON_DOCUMENTATION_PATH:U" \
        "CAULDRON_FAMILIAR_NAME:U" \
        "CAULDRON_USER_NAME:U" \
        "CAULDRON_USER_PRONOUNS:U" \
        "CAULDRON_VERSION:g"

    set -l fixed_count 0
    set -l shadowed_count 0

    if test $verbose -eq 1
        echo "Checking Cauldron variables for shadowing issues..."
        echo ""
    end

    # Check each Cauldron variable
    for var_spec in $cauldron_var_scopes
        set -l parts (string split ':' $var_spec)
        set -l var_name $parts[1]
        set -l preferred_scope $parts[2]

        # Check if variable exists at multiple scopes
        set -l is_universal 0
        set -l is_global 0
        set -l is_local 0
        set -l var_value ""

        # Check universal scope
        if set -qU $var_name
            set is_universal 1
            set var_value (set -U | grep "^$var_name " | string replace "$var_name " "")
        end

        # Check global scope
        if set -qg $var_name
            set is_global 1
            if test -z "$var_value"
                set var_value (set -g | grep "^$var_name " | string replace "$var_name " "")
            end
        end

        # Count how many scopes this variable exists in
        set -l scope_count (math $is_universal + $is_global)

        # If variable exists at multiple scopes, it's shadowed
        if test $scope_count -gt 1
            set shadowed_count (math $shadowed_count + 1)

            if test $verbose -eq 1; or test $dry_run -eq 1
                echo "⚠ Found shadowed variable: $var_name"
                if test $is_universal -eq 1
                    echo "  - Exists in universal scope"
                end
                if test $is_global -eq 1
                    echo "  - Exists in global scope"
                end
                echo "  - Preferred scope: $preferred_scope"
            end

            # Fix the shadowing if not in dry-run mode
            if test $dry_run -eq 0
                # Get the current value (prefer universal, then global)
                if test $is_universal -eq 1
                    set var_value $$var_name
                else if test $is_global -eq 1
                    set var_value $$var_name
                end

                # Remove from all scopes first
                if test $is_universal -eq 1
                    set -e -U $var_name 2>/dev/null
                end
                if test $is_global -eq 1
                    set -e -g $var_name 2>/dev/null
                end

                # Set at the preferred scope
                if test "$preferred_scope" = "U"
                    set -Ux $var_name $var_value
                    if test $verbose -eq 1
                        echo "  ✓ Reset to universal scope: $var_name"
                    end
                else if test "$preferred_scope" = "g"
                    set -gx $var_name $var_value
                    if test $verbose -eq 1
                        echo "  ✓ Reset to global scope: $var_name"
                    end
                end

                set fixed_count (math $fixed_count + 1)
            else
                echo "  → Would reset to $preferred_scope scope"
            end

            if test $verbose -eq 1; or test $dry_run -eq 1
                echo ""
            end
        end
    end

    # Also check for any other variables that might be problematic
    # (variables set at both -U and -g that aren't in our list)
    if test $verbose -eq 1
        echo "Checking for other potentially shadowed variables..."
        echo ""

        # Get all universal variables
        set -l all_universal (set -U | string match -r '^[A-Z_]+' | string replace -r ' .*' '')

        # Get all global variables starting with CAULDRON
        set -l all_cauldron_global (set -g | string match -r '^CAULDRON[A-Z_]*' | string replace -r ' .*' '')

        for var in $all_universal
            # Skip if already in our managed list
            set -l managed 0
            for var_spec in $cauldron_var_scopes
                set -l managed_var (string split ':' $var_spec)[1]
                if test "$var" = "$managed_var"
                    set managed 1
                    break
                end
            end

            if test $managed -eq 0
                # Check if it also exists in global scope
                if set -qg $var
                    echo "ℹ Found unmanaged shadowed variable: $var"
                    echo "  (exists in both universal and global scope)"
                    echo "  Skipping - not in Cauldron managed variables list"
                    echo ""
                end
            end
        end
    end

    # Summary
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if test $dry_run -eq 1
        echo "  Dry Run Summary:"
        echo "  Found $shadowed_count shadowed variable(s)"
        echo "  Would fix: $shadowed_count variable(s)"
    else
        echo "  Summary:"
        echo "  Found $shadowed_count shadowed variable(s)"
        echo "  Fixed: $fixed_count variable(s)"
    end
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if test $shadowed_count -eq 0
        echo "✓ No shadowed variables found!"
    else if test $dry_run -eq 0
        echo "✓ Variables have been reset to their correct scopes"
        echo ""
        echo "Note: You may need to restart your Fish shell for changes to take full effect:"
        echo "  exec fish"
    end

    return 0
end
