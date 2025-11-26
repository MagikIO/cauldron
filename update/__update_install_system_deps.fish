#!/usr/bin/env fish

function __update_install_system_deps -d 'Install essential system tools'
  # Installs: brew, pipx, tte, gum, uv, richify
  # Returns: 0 on success

  set -l OS (uname -s)

  # If brew is not installed we need it
  if not command -q brew
    /bin/bash -c "(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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
  end

  # Ensure tte is installed and working (reinstall if broken)
  if not command -q tte
    pipx ensurepath
    pipx install terminaltexteffects --quiet
  else
    # Check if tte actually works (module might be broken)
    if not tte --version >/dev/null 2>&1
      pipx reinstall terminaltexteffects --quiet
    end
  end

  if not command -q gum
    brew install gum
  end

  # Install uv for Python script running (needed for richify)
  if not command -q uv
    echo "→ Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1
    # Ensure uv is in path for current session
    set -gx PATH $HOME/.cargo/bin $PATH
  end

  # Install richify for markdown streaming
  if not test -d $HOME/.local/share/richify
    echo "→ Installing richify for enhanced markdown streaming..."
    git clone --depth 1 https://github.com/gianlucatruda/richify.git $HOME/.local/share/richify >/dev/null 2>&1
    chmod +x $HOME/.local/share/richify/richify.py

    # Create symlink in ~/.local/bin
    mkdir -p $HOME/.local/bin
    ln -sf $HOME/.local/share/richify/richify.py $HOME/.local/bin/richify
    echo "  ✓ Richify installed"
  else if not command -q richify
    # Richify directory exists but symlink might be missing
    mkdir -p $HOME/.local/bin
    ln -sf $HOME/.local/share/richify/richify.py $HOME/.local/bin/richify
  end

  return 0
end
