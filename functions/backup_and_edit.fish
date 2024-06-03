#!/usr/bin/env fish

function backup_and_edit -d 'Backup a file (make a copy with .bak) and open the original in your preferred editor' -a file -d 'The file to edit' -a max_copies -d 'The maximum number of copies to keep'
    # Version Number
    set -l func_version "1.2.0"
    # Flag options
    set -l options "v/version" "h/help" "b/backup" "V/verbose"
    argparse -n installs $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return
    end

    # if they asked for help, show it
    if set -q _flag_help
        echo "Backup and Edit"
        echo "Version: $func_version"
        echo "Usage: backup_and_edit [file]"
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        echo "  -b, --backup  Only make a backup, don't open the file"
        echo "  -V, --verbose  Show more information"
        return
    end

    # Make sure they have an editor set or fall back to nano
    if not set -q EDITOR
        # If the user has defined a preferred editor, use that
        if set -q aqua__preferred_editor
            set -g EDITOR $aqua__preferred_editor
        else if type -q code
            set -g EDITOR "code"
        else
            set -g EDITOR "nano"
        end
    end

    # if they didn't give a file, show an error
    if not set -q file
        echo "You must provide a file to edit"
        return
    end

    # if the file doesn't exist, show an error
    if not test -e $file
        echo "$file does not exist, at least not where I'm looking"
        return
    end

    # if the file is a directory, show an error
    if test -d $file
        echo "The $file is a directory, what are you trying to do?"
        return
    end

    # if the file is a symlink, show an error
    if test -L $file
        echo "The file $file is a symlink, this is not supported, or safe come to think of it"
        return
    end

    # if the file is not readable, show an error
    if not test -r $file
        echo "$file is not readable, I can't edit it, sorry"
        return
    end

    # if the file is not writable, show an error
    if not test -w $file
        echo "$file is not writable, I can't edit it, sorry"
        return
    end

    # No more than 5 copies by default
    if  not set -q max_copies
        set max_copies 5
    end

    if set -q _flag_verbose
        echo "Backing up $file"
        # Lets use the `bak` command to make a backup of the file
        fish -c "bak $file $max_copies --verbose"
    else
        # Lets use the `bak` command to make a backup of the file
        fish -c "bak $file $max_copies"
    end

    if set -q _flag_b
        echo "Backup created"
        return 0
    else
        ## Then open the file in their preferred editor
        $EDITOR $file
    end
end
