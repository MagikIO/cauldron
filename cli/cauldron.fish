#!/usr/bin/env fish

function cauldron
  set -l func_version "1.1.0"
  set -l cauldron_category "CLI"
  if not set -q CAULDRON_PATH
    set -Ux CAULDRON_PATH $HOME/.config/cauldron
  end
  if not set -q __CAULDRON_DOCUMENTATION_PATH
    set -Ux __CAULDRON_DOCUMENTATION_PATH $CAULDRON_PATH/docs
  end
  set script_dir (dirname (status --current-filename))
    
  # Define options that can be passed
  set -l options "v/version" "h/help" "D/new-docs=" "z/cauldron" "u/update" "t/tmux="
  argparse -n cauldron $options -- $argv

  # If the user passes the -v or --version flag, print the version number
  if set -q _flag_v; or set -q _flag_version
    echo "v$func_version"
    exit 0
  end

  # If they asked for the category return it
  if set -q _flag_z; or set -q _flag_cauldron
    echo $cauldron_category
    exit 0
  end

  # If the user passes the -h or --help flag, run __cauldron_help
  if set -q _flag_h; or set -q _flag_help
    __cauldron_help
    exit 0
  end

  # If the user passes the -D or --new-docs flag, run __cauldron_install_help
  if set -q _flag_D; or set -q _flag_new-docs
    __cauldron_install_help --src $_flag_D
    exit 0
  end

  # If the user passes the -u or --update flag, run __cauldron_update
  if set -q _flag_u; or set -q _flag_update
    cauldron_update
    exit 0
  end

  # If the user passes the -t or --tmux flag, run cauldron_tmux
  if set -q _flag_t; or set -q _flag_tmux
    switch $_flag_t
      case "install"
        cauldron_tmux --install
      case "modify"
        cauldron_tmux --modify
      case "remove"
        cauldron_tmux --remove
      case "backup"
        cauldron_tmux --backup
      case "restore"
        cauldron_tmux --restore
      case "list"
        cauldron_tmux --list-backups
      case '*'
        # If no specific action or invalid action, show interactive menu
        cauldron_tmux
    end
    exit 0
  end

  # If the user passes no flags, run the main function
  familiar "Welcome to Cauldron!"
end
