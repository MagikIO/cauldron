#!/usr/bin/env fish

function iterate -d "Move your npm package forward, and post it up"
  # Version Number
  set -l func_version "1.0.0"
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
    echo "iterate - Move your npm package forward, and post it up"
    echo "Usage: iterate [options] [file]"
    echo
    echo "Options:"
    echo "  -v, --version  Show version number"
    echo "  -h, --help     Show this help"
    echo
    echo "Examples:"
    echo "  iterate"
    return
  end

  # First we need to make sure there is a local package.json
  if not test -f package.json
    # check if the f-says command is available
    if type -q f-says
      f-says "Sorry, I can't increment a version if there is no package.json"
      return
    else
      echo "No package.json found"
      return
    end
  end

  # We need to check if this repo has a cliff.toml file and git cliff is installed
  if not test -f cliff.toml
    # check if the f-says command is available
    if type -q f-says
      f-says "Is it alright for me to make a cliff.toml file, so I can autogenerate changelogs for you in the future?"
    else
      echo "No cliff.toml found, we you like one to be created? (This will allow us to autogenerate CHANGELOG.md files for you)"
    end
    confirm "Generate a cliff.toml file?"

    # If the user cancels, we need to exit
    if test $status -ne 0
      return
    end

    # If $CAULDRON_LAST_CONFIRM === "true"
    if test $CAULDRON_LAST_CONFIRM = "true"
      # We need to see if git cliff is installed
      if not type -q git-cliff
        # Make sure rust / cargo is installed / up to date
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        cargo install git-cliff
      end

      # create cliff.toml with github-keepachangelog template
      git cliff --init github-keepachangelog
    end
  end

  # Now we need the current version
  set current_version (jq -r '.version' package.json)
  set current_version_array (string split . $current_version)
  set cur_major $current_version_array[1]
  set cur_minor $current_version_array[2]
  set cur_patch $current_version_array[3]

  # Calculate the next version numbers
  set next_patch (math $cur_patch + 1)
  set next_minor (math $cur_minor + 1)
  set next_major (math $cur_major + 1)

  # Prompt the user to find what version they want to move to, previewing the version increase
  choose "Patch ($cur_major.$cur_minor.$cur_patch -> $cur_major.$cur_minor.$next_patch)" "Minor ($cur_major.$cur_minor.$cur_patch -> $cur_major.$next_minor.0)" "Major ($cur_major.$cur_minor.$cur_patch -> $next_major.0.0)"

  # If the user cancels, we need to exit
  if test $status -ne 0
    return
  end

  # Now we check what the last choice was 
  switch $CAULDRON_LAST_CHOICE
    case "Patch ($cur_major.$cur_minor.$cur_patch -> $cur_major.$cur_minor.$next_patch)"
      set new_version "patch"
    case "Minor ($cur_major.$cur_minor.$cur_patch -> $cur_major.$next_minor.0)"
      set new_version "minor"
    case "Major ($cur_major.$cur_minor.$cur_patch -> $next_major.0.0)"
      set new_version "major"
  end

  # We need to detect if the users main branch is called main or master
  # So we will use the command "git branch -l master main "
  # This will out put something like:
  # * main
  #
  # So we just need to get the first word, minus the *
  set main_branch (git branch -l master main | string match -r 'main|master' | string trim)

  # If cliff.toml now exist we should generate changelogs for them
  if test -f cliff.toml
    # If they already have a changelog, we need to update it
    if test -f CHANGELOG.md
      git cliff -o CHANGELOG.md
    else
      git cliff
    end
    git cliff -o CHANGELOG.md

    # Now we need to add the changelog to the commit
    git add CHANGELOG.md
    git commit -m "chore: update changelog"
    git push origin $main_branch
  end

  npm version $new_version
  git push origin $main_branch --tags
  npm publish --access public
end
