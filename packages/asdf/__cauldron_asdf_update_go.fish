#!/usr/bin/env fish

function __cauldron_asdf_update_go -d 'Update go to the latest version'
    # Version Number
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help
    argparse -n asdf_update_go $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help just return it
    if set -q _flag_help
        echo (bold "asdf_update_go")
        echo "Version: $func_version"
        echo
        echo "Additional Info:"
        echo "  This will install the latest version of go using asdf"
        echo "  If there is a local go.mod file it will set the local version to the latest available version of Go"
        echo
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        return 0
    end

    if contains golang (asdf plugin list)
        # Returns in the format
        #  22.5.1
        set -l latest (asdf latest golang)
        # Returns in the format
        #  golang          22.5.1          /home/navi/Code/cauldron/.tool-versions
        set -l currentGo (asdf current golang)
        # Remove all the extra spaces
        set currentGo (string replace -r '\s+' ' ' $currentGo)

        # Check if already installed
        if test $latest = (string split " " $currentGo)[2]
            echo (badge red "ASDF") "Go is already up to date"
            return 0
        else
            # Now we prompt the user if they would like to move to this new version?
            confirm "Would you like to update Go to $latest?"
            if $CAULDRON_LAST_CONFIRM = true

                # Install the latest version of Go
                if asdf install golang $latest_version
                    echo (badge red "ASDF") "Successfully installed Go $latest_version"
                else
                    echo "Failed to install Go $latest_version" >&2
                    return 1
                end

                # Set the global version to the latest
                if asdf global golang $latest_version
                    echo (badge red "ASDF") "Go (Global) now at $latest_version"
                else
                    echo "Failed to set global Go version to $latest_version" >&2
                    return 1
                end

                # Check if there is a local go.mod file and set the local version
                if test -f go.mod
                    if asdf local golang $latest_version
                        echo (badge red "ASDF") "Go (Local) now at $latest_version"
                    else
                        echo "Failed to set local Go version to $latest_version" >&2
                        return 1
                    end
                end
            else
                echo "Confirmed, will remain on "(bold $current)"."
                return 0
            end
        end
    end

    echo "Go management not enabled" >&2
    return 1
end
