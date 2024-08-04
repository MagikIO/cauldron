#!/usr/bin/env fish

function __cauldron_asdf_update_ruby -d 'Update Ruby to the latest version'
    # Version Number
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help
    argparse -n asdf_update_ruby $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help just return it
    if set -q _flag_help
        echo (bold "asdf_update_ruby")
        echo "Version: $func_version"
        echo
        echo "Additional Info:"
        echo "  This will install the latest version of Ruby using asdf"
        echo "  If there is a local .ruby-version or Gemfile file it will set the local version to the latest available version of Ruby"
        echo
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        return 0
    end

    if contains ruby (asdf plugin list)
        # Returns in the format
        #  22.5.1
        set -l latest (asdf latest ruby)
        # Returns in the format
        #  ruby          22.5.1          /home/navi/Code/cauldron/.tool-versions
        set -l currentRuby (asdf current ruby)
        # Remove all the extra spaces
        set currentRuby (string replace -r '\s+' ' ' $currentRuby)

        # Check if already installed
        if test $latest = (string split " " $currentRuby)[2]
            echo (badge green "ASDF") "Ruby is already up to date"
            return 0
        else
            # Now we prompt the user if they would like to move to this new version?
            confirm "Would you like to update Ruby to $latest?"
            if $CAULDRON_LAST_CONFIRM = true

                # Install the latest version of Ruby
                if asdf install ruby $latest
                    echo (badge purple SUCCESS) "Successfully installed Ruby $latest"
                else
                    echo "Failed to install Ruby $latest" >&2
                    return 1
                end

                # Set the global version to the latest
                if asdf global ruby $latest
                    echo (badge purple SUCCESS) "Ruby (Global) now at $latest"
                else
                    echo "Failed to set Ruby $latest as the global version" >&2
                    return 1
                end

                # Check if there is a local .ruby-version or Gemfile file and set the local version
                if test -f .ruby-version; or test -f Gemfile
                    if asdf local ruby $latest
                        echo (badge purple SUCCESS) "Ruby (Local) now at $latest"
                    else
                        echo "Failed to set Ruby $latest as the local version" >&2
                        return 1
                    end
                end
            end
        end
    else
        echo "Ruby management not enabled" >&2
        return 1
    end
end
