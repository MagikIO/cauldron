#!/usr/bin/env fish

function orbiting-volley-effect
  # Default values
  set -l top_launcher_symbol █
  set -l right_launcher_symbol █
  set -l bottom_launcher_symbol █
  set -l left_launcher_symbol █
  set -l final_gradient_stops 5A639C E2BBE9
  set -l final_gradient_steps 12
  set -l final_gradient_direction radial
  set -l launcher_movement_speed 0.5
  set -l character_movement_speed 1
  set -l volley_size 0.03
  set -l launch_delay 30
  set -l character_easing OUT_SINE

  # Argument parsing
  set -l current_flag ""
  for arg in $argv
      switch $arg
          case --top-launcher-symbol
              set current_flag top_launcher_symbol
          case --right-launcher-symbol
              set current_flag right_launcher_symbol
          case --bottom-launcher-symbol
              set current_flag bottom_launcher_symbol
          case --left-launcher-symbol
              set current_flag left_launcher_symbol
          case --final-gradient-stops
              set current_flag final_gradient_stops
          case --final-gradient-steps
              set current_flag final_gradient_steps
          case --final-gradient-direction
              set current_flag final_gradient_direction
          case --launcher-movement-speed
              set current_flag launcher_movement_speed
          case --character-movement-speed
              set current_flag character_movement_speed
          case --volley-size
              set current_flag volley_size
          case --launch-delay
              set current_flag launch_delay
          case --character-easing
              set current_flag character_easing
          case "*"
              switch $current_flag
                  case top_launcher_symbol
                      set top_launcher_symbol $arg
                  case right_launcher_symbol
                      set right_launcher_symbol $arg
                  case bottom_launcher_symbol
                      set bottom_launcher_symbol $arg
                  case left_launcher_symbol
                      set left_launcher_symbol $arg
                  case final_gradient_stops
                      set -a final_gradient_stops $arg
                  case final_gradient_steps
                      set -a final_gradient_steps $arg
                  case final_gradient_direction
                      set final_gradient_direction $arg
                  case launcher_movement_speed
                      set launcher_movement_speed $arg
                  case character_movement_speed
                      set character_movement_speed $arg
                  case volley_size
                      set volley_size $arg
                  case launch_delay
                      set launch_delay $arg
                  case character_easing
                      set character_easing $arg
              end
      end
  end

  # Error handling and validation
  if test (count $final_gradient_steps) -le 0
      echo "Error: Number of gradient steps must be greater than 0."
      return 1
  end

  if test $volley_size -lt 0 -o $volley_size -gt 1
      echo "Error: Volley size must be between 0 and 1."
      return 1
  end

  if test $launch_delay -lt 0
      echo "Error: Launch delay must be greater than or equal to 0."
      return 1
  end

  # Call the external command with parsed arguments
  command tte orbittingvolley \
      --top-launcher-symbol $top_launcher_symbol \
      --right-launcher-symbol $right_launcher_symbol \
      --bottom-launcher-symbol $bottom_launcher_symbol \
      --left-launcher-symbol $left_launcher_symbol \
      --final-gradient-stops $final_gradient_stops \
      --final-gradient-steps $final_gradient_steps \
      --final-gradient-direction $final_gradient_direction \
      --launcher-movement-speed $launcher_movement_speed \
      --character-movement-speed $character_movement_speed \
      --volley-size $volley_size \
      --launch-delay $launch_delay \
      --character-easing $character_easing
end
