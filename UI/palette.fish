function palette -a color
    # Version Number
    set -l func_version "1.0.0"
    # Flag options
    argparse -n palette v/version h/help l/list -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "palette $func_version"
        echo ""
        echo "A function that returns a color from a palette"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo "  -l, --list     List all the colors in the palette"
        echo ""
        echo "Usage:"
        echo "  palette blue"
        echo "  palette blue.2"
        echo "  palette -l"
        return 0
    end

    # Check if the CAULDRON_PALETTES variable is set
    if not set -q CAULDRON_PALETTES
        set -Ux CAULDRON_PALETTES ~/.config/cauldron/config/palettes.json
    end

    if set -q _flag_list
        # Get the width of the terminal
        set term_width (math floor (tput cols))
        # If the user has a palettes file, print the colors from that file
        # This file should look like:
        # {
        #    "malory": ["850F8D", "C738BD", "E49BFF", "F8F9D7"]
        #  }
        if test -f $CAULDRON_PALETTES
            print_separator "🎨 Palletes 🎨"
            # Get all palette names
            set -l palettes (jq -r 'keys[]' $CAULDRON_PALETTES)
            for palette in $palettes
                set -l palette_colors_string (cat $CAULDRON_PALETTES | jq -r ".$palette | join(\" \")")
                set -l palette_colors (string split " " -- $palette_colors_string)
                set -l palette_name_length (string length $palette)
                echo -n "$palette"(string repeat -n (math 10 - $palette_name_length) " ")

                for color in $palette_colors
                    set block_width (math $term_width / (count $palette_colors))
                    # Now we calculate the length of the name
                    set name_length (string length $color)
                    # Now we calculate the length of the color block, minus the name
                    set block_length (math $block_width - $name_length)
                    # Now we make a string that's the length of half the block filled with spaces
                    set half_width (math floor (math $block_length / 2 - 1))

                    # Print the color block, with the name of the color in the center of the block
                    set_color -b "$color"
                    echo -n (string repeat -n $half_width " ")
                    echo -n $color
                    echo -n (string repeat -n $half_width " ")
                    set_color normal
                end

                printf \n
            end
        end
        return 0
    end


    # If the color string contains a period, the user is trying use a palette
    # We can find the users palette in the $CAULDRON_PALLETES, which points to their palettes.json
    # The structure of palettes is 
    # {
    #   "berry": ["850F8D", "C738BD", "E49BFF", "F8F9D7"],
    #   "malory": ["FFE6E6", "E1AFD1", "AD88C6", "7469B6"],
    #   "neodutch": ["000000", "F72798", "F57D1F", "EBF400"]
    # }
    # There color should equal `palette_name.number` where `number` is the index of the color in the palette
    # Ex. `blue.2` would be the third color in the blue palette
    if string match -q "*.*" $color
        set palette_name (string split -m 1 . $color)[1]
        set palette_index (string split -m 1 . $color)[2]
        set palette_colors_string (cat $CAULDRON_PALETTES | jq -r ".$palette_name | join(\" \")")
        set -l palette_colors (string split " " -- $palette_colors_string)
        echo $palette_colors[$palette_index]
    else
        # If there is no period in the color, return the list of colors in that palette
        set palette_colors_string (cat $CAULDRON_PALETTES | jq -r ".$color | join(\" \")")
        set -l palette_colors (string split " " -- $palette_colors_string)
        echo $palette_colors
    end

    return 0
end
