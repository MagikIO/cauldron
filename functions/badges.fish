function badges --description 'A fuction that creates a colored badge to prefix your echo or print statements' --argument colors txts
    # Version Number
    set -l func_version "1.0.3"
    # Flag options
    argparse -n badges v/version h/help 'c=+' 't=+' 'p=' -- $argv

    set badge_powerline "$_flag_p"
    # If they didn't profive a powerline, default to arrow
    if test -z $badge_powerline
        set badge_powerline arrow
    end

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "badges $func_version"
        echo ""
        echo "A fuction that creates colored badges to prefix your echo or print statements"
        echo ""
        echo "Possible colors:"
        echo "  black, red, green, yellow, blue, magenta, cyan, white,"
        echo "  brblack, brred, brgreen, bryellow, brblue, brmagenta, brcyan, brwhite,"
        echo "  any hex color code, or you can use any of your built in pallets"
        echo ""
        echo "Possible Powerline Options:"
        echo "  arrow, branch, line, none"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo "  -c             The color of the badge"
        echo "  -t             The text of the badge"
        echo "  -p             The powerline character"
        echo ""
        echo "Usage:"
        echo "  badges -c blue -t 'Hello, World!' -c red -t 'ERROR'"
        echo "  badges -p branch -c 62A -t 'SERVER' -c 62A -t 'LOGS'"
        return 0
    end

    set txts $_flag_t
    set colors $_flag_c

    # Now we use a switch to match the powerline character
    switch $badge_powerline
        case arrow
            set badge_powerline ""
        case branch
            set badge_powerline ""
        case line
            set badge_powerline "│"
        case none
            set badge_powerline none
        case '*'
            printf "\n Invalid powerline character \n"
            return 1
    end

    # Loop through the text, using the index
    for badge_txt in $txts
        set index (math $index + 1)
        set color
        # If the there are the same amount of color as text, use the index
        # Other wise, just use the first color
        if test (count $colors) -eq (count $txts)
            set color $colors[$index]
        else
            set color $colors[1]
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
            # now we use `palette $color` which will echo the color
            set color (palette $color)
        end

        badge $color $badge_txt

        # If they chose `none` for the powerline return
        if test $badge_powerline = none
            continue
        end

        # Is there another badge after this one?
        # If so, and it has a different color we need to make the background the same color
        if test (count $txts) -gt $index
            set next_color $colors[(math $index + 1)]
            if string match -q "*.*" $next_color
                set next_color (palette $next_color)
            end
            if test $next_color != $color
                set_color -b $next_color
            end
        end

        # Set the color itself to the color
        set_color $color
        printf "$badge_powerline"
        set_color normal
    end
end
