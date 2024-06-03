function roll-yarn
    if not type -q asdf
        echo "asdf is not installed. Please install it first."
        return 1
    end

    say "Getting yarn ready for you..."

    set nodejs_version $CAULDRON_PREFERRED_NODEJS_VERSION
    # Now we need to look for a local nodejs version (.tool-versions)
    if test -e ./.tool-versions
        # If they already have a nodejs version we need to install it
        set nodejs_version (awk '/nodejs/ {print $2}' ./.tool-versions)
    end

    # If: `nodejs_version` is still empty & there's no local file
    # Then: we need to see if they have a global one
    if test -e ~/.tool-versions -a -z "$nodejs_version"
        set nodejs_version (awk '/nodejs/ {print $2}' ~/.tool-versions)
    end

    # If there's no global file we need to install the latest nodejs version
    if not test -e ~/.tool-versions
        set nodejs_version latest

        # Make sure the asdf node plugin exist
        if not asdf plugin list | grep -q nodejs
            asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
        end

        # Install the latest nodejs version
        asdf install nodejs $nodejs_version

        # Set the nodejs version as the global version
        asdf global nodejs $nodejs_version
    end

    # Make the local nodejs version the same as the global one
    asdf local nodejs $nodejs_version

    # Make sure they have a package.json file
    if not test -e package.json
        touch package.json
    end

    # Now we need to add the packageManager field with the value of yarn
    # Otherwise this will prompt the user about installing an old version of yarn before we update yarn
    jq '. + { "packageManager": "yarn@4.2.2" }' package.json >package.json.tmp && mv package.json.tmp package.json

    # Enable corepack
    corepack enable
    # Now we have to reshim so it knows about yarn
    asdf reshim nodejs
    # Now we need to move to newest version of yarn
    yarn set version stable
    # Reshim again
    asdf reshim nodejs

    # Now we need to ask them what they prefer for their nodeLinker (pnp, node-modules, etc)
    echo "What nodeLinker do you prefer? (pnp, pnpm, node-modules)"
    choose pnp pnpm node-modules

    # We create the config yaml file
    touch .yarnrc.yml

    # Then we add the nodeLinker to the file
    echo "nodeLinker: $CAULDRON_LAST_CHOICE" >>.yarnrc.yml

    # Test if .gitignore exists, if not create it
    if not test -e .gitignore
        touch .gitignore
    end

    # Then we add the yarnrc file to the gitignore
    echo ".yarnrc.yml" >>.gitignore

    # If they chose 'node-modules' we need to add the node_modules to the gitignore
    if test "$CAULDRON_LAST_CHOICE" = node-modules
        echo node_modules >>.gitignore
    end

    # If they chose 'pnp' we need to add the .pnp.cjs to the gitignore
    if test "$CAULDRON_LAST_CHOICE" = pnp
        echo ".pnp.cjs" >>.gitignore
    end

    # If they chose 'pnpm' we need to add the .pnpm to the gitignore
    if test "$CAULDRON_LAST_CHOICE" = pnpm
        echo ".pnpm" >>.gitignore
    end

    # Then if their package.json file has dependencies or devDependencies we need to install them
    if test -e package.json
        # Look if theirs dependencies or devDependencies keys using jq
        set dependencies (jq -e '.dependencies' package.json >/dev/null)
        if jq -e '.dependencies' package.json >/dev/null
            shiny spin --spinner moon --title "Installing.." -- yarn install
        end
    end

    say "Yarn is ready for you!"

    return 0
end
