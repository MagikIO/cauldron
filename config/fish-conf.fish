#!/usr/bin/env fish

function fish-conf -d 'Open the fish configuration file in your default editor'
  # Version Number
  set -l func_version "1.1.0"
  # Flag options
  set -l options "v/version" "h/help" "l/list"
  argparse -n installs $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
    echo $func_version
    return
  end

  # If they asked for help, show it
  if set -q _flag_help
    echo "fish-conf - Open the fish configuration file in your default editor"
    echo "Usage: fish-conf [options]"
    echo ""
    echo "Options:"
    echo "  -v, --version  Show the version number"
    echo "  -h, --help     Show this help message"
    return
  end

  # If they asked for a list of options, show it (in bat)
  if set -q _flag_list
    bat ~/.config/fish/config.fish
  end

  # Make sure they have an editor set or fall back to nano
  if not set -q EDITOR
    # If the user has defined a preferred editor, use that
    if set -q aqua__preferred_editor
      set -g EDITOR $aqua__preferred_editor
    else if type -q code
      set -g EDITOR "code"
    else
      set -g EDITOR "nano"
    end
  end

  # Open the fish configuration file
  $EDITOR ~/.config/fish/config.fish
end
