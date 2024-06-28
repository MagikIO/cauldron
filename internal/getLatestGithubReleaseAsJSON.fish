#!/usr/bin/env fish

function getLatestGithubReleaseAsJSON --argument target
  # Version Number
  set -l func_version "1.0.0"
  # Flag options
  set -l options v/version h/help s/silent
  argparse -n getLatestGithubReleaseAsJSON $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
    echo $func_version
    return
  end

  # if they asked for help just return it
  if set -q _flag_help
    echo "Usage: getLatestGithubReleaseAsJSON <target>"
    echo "Version: $func_version"
    echo "Get the latest release of a GitHub repository as JSON"
    echo
    echo "Options:"
    echo "  -v, --version  Show the version number"
    echo "  -h, --help     Show this help message"
    echo "  -s, --silent   Don't print the output"
    echo
    echo "Examples:"
    echo "  getLatestGithubReleaseAsJSON MagikIO/cauldron"
    return
  end

  # If they accidentally provided the flag first then return an error
  if string match -q -- "-*" $target
    echo "You must provide a target to get the latest release of"
    return 1
  end

  # If they didn't provide a target then return an error
  if not set -q target
    echo "You must provide a target to get the latest release of"
    return 1
  end

  # if they want to be silent
  if set -q _flag_silent
    curl -sL \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      https://api.github.com/repos/$target/releases/latest
    return
  end

  curl -L \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$target/releases/latest
end
