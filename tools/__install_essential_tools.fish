#!/usr/bin/env fish

function __install_essential_tools
  set OS (uname -s)

  # If brew is not installed we need it
  if not command -q brew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  end

  # If pipx not installed 
  if not command -q pipx
    if test $OS = "Darwin"
      brew install pipx
    else
      sudo apt update
      sudo apt install pipx
    end
      pipx ensurepath
      register-python-argcomplete --shell fish pipx >~/.config/fish/completions/pipx.fish
      pipx install terminaltexteffects --quiet
  end

  if not command -q gum
    brew install gum
  end

  # As long as their is a dependencies.json file we will install the dependencies
  if test -f $CAULDRON_PATH/dependencies.json
    set apt_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.apt[]')
    set brew_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.brew[]')
    set snap_dependencies (cat $CAULDRON_PATH/dependencies.json | jq -r '.snap[]')

    for dep in $apt_dependencies
      gum spin --spinner moon --title "Installing $dep..." -- fish -c "if not command -q \$dep; sudo apt install \$dep -y; end; if not command -q \$dep; set ERROR_MSG \"Failed to install: \$dep using the command 'sudo apt install \$dep -y'\"; echo \$ERROR_MSG >> \$CAULDRON_PATH/logs/cauldron.log; else; set VERSION (apt show \$dep | grep \"Version\" | cut -d \":\" -f 2 | tr -d \" \"); set DATE (date); sqlite3 \$CAULDRON_DATABASE \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('\$$dep', '\$$VERSION', '\$$DATE')\"; end"
    end
    
    for dep in $brew_dependencies
      gum spin --spinner moon --title "Installing $dep..." -- fish -c "if not command -q \$dep; brew install \$dep; end; if not command -q \$dep; set ERROR_MSG \"Failed to install: \$dep using the command 'brew install \$dep'\"; echo \$ERROR_MSG >> \$CAULDRON_PATH/logs/cauldron.log; else; set VERSION (brew info \$dep | grep \"version\" | cut -d \" \" -f 1 | tr -d \"version:\"); set DATE (date); sqlite3 \$CAULDRON_DATABASE \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('\$$dep', '\$$VERSION', '\$$DATE');\"; end"
    end
    
    for dep in $snap_dependencies
      gum spin --spinner moon --title "Installing $dep..." -- fish -c "if not command -q \$dep; sudo snap install \$dep; end; if not command -q \$dep; set ERROR_MSG \"Failed to install: \$dep using the command 'sudo snap install \$dep'\"; echo \$ERROR_MSG >> \$CAULDRON_PATH/logs/cauldron.log; else; set VERSION (snap info \$dep | grep \"installed\" | cut -d \":\" -f 2 | tr -d \" \"); set DATE (date); sqlite3 \$CAULDRON_DATABASE \"INSERT OR REPLACE INTO dependencies (name, version, date) VALUES ('\$$dep', '\$$VERSION', '\$$DATE');\"; end"
    end
  end
end
