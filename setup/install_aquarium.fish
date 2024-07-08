#!/usr/bin/env fish

function install_aquarium -d 'Install the Aquarium CLI'
  # Check if aquarium is installed
  if not functions -q aquarium
    print_center "🐠 Filling Aquarium 🐠"
    rm -rf ~/.cache/aquarium
    git clone --depth 1 https://github.com/anandamideio/aquarium.git ~/.cache/aquarium
    pushd ~/.cache/aquarium/bin/
    ./install
    popd
  end
end
