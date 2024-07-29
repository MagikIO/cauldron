#!/usr/bin/env fish

function asdf_update_node -d 'Update Node.js to the latest version'
  # Version Number
  set -l func_version "1.0.1"
  # Flag options
  set -l options v/version h/help
  argparse -n asdf_update_node $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
      echo $func_version
      exit 0
  end

  # if they asked for help just return it
  if set -q _flag_help
      echo "Usage: asdf_update_node"
      echo "Version: $func_version"
      echo "Update Node.js to the latest version"
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
    asdf install nodejs latest
    asdf global nodejs latest
    corepack enable
    asdf reshim nodejs
    yarn set version stable

    # Only set the local version if there is a package.json file
    if test -f package.json
      asdf local nodejs latest
    end

    # Add back compatibility layers
    npm i tsx@latest -g
    asdf reshim nodejs
  end
end
