#!/usr/bin/env fish

function box -a txt
    # Version Number
    set -l func_version "1.0.0"
    # Flag options
    set -l options v/version h/help w/width= s/symbol= e/easy= r/rainbow
    argparse -n print_center $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "box $func_version"
        echo ""
        echo "A function that prints a message centered in a box"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo "  -w, --width    The width of the box"
        echo "  -s, --symbol   The symbol to use for the box"
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
        echo "Usage:"
        echo "  box 'Hello, World!'"
        echo "  box 'Hello, World!' -w 80"
        return
    end

    set BOX_WIDTH (math (tput cols) / 2)
    if set -q _flag_width
        set BOX_WIDTH $_flag_width
    end

    # Set the symbol to use for the line
    set symbol █
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

    function create-bar-with-symbol -a symbol
        set BOX_WIDTH (math (tput cols) / 2)
        if set -q _flag_width
            set BOX_WIDTH $_flag_width
        end

        if set -q _flag_rainbow
            echo (hr -w $BOX_WIDTH -s $symbol) | rainbow-fish
        else
            echo (hr -w $BOX_WIDTH -s $symbol)
        end
    end

    function create-sides-with-text -a text
        set BOX_WIDTH (math (tput cols) / 2)
        if set -q _flag_width
            set BOX_WIDTH $_flag_width
        end

        set symbol $argv[2]
        set msg_length (string length --visible $text)
        set padding (math $BOX_WIDTH - $msg_length)
        set half_width (math "floor($padding / 2)")
        set total_length (math $msg_length + $half_width \* 2)

        # echo -e (badge red "DEBUG") \
        #     \n(bold "MSG"): $text \
        #     \n(bold "MSG LENGTH"): $msg_length \
        #     \n(bold "WIDTH"): $BOX_WIDTH \
        #     \n(bold "HALF WIDTH") = $BOX_WIDTH / 2 = $half_width \
        #     \n(bold "TOTAL LENGTH"): $total_length

        if set -q _flag_rainbow
            echo -n $symbol | rainbow-fish
            echo -n (string repeat -n $half_width " ") | rainbow-fish
            echo -n $text | rainbow-fish
            echo -n (string repeat -n $half_width " ") | rainbow-fish
            echo $symbol | rainbow-fish
        else
            echo -n $symbol
            echo -n (string repeat -n $half_width " ")
            echo -n $text
            echo -n (string repeat -n $half_width " ")
            echo $symbol
        end
    end

    create-bar-with-symbol "─"
    create-sides-with-text $txt "|"
    create-bar-with-symbol "─"
end
