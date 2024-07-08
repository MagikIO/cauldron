#!/usr/bin/env fish

function detectOS
  set -l func_version "1.0.0"
  set -l cauldron_category "Internal"

  # Flag options
  set options v/version h/help z/cauldron V/verbose
  argparse -n detectOS $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
    echo $func_version
    return 0
  end

  # if they asked for help, show it
  if set -q _flag_help
    echo "Detect the Operating System"
    echo "Usage: detectOS [options]"
    echo ""
    echo "Options:"
    echo "  -v, --version  Show the version"
    echo "  -h, --help     Show this help message"
    echo "  -z, --cauldron Show the cauldron category"
    echo "  -V, --verbose  Show the verbose output"
    return 0
  end

  if set -q _flag_cauldron
    echo "Category: $cauldron_category"
  end

  # Detecting macOS
  if test (uname -s) = "Darwin"
    echo "Operating System: macOS"
    return 0
  else
    # Detecting Linux distributions
    set os_name (uname -o)

    switch $os_name
      case "GNU/Linux"
        # Further differentiation between Debian/Ubuntu and other Linux distros
        set pretty_name (cat /etc/os-release | grep "PRETTY_NAME" | cut -d "=" -f 2 | tr -d '"')
        set os_id (cat /etc/os-release | grep "^ID=" | cut -d "=" -f 2)
        # If verbose display pretty name
        if set -q _flag_verbose
          echo "Operating System: $pretty_name"
        else
          echo "Operating System: $os_id"
        end
      case BSD
        echo "Operating System: FreeBSD"
      case Solaris
        echo "Operating System: Solaris"
      case *
        echo "Unknown Operating System"
    end
  end
end
