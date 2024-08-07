#!/usr/bin/env fish

function hamsa -d "Uses grep to search recursively for a string in a directory, then shows the results using fzf preview" -a search_string
    # Version Number
    set -l func_version "1.0.0"

    # Flag options
    set -l options v/version h/help
    argparse -n hamsa $options -- $argv

    # if they asked the version just return it
    if set -q _flag_version
        echo $func_version
        return 0
    end

    # if they asked for help just return it
    if set -q _flag_help
        echo (bold "hamsa")
        echo "Version: $func_version"
        echo
        echo "Additional Info:"
        echo "  Uses grep to search recursively for a string in a directory, then shows the results using fzf preview"
        echo
        echo "Options:"
        echo "  -v, --version  Show the version number"
        echo "  -h, --help     Show this help message"
        exit 0
    end

    # Check if fzf is installed
    if not command -v fzf >/dev/null
        echo "fzf is required for this function to work"
        return 1
    end

    # Check if the search string is empty
    if test -z $search_string
        echo "Please provide a search string"
        return 1
    end

    set -l temp_file (mktemp)

    # Search for the string in the directory
    grep -rn --binary-files=without-match $search_string . >$temp_file

    # Initialize an empty list to store results
    set -l results

    # Read the contents of the temporary file line by line
    while read -l line
        set results $results $line
    end <$temp_file

    # Check if there are any results
    if test (count $results) -eq 0
        echo "No results found"
        return 1
    end

    # Show the results using fzf preview
    set -l selected (printf "%s\n" $results | fzf --preview 'echo {1} | awk -F: "{print \$1}" | xargs -I {} bat --color=always --highlight-line {2} {}' --delimiter ':' --preview-window=right:60%)

    # Extract the file path and line number from the selected result
    set -l file_path (echo $selected | awk -F: '{print $1}')
    set -l line_number (echo $selected | awk -F: '{print $2}')

    # Open the file in VS Code at the specified line
    code --goto $file_path:$line_number

    # Now we display a message to the user to let them know we've opened VSCode for them
    # But they can press this message to open the file in the file manager
    set -l file_url (realpath $file_path)
    echo -e (badge black " 🪬  ")(printf "\e]8;;file://%s\a Opened %s in VSCode for you; To open in file manager simply control click this text\e]8;;\a" $file_url $file_path)
end
