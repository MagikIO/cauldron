#!/usr/bin/env fish

function update_git_alias -d 'Update a Git alias, if the definition has changed, otherwise do nothing' -a git_alias -d "The name of the Git alias to update" -a new_alias_definition -d "The new definition of the Git alias"
    # Version Number
    set -l func_version "1.2.0"
    set -l __cauldron_category Setup
    # Flag options
    set -l options v/version t/test h/help V/verbose s/silent z/cauldron
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it (added in 1.0.2)
    if set -q _flag_help
        echo (bold "Update Git Alias") " - v$func_version"
        echo ""
        echo "Update a Git alias, if the definition has changed, otherwise do nothing"
        echo ""
        echo (bold "Options:")
        echo "  -v, --version  Show the version number"
        echo "  -t, --test     Test run, don't actually update the alias"
        echo "  -h, --help     Show this help message"
        echo "  -V, --verbose  Show verbose output"
        echo "  -s, --silent   Suppress all output"
        echo ""
        echo (bold "Usage:")
        echo "update_git_alias [OPTIONS] git_alias new_alias_definition"
        return 0
    end

    # If the cauldron flag is set, then we need to return the Cauldron category
    if set -q _flag_cauldron
        echo $__cauldron_category
        return 0
    end

    # Error handling for empty parameters
    if test -z "$git_alias" -o -z "$new_alias_definition"
        familiar "Error: Both "(bold "git_alias")" and "(bold "new_alias_definition")" must be provided for `update_git_alias` to work."
        return 1
    end

    # Retrieve the existing definition of the alias from the Git configuration
    set -l existing_definition (git config --get alias.$git_alias | string collect)
    # If verbose flag is set, print the existing definition
    if set -q _flag_verbose
        echo (bold "Existing Definition:")
        echo "$existing_definition \n"
    end

    # Remove all newlines and spaces from both definitions for comparison
    set trimmed_existing_definition (string replace -r -a '\n| ' '' -- $existing_definition)
    if set -q _flag_verbose
        echo (bold "Trimmed Existing Definition:" )
        echo "$trimmed_existing_definition \n"
    end

    set new_definition (string replace -r -a '\n| ' '' -- $new_alias_definition)
    if set -q _flag_verbose
        echo (bold "New Definition:")
        echo "$new_definition \n"
    end

    # Update the alias if the existing definition is different from the new one
    if test -z "$trimmed_existing_definition" -o "$trimmed_existing_definition" != "$new_definition"
        if set -q _flag_verbose
            echo "Updating "(bold "$git_alias")" alias as the definition has changed."
        end
        # If the test flag is set, then just print the command that would be run and exit
        if set -q _flag_test
            echo (bold "Test Run:")
            echo "`git "(italic "$git_alias")"` would have been updated"
            return 0
        end

        if not set -q _flag_silent
            # No Test flag, so update the alias
            familiar "🔖 Updating $git_alias Alias 🔖"
        end

        git config --global alias.$git_alias $new_alias_definition
        return 0
    else
        if not set -q _flag_silent
            familiar "🔖 $git_alias already up to date 🔖"
        end
        return 0
    end
end
