#!/usr/bin/env fish

function fished
  set -l func_version "1.0.0"

  set -l options "v/version" "h/help" "l/list"
  argparse -n fished $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
    echo $func_version
    return 0
  end

  # if they asked for help, show it
  if set -q _flag_help
    echo "fished - Fish function editor"
    echo "Usage: fished [options] [function]"
    echo ""
    echo "Options:"
    echo "  -v, --version  Show the version"
    echo "  -h, --help     Show this help"
    echo "  -l, --list     List all functions"
    return 0
  end

  # if they asked for a list of functions, show it
  if set -q _flag_list
    set -l fns_list (functions -n)

    set -l selected_fn (printf '%s\n' $fns_list | fzf --prompt="Select a function: ")

    # If not selected, return
    if test -z $selected_fn
      echo "No function selected, exiting..."
      return 0
    end

    # Get the directory where the selected function is defined
    set -l function_directory (dirname (functions -D $selected_fn))

    # Move to the functions location
    pushd $function_directory
    code $selected_fn.fish &
    # Return to the previous directory
    popd
    return 0
  end

  # Move to the functions location
  pushd dirname (functions -D $argv)
  code $argv.fish &
  popd
  return 0
end
