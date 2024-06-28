#!/usr/bin/env fish

function cauldron
  set -l func_version "1.0.0"
    
  # Define options that can be passed
  set -l options "v/version" "h/help"
  argparse -n cauldron $options -- $argv

  # If the user passes the -v or --version flag, print the version number
  if set -q _flag_v; or set -q _flag_version
    echo "v$func_version"
    return
  end

  # If the user passes the -h or --help flag, run __cauldron_help
  if set -q _flag_h; or set -q _flag_help
    __cauldron_help
    return
  end

  # If the user passes no flags, run the main function
  f-says "Welcome to Cauldron!"
end
