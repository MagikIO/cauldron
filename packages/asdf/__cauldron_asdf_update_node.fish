#!/usr/bin/env fish

function __cauldron_asdf_update_node -d 'Update Node.js to the latest version'
    # Version Number
    set -l func_version "1.1.0"

    # Flag options
    set -l options v/version h/help
    argparse -n asdf_update_node $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help just return it
    if set -q _flag_help
        echo (bold "asdf_update_node")
        echo "Version: $func_version"
        echo
        echo "Additional Info:"
        echo "  This will install the latest version of Node.js using asdf"
        echo "  If there is a local package.json file it will set the local version to the latest available version of Node.js"
        echo
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        exit 0
    end

    if not contains nodejs (asdf plugin list)
        asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    end

    if contains nodejs (asdf plugin list)
        # Returns in the format
        #  22.5.1
        set -l latest (asdf latest nodejs)
        # Returns in the format
        #  nodejs          22.5.1          /home/navi/Code/cauldron/.tool-versions
        set -l currentNode (asdf current nodejs)
        # Remove all the extra spaces
        set currentNode (string replace -r '\s+' ' ' $currentNode)


        # Check if already installed
        if test $latest = (string split " " $currentNode)[2]
            echo (badge red "ASDF") "Node.js is already up to date"
            return 0
        else
            # Now we prompt the user if they would like to move to this new version?
            confirm "Would you like to update Node.js to v$latest?"
            if $CAULDRON_LAST_CONFIRM = true

                # Install the latest version of Node.js
                asdf install nodejs $latest
                if test $status -eq 1
                    echo "Failed to install Node.js v$latest" >&2
                    return 1
                end

                # Set the global version to the latest
                if asdf global nodejs $latest
                    echo (badge red "ASDF") "Node.js (Global) now at v$latest"
                else
                    echo "Failed to set global Node.js version to v$latest" >&2
                end

                # Only set the local version if there is a package.json file
                if test -f package.json
                    asdf local nodejs $latest
                    echo (badge red "ASDF") "Node.js (Local) now at v$latest"
                    corepack enable
                    asdf reshim nodejs

                    # Update the package manager
                    # Check out nodejs package manager preference via $cauldron_node_packman_pref
                    if test $cauldron_node_packman_pref = pnpm
                        corepack enable pnpm
                        corepack use pnpm@latest
                        asdf reshim nodejs
                        pnpm add tsx@latest -g
                        # Rebuild the packages list to ensure everything is up to date
                        pnpm i
                    else if test $cauldron_node_packman_pref = yarn
                        corepack enable yarn
                        yarn set version stable
                        asdf reshim nodejs
                        npm i tsx@latest -g

                        # Rebuild the packages list to ensure everything is up to date
                        yarn
                    else if test $cauldron_node_packman_pref = npm
                        npm i npm@latest -g
                        npm i tsx@latest -g
                        asdf reshim nodejs
                        # Rebuid the packages list to ensure everything is up to date
                        npm i
                    end


                end
            end
        end
    end
end
