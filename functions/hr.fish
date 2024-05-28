function hr --description 'Prints a horizontal line'
    # Version Number
    set -l func_version "1.0.0"
    # Flag options
    set -l options v/version h/help l/length s/symbol= e/easy=
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "Usage: hr [OPTIONS]"
        echo "Prints a horizontal line"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show version number"
        echo "  -h, --help     Show this help message"
        echo "  -l, --length   The length of the line"
        echo "  -s, --symbol   The symbol to use for the line"
        echo "  -e, --easy     Easy symbol reference"
        echo
        echo "Symbol References:"
        echo "  -e  1   █"
        echo "  -e  2   ▓"
        echo "  -e  3   ▒"
        echo "  -e  4   ░"
        echo "  -e  5   ─"
        echo "  -e  6   ━"
        echo "  -e  7   ┄"
        echo "  -e  8   ┅"
        echo "  -e  9   ┈"
        echo "  -e 10   ┉"
        echo "  -e 11   ═"
        echo "  -e 12   ═"
        echo "  -e 13   ≡"
        echo "  -e 14   -"
        echo
        return 0
    end

    # Set the length of the line
    set length (tput cols)
    if set -q _flag_length
        set length $_flag_length
    end

    # Set the symbol to use for the line
    set symbol ─
    if set -q _flag_symbol
        set symbol $_flag_symbol
    end
    if set -q _flag_easy
        switch $_flag_easy
            case 1
                set symbol █
            case 2
                set symbol ▓
            case 3
                set symbol ▒
            case 4
                set symbol ░
            case 5
                set symbol ─
            case 6
                set symbol ━
            case 7
                set symbol ┄
            case 8
                set symbol ┅
            case 9
                set symbol ┈
            case 10
                set symbol ┉
            case 11
                set symbol ═
            case 12
                set symbol ═
            case 13
                set symbol ≡
            case 14
                set symbol -
        end
    end

    # Print the line
    for i in (seq 1 $length)
        echo -n $symbol
    end

    return 0
end
