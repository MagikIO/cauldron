#!/usr/bin/env fish

function n+ --description 'Get Node and Yarn to the lastest version (Using asdf)'
    # Check if there is a package.json file (If not we should prompt them if they are use they meant to use this in this folder)
    if test ! -f package.json
        confirm "This folder does not have a package.json file. Are you sure you want to continue?"
        if not test $status -eq 0
            return
        end
    end

    if test $cauldron_packman_pref = "asdf"
        asdf_update_node
    else if test $cauldron_packman_pref = "nvm"
        nvm_update_node
    end

    yarn upgrade-interactive

    if test $cauldron_packman_pref = "asdf"
      asdf reshim nodejs
    else if test $cauldron_packman_pref = "nvm"
      nvm_update_node
    end
    
    $argv
end
