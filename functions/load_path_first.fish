function load_path_first --description 'Move a directory to the start of PATH'
    set -l func_version "1.0.0"

    set -l options "v/version" "h/help"
    argparse -n load_path_first $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "Usage: load_path_first [options] [directory]"
        echo
        echo "Options:"
        echo "  -v, --version  Show version"
        echo "  -h, --help     Show this help"
        return 0
    end

    set -l dir (printf '%s\n' $fish_user_paths | fzf)

    if test -n "$dir"
        fish_add_path --move --prepend $dir
    end
end
