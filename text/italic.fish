#!/usr/bin/env fish

function italic --argument text
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help
    argparse -n italic $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        set_color --bold
        echo -n italic
        set_color normal
        echo " - Make the text italic"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version"
        echo "  -h, --help     Show this help"
        echo ""
        echo "Usage: "
        echo "  italic 'Hello, World!'"
        echo "  echo -n "Hello "(italic 'Bilbo')"
        return 0
    end

    set_color --italic
    echo -n $text
    set_color normal
end
