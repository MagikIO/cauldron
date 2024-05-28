#!/usr/bin/env fish

# Function to center text within a given width
function print_center -d 'Print a message centered in terminal' -a width -a message
    # Version Number
    set -l func_version "1.0.0"
    # Flag options
    set -l options v/version h/help
    argparse -n print_center $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "print_center $func_version"
        echo ""
        echo "A function that prints a message centered in the terminal"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo ""
        echo "Usage:"
        echo "  print_center 'Hello, World!'"
        echo "  print_center -w 80 'Hello, World!'"
        return
    end

    set term_width (tput cols)
    set term_msg

    # If one arg is passed, calculate the width of the terminal
    if test (count $argv) -eq 1
        set term_msg $argv[1]
    else
        set term_width $width
        set term_msg $argv[2]
    end

    # Calculate the length of the message
    set msg_length (string length $term_msg)
    # Calculate the length of the padding
    set padding (math floor (math $term_width - $msg_length) / 2)

    # Print the padding
    echo -n (string repeat -n $padding " ")
    # Print the message
    echo $term_msg

    return 0

end
