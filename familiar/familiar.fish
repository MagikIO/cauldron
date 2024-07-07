#!/usr/bin/env fish

function familiar -d "Have your familiar speak it's mind" -a msg
  # Cauldron Stats (Version, Category, and Description)
  set -l func_version "1.0.0"
  set -l __cauldron_category "Familiar"
  # Flag options
  set -l options "v/version" "h/help" "z/cauldron" "t/think" "e/emotion="
  argparse -n familiar $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
      echo $func_version
      return
  end

  # if they asked for help, show it
  if set -q _flag_help
      echo (bold "Familiar") " - v$func_version"
      echo ""
      echo "Have your familiar speak it's mind"
      echo ""
      echo (bold "Options:")
      echo "  -v, --version  Show the version number"
      echo "  -h, --help     Show this help message"
      echo "  -t, --think    Have your familiar think about the message"
      echo "  -e, --emotion  The emotion of your familiar"
      echo ""
      echo (bold "Usage:")
      echo "familiar [OPTIONS] msg"
      return
  end

  # If the cauldron flag is set, then we need to return the Cauldron category
  if set -q _flag_cauldron
      echo $__cauldron_category
      return
  end

  function check-dependencies
    # Check for cowsay
    if not command -q cowsay
        # We should make sure cowsays is installed
      if not command -q cowsay
        if command -q brew
            brew install cowsay
        else if command -q apt
            sudo apt install cowsay -y
        else
            echo "Error: could not install required dependencies -> cowsay"
            return 1
        end
      end
    end
  end

  # We need to make sure `f-says` and `f-thinks` are installed before we can proceed
  if not functions -q f-says
      # We should copy the file from git
      if not command -q wget # Install wget if it is not installed
          if command -q apt
              sudo apt install wget -y
          else
              echo "Error: wget is not installed and we cannot install it."
              return 1
          end
      end
      # So wget `https://raw.githubusercontent.com/MagikIO/cauldron/main/familiar/f-says.fish` to `~/.config/fish/functions/f-says.fish`
      wget -qO ~/.config/fish/functions/f-says.fish https://raw.githubusercontent.com/MagikIO/cauldron/main/familiar/f-says.fish
      # Make sure the file is executable
      chmod +x ~/.config/fish/functions/f-says.fish
      # Source it so we can use it
      source ~/.config/fish/functions/f-says.fish

      # We should make sure cowsays is installed
      check-dependencies
  end
  # Check for f-thinks
  if not functions -q f-thinks
      # We should copy the file from git
      if not command -q wget # Install wget if it is not installed
          if command -q apt
              sudo apt install wget -y
          else
              echo "Error: wget is not installed and we cannot install it."
              return 1
          end
      end
      # So wget `https://raw.githubusercontent.com/MagikIO/cauldron/main/familiar/f-thinks.fish` to `~/.config/fish/functions/f-thinks.fish`
      wget -qO ~/.config/fish/functions/f-thinks.fish https://raw.githubusercontent.com/MagikIO/cauldron/main/familiar/f-thinks.fish
      # Make sure the file is executable
      chmod +x ~/.config/fish/functions/f-thinks.fish
      # Source it so we can use it
      source ~/.config/fish/functions/f-thinks.fish
      # Check dependencies
      check-dependencies
  end

  # Under the hood, for the moment both functions rely on cowsay/cowthink , so we need to make sure that is installed
  check-dependencies

  # Error handling for empty parameters
  if test -z "$msg"
    set ErrMsg (bold "Error")": A message must be provided for me to speak."
    if command -q f-says
        f-says $ErrMsg
    else 
      echo $ErrMsg
    end
    return 1
  end


  # If the think flag is set, then we need to think about the message
  if set -q _flag_think
    # If they provided an emotion, we should use that
    if set -q _flag_emotion
      f-thinks -e $_flag_emotion $msg
    else
      f-thinks $msg
    end
  else
    # IF they provided an emotion, we should use that
    if set -q _flag_emotion
      f-says -e $_flag_emotion $msg
    else
      f-says $msg
    end
  end

  return 0
end
