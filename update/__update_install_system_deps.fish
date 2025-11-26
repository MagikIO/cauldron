#!/usr/bin/env fish

function __update_install_system_deps -d 'Install essential system tools'
  # Installs: brew, pipx, tte, gum, uv, richify
  # Returns: 0 on success

  set -l debug_log "/tmp/cauldron_update_debug.log"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Starting" >> $debug_log

  set -l OS (uname -s)

  # If brew is not installed we need it
  if not command -q brew
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Installing Homebrew" >> $debug_log
    # Run Homebrew installer in explicit subshell to isolate it
    fish -c '/bin/bash -c "(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"' 2>> $debug_log
    set -l brew_status $status
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Homebrew install status: $brew_status" >> $debug_log
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Homebrew already installed" >> $debug_log
  end

  # If pipx not installed 
  if not command -q pipx
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Installing pipx" >> $debug_log
    if test $OS = "Darwin"
      brew install pipx
    else
      sudo apt update
      sudo apt install pipx
    end
    pipx ensurepath
    register-python-argcomplete --shell fish pipx >~/.config/fish/completions/pipx.fish
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: pipx installed" >> $debug_log
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: pipx already installed" >> $debug_log
  end

  # Ensure tte is installed and working (reinstall if broken)
  if not command -q tte
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Installing tte" >> $debug_log
    pipx ensurepath
    pipx install terminaltexteffects --quiet
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: tte installed" >> $debug_log
  else
    # Check if tte actually works (module might be broken)
    if not tte --version >/dev/null 2>&1
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Reinstalling broken tte" >> $debug_log
      pipx reinstall terminaltexteffects --quiet
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: tte reinstalled" >> $debug_log
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: tte already working" >> $debug_log
    end
  end

  if not command -q gum
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Installing gum" >> $debug_log
    brew install gum
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: gum installed" >> $debug_log
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: gum already installed" >> $debug_log
  end

  # Install uv for Python script running (needed for richify)
  if not command -q uv
    echo "→ Installing uv..."
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Installing uv" >> $debug_log
    # Run uv installer in explicit subshell to isolate it
    fish -c 'curl -LsSf https://astral.sh/uv/install.sh | sh' >/dev/null 2>> $debug_log
    set -l uv_status $status
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: uv install status: $uv_status" >> $debug_log
    # Ensure uv is in path for current session
    set -gx PATH $HOME/.cargo/bin $PATH
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: uv already installed" >> $debug_log
  end

  # Install richify for markdown streaming
  if not test -d $HOME/.local/share/richify
    echo "→ Installing richify for enhanced markdown streaming..."
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Installing richify" >> $debug_log
    git clone --depth 1 https://github.com/gianlucatruda/richify.git $HOME/.local/share/richify >/dev/null 2>&1
    chmod +x $HOME/.local/share/richify/richify.py

    # Create symlink in ~/.local/bin
    mkdir -p $HOME/.local/bin
    ln -sf $HOME/.local/share/richify/richify.py $HOME/.local/bin/richify
    echo "  ✓ Richify installed"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: richify installed" >> $debug_log
  else if not command -q richify
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Fixing richify symlink" >> $debug_log
    # Richify directory exists but symlink might be missing
    mkdir -p $HOME/.local/bin
    ln -sf $HOME/.local/share/richify/richify.py $HOME/.local/bin/richify
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: richify symlink fixed" >> $debug_log
  else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: richify already installed" >> $debug_log
  end

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] __update_install_system_deps: Completed successfully" >> $debug_log
  return 0
end
