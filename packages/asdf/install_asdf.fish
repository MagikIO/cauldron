#!/usr/bin/env fish

function install_asdf
  if not command -q asdf
    installs curl git gpg gawk dirmngr
    print_center "🎠 Installing ASDF 🎠";
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0;
    echo -e "\nsource ~/.asdf/asdf.fish" >>~/.config/fish/config.fish;
    source ~/.config/fish/config.fish;
    mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions;
    # Now we enable legacy version file by adding `legacy_version_file = yes` to the `~/.asdfrc` file
    echo "\nlegacy_version_file = yes" >>~/.asdfrc;

    print_center "🤹 ASDF Installed 🤹"

    # Set asdf as the preferred version manager
    set -gx cauldron_packman_pref asdf
  end

  # Now we need to see which plugins are installed, and install the ones the user would like
  if not contains nodejs (asdf plugin list)
    # Prompt the user and ask if they would like to install nodejs
    confirm "Would you like cauldron to install the Node.js for you? (This will install the nodejs plugin for asdf)"
    # Now we check `CAULDRON_LAST_CONFIRM` to see if the user said yes
    if test $CAULDRON_LAST_CONFIRM = true
      asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git;
      asdf install nodejs latest;
      asdf global nodejs latest;
      corepack enable;
      asdf reshim nodejs;
      yarn set version stable;
    end
  end

  exit 0
end
