#!/usr/bin/env fish

function rain-effect
  # Default values
  set rain_colors 00315C 004C8F 0075DB 3F91D9 78B9F2 9AC8F5 B8D8F8 E3EFFC
  set movement_speed "0.1-0.2"
  set rain_symbols "o" "." "," "*" "|"
  set final_gradient_stops 488bff b2e7de 57eaf7
  set final_gradient_steps 12
  set final_gradient_direction "diagonal"
  set easing "IN_QUART"

  # Argument parsing
  set -l current_flag ""
  for arg in $argv
      switch $arg
          case --rain-colors
              set current_flag rain_colors
          case --movement-speed
              set current_flag movement_speed
          case --rain-symbols
              set current_flag rain_symbols
          case --final-gradient-stops
              set current_flag final_gradient_stops
          case --final-gradient-steps
              set current_flag final_gradient_steps
          case --final-gradient-direction
              set current_flag final_gradient_direction
          case "*"
              switch $current_flag
                  case rain_colors
                      set -a rain_colors $arg
                  case movement_speed
                      set movement_speed $arg
                  case rain_symbols
                      set -a rain_symbols $arg
                  case final_gradient_stops
                      set -a final_gradient_stops $arg
                  case final_gradient_steps
                      set -a final_gradient_steps $arg
                  case final_gradient_direction
                      set final_gradient_direction $arg
              end
      end
  end

  # Error handling and validation
  if test (count $rain_colors) -le 0
      echo "Error: At least one rain color must be provided."
      return 1
  end

  if test (count $rain_symbols) -le 0
      echo "Error: At least one rain symbol must be provided."
      return 1
  end

  if test (count $final_gradient_steps) -le 0
      echo "Error: Number of gradient steps must be greater than 0."
      return 1
  end

  # Call the external command with parsed arguments
  command tte rain \
      --rain-colors $rain_colors \
      --movement-speed $movement_speed \
      --rain-symbols $rain_symbols \
      --final-gradient-stops $final_gradient_stops \
      --final-gradient-steps $final_gradient_steps \
      --final-gradient-direction $final_gradient_direction
end
