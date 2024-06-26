#!/usr/bin/env fish

function nvm_update_node
    if test -f .nvmrc
        set nvm_node_version (cat .nvmrc)
    else if test -f ~/.nvmrc
        set nvm_node_version (cat ~/.nvmrc)
    else
        nvm install latest
        nvm use latest
        set -Ux nvm_default_version (node --version)
    end

    # Install the version of node specified in the .nvmrc file, if it's not already installed
    if not nvm list | grep -q $nvm_node_version
        nvm install $nvm_node_version
    end

    # Set the node version we want to use
    nvm use $nvm_node_version

    # Alias the default version of node
    nvm alias default $nvm_node_version

    # Set the default version of node
    set -Ux nvm_default_version $nvm_node_version

    # Set the default version of node
    nvm use default
end
