#!/usr/bin/env fish

function n+
    # Check if there is a package.json file (If not we should prompt them if they are use they meant to use this in this folder)
    if not test -f package.json
        confirm "This folder does not have a package.json file. Are you sure you want to continue?"
        if not test $status -eq 0
            return
        end
    end

    if not set -q cauldron_lang_packman_pref
        set cauldron_lang_packman_pref (jq -r '.cauldron_lang_packman_pref' $CAULDRON_PATH/data/prefs.json)
    end

    if test "$cauldron_lang_packman_pref" = "asdf"
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
    else if test "$cauldron_lang_packman_pref" = "nvm"
        nvm_update_node
    end
end
