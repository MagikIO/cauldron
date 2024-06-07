#!/usr/bin/env fish

function underline --argument text
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help
    argparse -n underline $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        set_color --bold
        echo -n underline
        set_color normal
        echo " - Make the text underlined"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show the version"
        echo "  -h, --help     Show this help"
        echo ""
        echo "Usage: "
        echo "  underline 'Hello, World!'"
        echo "  echo -n "Hello "(underline 'Bilbo')"
        return 0
    end

    set_color -u
    echo -n $text
    set_color normal
end
