function dev-it
    set -l func_version "1.0.0"

    set -l options (fish_opt -s v -l version)
    set options $options (fish_opt -s h -l help)
    set options $options (fish_opt -s r -l reverse)
    argparse $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "Usage: dev-it [options] [package-name]"
        echo ""
        echo "Options:"
        echo "  -v, --version  Show version number"
        echo "  -h, --help     Show help"
        echo "  -r, --reverse  Add package to main dependencies from the dev dependencies"
        return 0
    end

    # if they asked to reverse the package
    if set -q _flag_reverse
        yarn remove $argv
        yarn add $argv
        return 0
    end

    yarn remove $argv
    yarn add -D $argv
    return 0
end
