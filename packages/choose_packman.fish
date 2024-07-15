#!/usr/bin/env fish

function choose_packman -d 'Choose the package manager you want to use'
  # Version Number
  set -l func_version "1.0.1"
  # Flag options
  set -l options v/version h/help s/silent
  argparse -n choose_packman $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
      echo $func_version
      exit 0
  end

  # if they asked for help just return it
  if set -q _flag_help
      echo "Usage: choose_packman"
      echo "Version: $func_version"
      echo "Choose the (Node) package manager you want to use"
      echo
      echo "Options:"
      echo "  -v, --version  Show the version number"
      echo "  -h, --help     Show this help message"
      echo "  -s, --silent   Only prompt the user if we absolutely can not determine their preferred package manager"
      exit 0
  end

  if not set -q $cauldron_packman_pref; or test $cauldron_packman_pref = "asdf"; or test $cauldron_packman_pref = "nvm"; or test $cauldron_packman_pref = "none"
    ## Detect if they have a preferred version manager using the following logic:
    # 1. If they have a .tool-versions file, prefer asdf
    # 2. If they have a .nvmrc file, prefer nvm
    # 3. If asdf is installed, prefer asdf
    # 4. If nvm is installed, prefer nvm
    # 5. If none of the above, we need to prompt the user if we can install asdf
    set -gx cauldron_packman_pref asdf
    if test -f .tool-versions
        set -gx cauldron_packman_pref asdf
    else if test -f .nvmrc
        set -gx cauldron_packman_pref nvm
    else if type -q asdf
        set -gx cauldron_packman_pref asdf
    else if type -q nvm
        set -gx cauldron_packman_pref nvm
    else
        set -gx cauldron_packman_pref none
    end

    if test $cauldron_packman_pref = "none"
      f-says "Cauldron does not seem to know your preferred Node package manager yet, do you prefer "(bold "asdf")" or "(bold "nvm")"?"
      choose "asdf" "nvm" --height 4 --header "Node PackMan Pref"

      set -gx cauldron_packman_pref $CAULDRON_LAST_CHOICE
    else if test $cauldron_packman_pref = "asdf" && not set -q _flag_silent
      confirm "Cauldron has detected that you prefer asdf as your Node package manager, do you want to change it to nvm?"
      if test $CAULDRON_LAST_CONFIRM = "true"
        set -gx cauldron_packman_pref nvm
      end
    else if test $cauldron_packman_pref = "nvm" && not set -q _flag_silent
      confirm "Cauldron has detected that you prefer nvm as your Node package manager, do you want to change it to asdf?"
      if test $CAULDRON_LAST_CONFIRM = "true"
        set -gx cauldron_packman_pref asdf
      end
    end
  else
    if not set -q _flag_silent
      f-says "You have already set your preferred Node package manager to "(bold $cauldron_packman_pref)", do you want to change it?"
      choose "Yes" "No" --height 4 --header "Change Node PackMan Pref"

      if test $CAULDRON_LAST_CHOICE = "Yes"
        set -eg cauldron_packman_pref
        choose_packman
      end
    end
  end
end
