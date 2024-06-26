#!/usr/bin/env fish

function install_asdf
    print_center "🎠 Installing ASDF 🎠"
    brew install asdf
    echo -e "\nsource "(brew --prefix asdf)"/libexec/asdf.fish" >>~/.config/fish/config.fish
    source ~/.config/fish/config.fish
    print_center "🎡 Installing ASDF plugin / dependencies 🎡"
    installs dirmngr gpg curl gawk
    asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
    asdf install nodejs latest
    print_center "🤹 ASDF Installed 🤹"

    # Set asdf as the preferred version manager
    set -gx cauldron_packman_pref asdf
end

function asdf_set_node_version
    if test -f .tool-versions
        set asdf_node_version (awk '/nodejs/ {print $2}' .tool-versions)
        asdf local nodejs $asdf_node_version
        asdf install nodejs $asdf_node_version
    else if test -f ~/.tool-versions
        set asdf_node_version (awk '/nodejs/ {print $2}' ~/.tool-versions)
        asdf local nodejs $asdf_node_version
        asdf install nodejs $asdf_node_version
    else
        asdf local nodejs latest
        asdf install nodejs latest
    end

    # Enable corepack
    corepack enable
    # Reshim node
    asdf reshim nodejs

    # Most recent version of yarn
    yarn set version latest

    # Add typescript and node types
    package_manifest_has_typescript
    if test $status -eq 1
        yarn add -D typescript @types/node
    end

    # Add the vscode sdk
    has_node_modules
    if test $status -eq 1
        yarn dlx @yarnpkg/sdks base vscode
    end
end

function nvm_set_node_version
    if test -f .nvmrc
        set nvm_node_version (cat .nvmrc)
    else if test -f ~/.nvmrc
        set nvm_node_version (cat ~/.nvmrc)
    else
        nvm install latest
        nvm use latest
        set -gx nvm_default_version (node --version)
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
    set -gx nvm_default_version $nvm_node_version

    # Enable corepack
    corepack enable

    # Most recent version of yarn
    yarn set version latest

    package_manifest_has_typescript
    if test $status -eq 1
        yarn add -D typescript @types/node
    end

    # Add the vscode sdk
    has_node_modules
    if test $status -eq 1
        yarn dlx @yarnpkg/sdks base vscode
    end
end

function package_manifest_has_typescript
    if test -f package.json
        if cat package.json | jq -e '.devDependencies.typescript' >/dev/null || cat package.json | jq -e '.dependencies.typescript' >/dev/null
            return 0 # success
        else
            return 1 # not found in dependencies
        end
    else
        return 1 # package.json not found
    end
end

function has_node_modules
    if test -d node_modules
        return 0
    else
        return 1
    end
end

function update_repo
    # This script is designed to be run whenever VScode is opened
    # Check if aquarium is installed
    if not type -q aquarium
        print_center "🐠 Filling Aquarium 🐠"
        rm -rf ~/.cache/aquarium
        git clone --depth 1 https://github.com/anandamideio/aquarium.git ~/.cache/aquarium
        pushd ~/.cache/aquarium/bin/
        ./install
        popd
    end

    ## Detect if they have a preferred version manager using the following logic:
    # 1. If they have a .tool-versions file, prefer asdf
    # 2. If they have a .nvmrc file, prefer nvm
    # 3. If asdf is installed, prefer asdf
    # 4. If nvm is installed, prefer nvm
    # 5. If none of the above, we need to prompt the user if we can install asdf
    set -gx cauldron_packman_pref asdf
    if test -f .tool-versions
        set -gx cauldron_packman_pref asdf
    else if test -f .nvmrc
        set -gx cauldron_packman_pref nvm
    else if type -q asdf
        set -gx cauldron_packman_pref asdf
    else if type -q nvm
        set -gx cauldron_packman_pref nvm
    else
        set -gx cauldron_packman_pref none
    end

    # If the pref version manager is none then we need to prompt the user and ask if we can install asdf
    if test $cauldron_packman_pref = none
        print_center "You seem to be missing a version manager for Node. Is it alright if the fish install asdf, and the most current version of node for you?"
        set continue_prompt_result (promptConfirm "This will install asdf, and add the most current version of node, but only alias a Node version for this repo. Continue?")
        if test $continue_prompt_result -eq 0
            # User accepted, proceed with the next steps
            install_asdf
        end
    end

    # If they prefer asdf
    if test $cauldron_packman_pref = asdf
        # First we need to see if they have asdf installed
        if not type -q asdf
            install_asdf
        end
        # Then we need to set the node version
        asdf_set_node_version
    end

    # If they prefer nvm
    if test $cauldron_packman_pref = nvm
        # We need to set the node version
        nvm_set_node_version
    end

    print_separator "⬆️ Updating Branch ⬆️"
    git fetch

    print_separator "🌳 Choose what branch you'd like to work on 🌳"
    git visual-checkout
    git pull

    print_separator "✂️ Trimming uneeded branches ✂️"
    git gone

    print_separator "🆙 Updating your system 🆙"
    sudo apt -y update && sudo apt -y upgrade

    # Update Homebrew
    print_separator "⚗️ Updating Homebrew ⚗️"
    brew update && brew upgrade

    print_separator "🧶 Rolling up most recent ball of yarn 🧶"
    yarn && yarn up

    print_separator "🧶 Upgrading dependencies 🧶"
    yarn upgrade-interactive

    exit 0
end
