#!/usr/bin/env fish

function download_git_dir -d "Download a specific directory from a GitHub repository" -a url -d "The URL of the GitHub repository"
  set -l func_version "1.0.0"
  set -l __category "Setup"

  # Flag options
  set -l options v/version h/help z/cauldron d/destination= s/silent
  argparse -n download_git_dir $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
      echo $func_version
      return 0
  end

  # If they want the cauldron category, return it
  if set -q _flag_cauldron
      echo $__category
      return 0
  end

  # if they asked for help, show it
  if set -q _flag_help
      echo "Download a specific directory from a GitHub repository"
      echo "Usage: download_git_dir [options] url branch"
      echo ""
      echo "Options:"
      echo "  -v, --version      Show the version"
      echo "  -h, --help         Show this help message"
      echo "  -d, --destination  The destination directory to download the files to"
      echo "  -s, --silent       Suppress all output"
      return 0
  end
  
  set -l parts (string split / $url)
  if not count $parts = 7
      familiar "Error: Invalid URL format. Expected URL format: https://github.com/<user>/<repo>/tree/<branch>/<path>"
      return 1
  end
  set user $parts[4]
  set repo $parts[5]
  set branch $parts[7]
  set folder (string join / (string sub -s 8 $parts))

  if test -z "$user" -o -z "$repo" -o -z "$branch" -o -z "$folder"
    familiar "Error: Invalid URL format. Expected URL format: https://github.com/<user>/<repo>/tree/<branch>/<path>"
    return 1
  end

  set strip (math (string length $url) - 5)

  if set -q _flag_destination
    if not test -d $_flag_destination
      mkdir -p $_flag_destination
    end

    set dest $_flag_destination
    if not set -q _flag_silent
      familiar "Downloading $repo from https://github.com/$user/$repo/archive/$branch.tar.gz to $dest"
    end
    curl -L "https://github.com/$user/$repo/archive/$branch.tar.gz" | tar -xv --strip-components=$strip -C $dest "$repo-$branch/$folder"
  else
    if not set -q _flag_silent
      familiar "Downloading $repo from https://github.com/$user/$repo/archive/$branch.tar.gz"
    end
    curl -L "https://github.com/$user/$repo/archive/$branch.tar.gz" | tar -xv --strip-components=$strip "$repo-$branch/$folder"
  end

  if not set -q _flag_silent
    banner "Extraction completed"
  end
end
