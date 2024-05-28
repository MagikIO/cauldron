function badge --description 'A fuction that creates a colored badge to prefix your echo or print statements' --argument color txt
    # Version Number
    set -l func_version "1.0.3"
    # Flag options
    set -l options v/version h/help
    argparse -n badge $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "badge $func_version"
        echo ""
        echo "A fuction that creates a colored badge to prefix your echo or print statements"
        echo ""
        echo "Possible colors:"
        echo "  black, red, green, yellow, blue, magenta, cyan, white"
        echo "  brblack, brred, brgreen, bryellow, brblue, brmagenta, brcyan, brwhite"
        echo "  any hex color code"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo ""
        echo "Usage:"
        echo "  badge blue 'Hello, World!'"
        echo "  badge red 'ERROR'"
        echo "  badge 62A 'LOGS'"
        return 0
    end

    # there must be two arguments
    if test (count $argv) -ne 2
        printf "ERROR: You must provide a color and text value\n"
        return 1
    end

    #################################
    # Set the color and text values #
    #################################
    set -l color $argv[1]
    set -l txt $argv[2]

    set_color -b $color
    printf " $txt "
    set_color normal
end
