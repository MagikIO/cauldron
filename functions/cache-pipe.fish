#!/usr/bin/env fish

function cache-pipe -d 'Cache the output of a pipe into a temporary file than move that temp file to overwrite the source of the pipe'
  # Version Number
  set -l func_version "1.0.2"
  # Flag options
  set -l options "v/version" "h/help"
  argparse -n installs $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
    echo $func_version
    return
  end

  # if they asked for help, show it
  if set -q _flag_help
    echo "cache-pipe - Cache the output of a pipe into a temporary file than move that temp file to overwrite the source of the pipe"
    echo "Usage: cache-pipe [options] [file]"
    echo
    echo "Options:"
    echo "  -v, --version  Show version number"
    echo "  -h, --help     Show this help"
    echo
    echo "Examples:"
    echo "  echo 'Hello World' | cache-pipe sample.txt"
    echo "  cat sample.txt # => Hello World"
    return
  end

  set temp_file (mktemp)
  cat > $temp_file
  if test -n "$argv[1]"
    mv $temp_file $argv[1]
  end
end
