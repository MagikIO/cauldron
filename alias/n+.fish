#!/usr/bin/env fish

function n+ --description 'Get Node and Yarn to the lastest version (Using abbr)'
    # Check if there is a package.json file (If not we should prompt them if they are use they meant to use this in this folder)
    if test ! -f package.json
        confirm "This folder does not have a package.json file. Are you sure you want to continue?"
        if not test $status -eq 0
            return
        end
    end



    asdf install nodejs latest
    asdf global nodejs latest
    asdf local nodejs latest
    corepack enable
    asdf reshim nodejs
    yarn set version stable
    asdf reshim nodejs
    yarn
    npm i tsx@latest -g
    yarn upgrade-interactive
    asdf reshim nodejs
    $argv
end
