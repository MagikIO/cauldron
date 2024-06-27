#!/usr/bin/env fish

function vhs-effect
    # Default values
    set -l final_gradient_stops ab48ff e7b2b2 fffebd
    set -l final_gradient_steps 12
    set -l final_gradient_direction vertical
    set -l glitch_line_colors ffffff ff0000 00ff00 0000ff ffffff
    set -l glitch_wave_colors ffffff ff0000 00ff00 0000ff ffffff
    set -l noise_colors 1e1e1f 3c3b3d 6d6c70 a2a1a6 cbc9cf ffffff
    set -l glitch_line_chance 0.05
    set -l noise_chance 0.004
    set -l total_glitch_time 1000

    # Argument parsing
    set -l current_flag ""
    for arg in $argv
        switch $arg
            case --final-gradient-stops
                set current_flag final_gradient_stops
            case --final-gradient-steps
                set current_flag final_gradient_steps
            case --final-gradient-direction
                set current_flag final_gradient_direction
            case --glitch-line-colors
                set current_flag glitch_line_colors
            case --glitch-wave-colors
                set current_flag glitch_wave_colors
            case --noise-colors
                set current_flag noise_colors
            case --glitch-line-chance
                set current_flag glitch_line_chance
            case --noise-chance
                set current_flag noise_chance
            case --total-glitch-time
                set current_flag total_glitch_time
            case "*"
                switch $current_flag
                    case final_gradient_stops
                        set -a final_gradient_stops $arg
                    case final_gradient_steps
                        set -a final_gradient_steps $arg
                    case final_gradient_direction
                        set final_gradient_direction $arg
                    case glitch_line_colors
                        set -a glitch_line_colors $arg
                    case glitch_wave_colors
                        set -a glitch_wave_colors $arg
                    case noise_colors
                        set -a noise_colors $arg
                    case glitch_line_chance
                        set glitch_line_chance $arg
                    case noise_chance
                        set noise_chance $arg
                    case total_glitch_time
                        set total_glitch_time $arg
                end
        end
    end

    # Error handling and validation
    if test (count $final_gradient_steps) -le 0
        echo "Error: Number of gradient steps must be greater than 0."
        return 1
    end

    if test $glitch_line_chance -lt 0 -o $glitch_line_chance -gt 1
        echo "Error: Glitch line chance must be between 0 and 1."
        return 1
    end

    if test $noise_chance -lt 0 -o $noise_chance -gt 1
        echo "Error: Noise chance must be between 0 and 1."
        return 1
    end

    # Call the external command with parsed arguments
    command tte vhstape \
        --final-gradient-stops $final_gradient_stops \
        --final-gradient-steps $final_gradient_steps \
        --final-gradient-direction $final_gradient_direction \
        --glitch-line-colors $glitch_line_colors \
        --glitch-wave-colors $glitch_wave_colors \
        --noise-colors $noise_colors \
        --glitch-line-chance $glitch_line_chance \
        --noise-chance $noise_chance \
        --total-glitch-time $total_glitch_time
end
