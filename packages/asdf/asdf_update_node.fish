#!/usr/bin/env fish

function asdf_update_node -d 'Update Node.js to the latest version'
    asdf install nodejs latest
    asdf global nodejs latest
    corepack enable
    asdf reshim nodejs

    # Only set the local version if there is a package.json file
    if test -f package.json
        asdf local nodejs latest
        yarn set version stable
        asdf reshim nodejs
    end

    # Add back compatibility layers
    npm i tsx@latest -g
    asdf reshim nodejs
end
