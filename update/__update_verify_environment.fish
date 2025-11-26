#!/usr/bin/env fish

function __update_verify_environment -d 'Verify and correct all Cauldron environment variables'
  # ============================================================================
  # VARIABLE VERIFICATION AND CORRECTION
  # Ensure all Cauldron paths are set correctly to prevent confusion between
  # install directory (~/.cauldron) and config directory (~/.config/cauldron)
  # ============================================================================

  # Set install directory (where git repo lives)
  if set -qg CAULDRON_PATH
    set -eg CAULDRON_PATH
  end

  if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.cauldron
  else if test "$CAULDRON_PATH" != "$HOME/.cauldron"
    # Fix incorrect CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.cauldron
  end

  # Make sure the install path exists
  if not test -d $CAULDRON_PATH
    echo "Error: Cauldron installation directory not found at $CAULDRON_PATH"
    echo "You must have Cauldron installed to update it, please run the install script instead"
    return 1
  end

  # Set config directory (where user data lives)
  if set -qg CAULDRON_CONFIG_DIR
    set -eg CAULDRON_CONFIG_DIR
  end

  if not set -q CAULDRON_CONFIG_DIR
    set -Ux CAULDRON_CONFIG_DIR $HOME/.config/cauldron
  else if test "$CAULDRON_CONFIG_DIR" != "$HOME/.config/cauldron"
    # Fix incorrect CAULDRON_CONFIG_DIR
    set -Ux CAULDRON_CONFIG_DIR $HOME/.config/cauldron
  end

  # Create config directory if it doesn't exist
  if not test -d $CAULDRON_CONFIG_DIR
    mkdir -p $CAULDRON_CONFIG_DIR
  end

  # Verify other required variables
  if not set -q __CAULDRON_DOCUMENTATION_PATH
    set -Ux __CAULDRON_DOCUMENTATION_PATH $CAULDRON_PATH/docs
  end

  if not test -d $__CAULDRON_DOCUMENTATION_PATH
    mkdir -p $__CAULDRON_DOCUMENTATION_PATH
  end

  if not set -q CAULDRON_GIT_REPO
    set -Ux CAULDRON_GIT_REPO "https://github.com/MagikIO/cauldron.git"
  end

  # Database should be in config directory, NOT install directory
  if set -qg CAULDRON_DATABASE
    set -eg CAULDRON_DATABASE
  end

  if not set -q CAULDRON_DATABASE
    set -Ux CAULDRON_DATABASE $CAULDRON_CONFIG_DIR/data/cauldron.db
  else if test "$CAULDRON_DATABASE" != "$CAULDRON_CONFIG_DIR/data/cauldron.db"
    # Fix incorrect database path
    set -Ux CAULDRON_DATABASE $CAULDRON_CONFIG_DIR/data/cauldron.db
  end

  if not test -f $CAULDRON_DATABASE
    mkdir -p $CAULDRON_CONFIG_DIR/data
    touch $CAULDRON_DATABASE
  end

  # Data files should be in config directory
  if set -qg CAULDRON_PALETTES
    set -eg CAULDRON_PALETTES
  end

  if not set -q CAULDRON_PALETTES
    set -Ux CAULDRON_PALETTES $CAULDRON_CONFIG_DIR/data/palettes.json
  else if test "$CAULDRON_PALETTES" != "$CAULDRON_CONFIG_DIR/data/palettes.json"
    set -Ux CAULDRON_PALETTES $CAULDRON_CONFIG_DIR/data/palettes.json
  end

  if set -qg CAULDRON_SPINNERS
    set -eg CAULDRON_SPINNERS
  end

  if not set -q CAULDRON_SPINNERS
    set -Ux CAULDRON_SPINNERS $CAULDRON_CONFIG_DIR/data/spinners.json
  else if test "$CAULDRON_SPINNERS" != "$CAULDRON_CONFIG_DIR/data/spinners.json"
    set -Ux CAULDRON_SPINNERS $CAULDRON_CONFIG_DIR/data/spinners.json
  end

  # Internal tools are in install directory
  if not set -q CAULDRON_INTERNAL_TOOLS
    set -Ux CAULDRON_INTERNAL_TOOLS $CAULDRON_PATH/tools
  else if test "$CAULDRON_INTERNAL_TOOLS" != "$CAULDRON_PATH/tools"
    set -Ux CAULDRON_INTERNAL_TOOLS $CAULDRON_PATH/tools
  end

  if not test -d $CAULDRON_INTERNAL_TOOLS
    mkdir -p $CAULDRON_INTERNAL_TOOLS
  end

  return 0
end
