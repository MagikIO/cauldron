#!/usr/bin/env fish

function familiars
  # Cauldron Stats (Version, Category, and Description)
  set func_version "1.0.0"
  set __cauldron_category "Familiar"
  # Flag options
  set options "v/version" "h/help" "z/cauldron" "r/rename"
  argparse -n familiars $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
      echo $func_version
      return
  end

  # if they asked for help, show it
  if set -q _flag_help
      echo (bold "familiars") " - v$func_version"
      echo ""
      echo "View, choose, and rename your familiar"
      echo ""
      echo (bold "Options:")
      echo "  -v, --version  Show the version number"
      echo "  -h, --help     Show this help message"
      echo "  -r, --rename   Rename your familiar"
      echo "  -z, --cauldron Show the category of the function"
      echo ""
      echo (bold "Usage:")
      echo "familiars [OPTIONS]"
      return
  end

  if not set -q _flag_rename
    $CAULDRON_PATH/tools/__list_familiars.fish
  end

  # We will use the `new-name` fish function which returns a first and last name,
  # Then split the space, and use the first word
  set -gx CAULDRON_FAMILIAR_NAME (new-name | string split " ")[1]
  # Now we can use the familiar
  f-says "Hello, $username! I am "(bold $CAULDRON_FAMILIAR_NAME)", your new familiar!/n You can press 'r' to roll a new name for me, 'e' to edit my name, or 'q' if you're happy with the name and want to dismiss me for now." | rainbow-fish

  set HALF_TERM_WIDTH (math (tput cols) / 2)

  # Now we prompt the user to press 'r' to roll a new name, 'e' to edit the name, or 'q' to quit
  while true
    box $CAULDRON_FAMILIAR_NAME -w $HALF_TERM_WIDTH
    read -l -P "Press 'r' to roll a new name, 'e' to edit my name, or 'q' to quit: [r/e/q]" action
    switch $action
      case r
        clear;
        set -gx CAULDRON_FAMILIAR_NAME (new-name | string split " ")[1]
        f-says "Hello, $username! I am "(bold $CAULDRON_FAMILIAR_NAME)", your new familiar!/n You can press 'r' to roll a new name for me, 'e' to edit my name, or 'q' if you're happy with the name and want to dismiss me for now." | rainbow-fish
      case e
        read -l -P "Enter a new name for me: " new_name
        set -Ux CAULDRON_FAMILIAR_NAME $new_name
        f-says "Hello, $username! I am $CAULDRON_FAMILIAR_NAME, your new familiar!/n You can press 'r' to roll a new name for me, 'e' to edit my name, or 'q' if you're happy with the name and want to dismiss me for now." | rainbow-fish
      case q
        break
    end
  end

    banner "New Familiar!"
end
