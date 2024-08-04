#!/usr/bin/env fish

function __cauldron_aquarium_update_step
    if not functions -q aquarium
        print_center "🐠 Filling Aquarium 🐠"
        # Remove the old aquarium (if it exists)
        if test -d ~/.cache/aquarium
            rm -rf ~/.cache/aquarium
        end

        # Make sure the folder exist
        mkdir -p ~/.cache/aquarium

        # Clone the aquarium repo
        git clone https://github.com/anandamideio/aquarium.git ~/.cache/aquarium

        # Install the aquarium
        pushd ~/.cache/aquarium/bin/
        ./bin/install
        popd
    end
end
