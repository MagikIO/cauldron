function color-block -d "Prints a color block to show you what colors are available"
    # Version Number
    set -l func_version "1.0.5"
    # Flag options
    argparse -n color-block v/version h/help -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "color-block $func_version"
        echo ""
        echo "A fuction that creates colored badges to prefix your echo or print statements"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo ""
        echo "Usage:"
        echo "  color-block"
        return 0
    end

    set basic_colors black red green yellow blue magenta cyan white
    set bright_colors brblack brred brgreen bryellow brblue brmagenta brcyan brwhite

    # Check if the CAULDRON_PALETTES variable is set
    if not set -q CAULDRON_PALETTES
        set -Ux CAULDRON_PALETTES ~/.config/cauldron/config/palettes.json
    end

    # Get the width of the terminal
    set term_width (math floor (tput cols))
    # Divide the width by number of colors to get the width of each block
    set block_width (math $term_width / (count $basic_colors))

    print_separator " 🌈 Basic Colors 🌈 "

    for color in $basic_colors
        # Now we calculate the length of the name
        set name_length (string length $color)
        # Now we calculate the length of the color block, minus the name
        set block_length (math $block_width - $name_length)
        # Now we make a string that's the length of half the block filled with spaces
        set half_width (math floor (math $block_length / 2))

        # Print the color block, with the name of the color in the center of the block
        set_color -b $color
        echo -n (string repeat -n $half_width " ")
        echo -n $color
        echo -n (string repeat -n $half_width " ")
        set_color normal
    end

    printf \n

    for color in $bright_colors
        # Now we calculate the length of the name
        set name_length (string length $color)
        # Now we calculate the length of the color block, minus the name
        set block_length (math $block_width - $name_length)
        # Now we make a string that's the length of half the block filled with spaces
        set half_width (math floor (math $block_length / 2))

        # Print the color block, with the name of the color in the center of the block
        set_color -b $color
        echo -n (string repeat -n $half_width " ")
        echo -n $color
        echo -n (string repeat -n $half_width " ")
        set_color normal
    end

    printf \n

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
