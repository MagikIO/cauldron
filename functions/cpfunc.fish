#!/usr/bin/env fish

# This is an alias function to make cp then sourcing a function easier
# It will copy the function to the fish functions directory and then source it
# Usage: cpfunc <path_to_function>
function cpfunc -d 'Copy a function to the fish functions directory and source it' -a path_to_function -d 'The path to the function to copy'
    # Version Number
    set -l func_version "1.3.5"
    # Flag options
    set -l options v/version h/help d/directory g/global
    argparse -n cpfunc $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help just return it
    if set -q _flag_help
        echo "Usage: cpfunc <path_to_function>"
        echo "Version: $func_version"
        echo "Copy a function to the fish functions directory and source it"
        echo
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo "  -d, --directory  The directory to copy the function to"
        echo "  -g, --global  Install the function globally"
        echo
        echo "Examples:"
        echo "  cpfunc ~/path/to/function.fish"
        echo "  cpfunc ~/path/to/functions/ -d"
        echo "  cpfunc ~/path/to/functions/ -d -g"
        return
    end

    # If they accidentally provided the flag first then return an error
    if string match -q -- "-*" $path_to_function
        echo "You must provide a path to the function or function(s) to copy, then any flags"
        return 1
    end

    # If they didn't provide a path to the function then return an error
    if not set -q path_to_function; or test -z "$path_to_function"
        echo "You must provide a path to the function or function(s) to copy"
        return 1
    end

    # If they provided a directory to copy all the functions within then do that
    if set -q _flag_d
        # Confirm it's a directory
        if not test -d $path_to_function
            echo "$path_to_function is not a directory, please provide a directory"
            return 1
        end

        # If path the function doesn't end with a / then add it
        if not string match -q '*/' $path_to_function
            set path_to_function "$path_to_function/"
        end

        # Get all the files in the directory
        set -l files (lsf $path_to_function)

        # Loop through the files
        for file in $files
            # Get the function name
            set -l function_name (basename -s .fish $file)

            # Check if the script is executable, if not make it executable
            if not test -x $path_to_function$file
                chmod +x $path_to_function$file
            end

            # If the want to install it globally then copy it to the global fish functions directory
            if set -q _flag_g
                # Copy the function to the fish functions directory
                sudo cp $path_to_function$file $__fish_sysconf_dir/functions/
                continue
            else
                # Copy the function to the fish functions directory
                cp $path_to_function$file $HOME/.config/fish/functions/$function_name.fish
            end
        end
        return
    end

    # Get the function name
    # Our function paths are going to look like `./.vscode/scripts/theme/install_mods_theme.fish` so we need to extract the function name
    set -l function_name (basename -s .fish $path_to_function)

    # Check if the script is executable, if not make it executable
    if not test -x $path_to_function
        chmod +x $path_to_function
    end

    # If the want to install it globally then copy it to the global fish functions directory
    if set -q _flag_g
        # Copy the function to the fish functions directory
        sudo cp $path_to_function $__fish_sysconf_dir/functions/
        return
    else
        # Copy the function to the fish functions directory
        cp $path_to_function $HOME/.config/fish/functions/$function_name.fish
    end
end
