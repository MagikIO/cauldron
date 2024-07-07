#!/usr/bin/env fish

function __cauldron_help
    set -l options c/category
    argparse -n cauldron_help $options -- $argv

    # First we need to make sure that glow is installed
    if not type -q glow
        brew install glow

        # Add fish completion for glow
        function __glow_debug
            set -l file "$BASH_COMP_DEBUG_FILE"
            if test -n "$file"
                echo "$argv" >>$file
            end
        end

        function __glow_perform_completion
            __glow_debug "Starting __glow_perform_completion"

            # Extract all args except the last one
            set -l args (commandline -opc)
            # Extract the last arg and escape it in case it is a space
            set -l lastArg (string escape -- (commandline -ct))

            __glow_debug "args: $args"
            __glow_debug "last arg: $lastArg"

            # Disable ActiveHelp which is not supported for fish shell
            set -l requestComp "GLOW_ACTIVE_HELP=0 $args[1] __complete $args[2..-1] $lastArg"

            __glow_debug "Calling $requestComp"
            set -l results (eval $requestComp 2> /dev/null)

            # Some programs may output extra empty lines after the directive.
            # Let's ignore them or else it will break completion.
            # Ref: https://github.com/spf13/cobra/issues/1279
            for line in $results[-1..1]
                if test (string trim -- $line) = ""
                    # Found an empty line, remove it
                    set results $results[1..-2]
                else
                    # Found non-empty line, we have our proper output
                    break
                end
            end

            set -l comps $results[1..-2]
            set -l directiveLine $results[-1]

            # For Fish, when completing a flag with an = (e.g., <program> -n=<TAB>)
            # completions must be prefixed with the flag
            set -l flagPrefix (string match -r -- '-.*=' "$lastArg")

            __glow_debug "Comps: $comps"
            __glow_debug "DirectiveLine: $directiveLine"
            __glow_debug "flagPrefix: $flagPrefix"

            for comp in $comps
                printf "%s%s\n" "$flagPrefix" "$comp"
            end

            printf "%s\n" "$directiveLine"
        end

        # This function does two things:
        # - Obtain the completions and store them in the global __glow_comp_results
        # - Return false if file completion should be performed
        function __glow_prepare_completions
            __glow_debug ""
            __glow_debug "========= starting completion logic =========="

            # Start fresh
            set --erase __glow_comp_results

            set -l results (__glow_perform_completion)
            __glow_debug "Completion results: $results"

            if test -z "$results"
                __glow_debug "No completion, probably due to a failure"
                # Might as well do file completion, in case it helps
                return 1
            end

            set -l directive (string sub --start 2 $results[-1])
            set --global __glow_comp_results $results[1..-2]

            __glow_debug "Completions are: $__glow_comp_results"
            __glow_debug "Directive is: $directive"

            set -l shellCompDirectiveError 1
            set -l shellCompDirectiveNoSpace 2
            set -l shellCompDirectiveNoFileComp 4
            set -l shellCompDirectiveFilterFileExt 8
            set -l shellCompDirectiveFilterDirs 16

            if test -z "$directive"
                set directive 0
            end

            set -l compErr (math (math --scale 0 $directive / $shellCompDirectiveError) % 2)
            if test $compErr -eq 1
                __glow_debug "Received error directive: aborting."
                # Might as well do file completion, in case it helps
                return 1
            end

            set -l filefilter (math (math --scale 0 $directive / $shellCompDirectiveFilterFileExt) % 2)
            set -l dirfilter (math (math --scale 0 $directive / $shellCompDirectiveFilterDirs) % 2)
            if test $filefilter -eq 1; or test $dirfilter -eq 1
                __glow_debug "File extension filtering or directory filtering not supported"
                # Do full file completion instead
                return 1
            end

            set -l nospace (math (math --scale 0 $directive / $shellCompDirectiveNoSpace) % 2)
            set -l nofiles (math (math --scale 0 $directive / $shellCompDirectiveNoFileComp) % 2)

            __glow_debug "nospace: $nospace, nofiles: $nofiles"

            # If we want to prevent a space, or if file completion is NOT disabled,
            # we need to count the number of valid completions.
            # To do so, we will filter on prefix as the completions we have received
            # may not already be filtered so as to allow fish to match on different
            # criteria than the prefix.
            if test $nospace -ne 0; or test $nofiles -eq 0
                set -l prefix (commandline -t | string escape --style=regex)
                __glow_debug "prefix: $prefix"

                set -l completions (string match -r -- "^$prefix.*" $__glow_comp_results)
                set --global __glow_comp_results $completions
                __glow_debug "Filtered completions are: $__glow_comp_results"

                # Important not to quote the variable for count to work
                set -l numComps (count $__glow_comp_results)
                __glow_debug "numComps: $numComps"

                if test $numComps -eq 1; and test $nospace -ne 0
                    # We must first split on \t to get rid of the descriptions to be
                    # able to check what the actual completion will be.
                    # We don't need descriptions anyway since there is only a single
                    # real completion which the shell will expand immediately.
                    set -l split (string split --max 1 \t $__glow_comp_results[1])

                    # Fish won't add a space if the completion ends with any
                    # of the following characters: @=/:.,
                    set -l lastChar (string sub -s -1 -- $split)
                    if not string match -r -q "[@=/:.,]" -- "$lastChar"
                        # In other cases, to support the "nospace" directive we trick the shell
                        # by outputting an extra, longer completion.
                        __glow_debug "Adding second completion to perform nospace directive"
                        set --global __glow_comp_results $split[1] $split[1].
                        __glow_debug "Completions are now: $__glow_comp_results"
                    end
                end

                if test $numComps -eq 0; and test $nofiles -eq 0
                    # To be consistent with bash and zsh, we only trigger file
                    # completion when there are no other completions
                    __glow_debug "Requesting file completion"
                    return 1
                end
            end

            return 0
        end

        # Since Fish completions are only loaded once the user triggers them, we trigger them ourselves
        # so we can properly delete any completions provided by another script.
        # Only do this if the program can be found, or else fish may print some errors; besides,
        # the existing completions will only be loaded if the program can be found.
        if type -q glow
            # The space after the program name is essential to trigger completion for the program
            # and not completion of the program name itself.
            # Also, we use '> /dev/null 2>&1' since '&>' is not supported in older versions of fish.
            complete --do-complete "glow " >/dev/null 2>&1
        end

        # Remove any pre-existing completions for the program since we will be handling all of them.
        complete -c glow -e

        # The call to __glow_prepare_completions will setup __glow_comp_results
        # which provides the program's completion choices.
        complete -c glow -n __glow_prepare_completions -f -a '$__glow_comp_results'
    end

    function to_lower_case -a str
        echo $str | tr '[:upper:]' '[:lower:]'
    end

    if set -q _flag_category
        set -gx __doc_category $_flag_category
    else
        set -gx __doc_category Functions
    end

    function change_category -a index
        # if the index is -1 we move back a category, if it's 1 we move forward
        set -l current_index (math (math --scale 0 (math --scale 0 (string match -r -- '.*\t' $__doc_category) + $index) % (count $doc_categories)))
        set -gx __doc_category (string join " " $doc_categories[$current_index])
        set __lower_case_category (to_lower_case $__doc_category)
        set -gx __CAULDRON_DOC_CATEGORY_PATH "$__CAULDRON_DOCUMENTATION_PATH/$__lower_case_category"
    end

    # Documentation Category
    set doc_categories "Functions" "Text" "Setup" "Alias" "UI" "Internal"
    set -gx __CAULDRON_DOCUMENTATION_PATH $CAULDRON_PATH/docs
    set __lower_case_category (to_lower_case $__doc_category)
    set -gx __CAULDRON_DOC_CATEGORY_PATH "$__CAULDRON_DOCUMENTATION_PATH/$__lower_case_category"

    # terminal width
    set term_width (tput cols)
    # Reduce to 80% of the terminal width
    set term_width (math (math --scale 0 $term_width \* 0.8))

    shiny style \
        --foreground 212 --border-foreground 212 --border double \
        --align center --width $term_width --margin "1 2" --padding "2 4" \
        "Cauldron Documentation - $__doc_category" "Press Enter to open the documentation in full-screen" \
        "Press Ctrl-e to edit the documentation, or Ctrl-f to preview with bat" \
        "Change documentation categories with ctrl+n or ctrl+m to cycle the documentation category"

    # Generate a list of markdown files with their paths
    set -l mdFiles (find $__CAULDRON_DOC_CATEGORY_PATH -type f -name '*.md')

    function extract_file_names
        for path in $argv
            # Remove the directory path
            set filename (string replace -r '.*/' '' $path)
            # Remove the .md extension
            set filename (string replace -r '\.md$' '' $filename)
            echo $filename
        end
    end

    set nameList (extract_file_names $mdFiles)
    # Initialize displayList as an empty list
    set displayList

    for idx in (seq (count $mdFiles))
        # Construct displayList with name and path as "name###path"
        # Do not add a newline character here
        set displayList $displayList (string trim (string join "\t" $nameList[$idx] $mdFiles[$idx]))
    end

    # Join the displayList entries with a newline character
    set displayList (string join "\n" $displayList)

    set -x CLICOLOR_FORCE 1
    set -x GLAMOUR_STYLE dark

    # Use fzf with the modified list
    # Display names are shown to the user, but actions use the full path
    echo -e $displayList |
        fzf --delimiter='\t' \
            --with-nth=1 \
            --preview 'glow {2} -s dark' \
            --preview-window=right:50%:wrap \
            --bind 'enter:execute(glow {2})' \
            --bind 'ctrl-e:execute($EDITOR {2})' \
            --bind 'ctrl-f:execute(glow {2} | bat -l md --paging=always)' \
            --bind 'ctrl-n:execute(change_category -1; change-prompt($__doc_category> ); reload)' \
            --bind 'ctrl-m:execute(change_category 1; change-prompt($__doc_category> ); reload)' \
            --prompt 'Function> ' \
            --header 'Enter to open full-screen, Ctrl-e: Edit Documentation, Ctrl-f: Preview with bat' \
            --ansi \
            --height 80%
end
