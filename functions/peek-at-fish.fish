function peek-at-fish
    set selected_function (functions | fzf --preview "functions -D {} | read -l function_path; bat --color=always --style=numbers \$function_path" --preview-window="right:wrap")
    if test -n "$selected_function"
        # if the EDITOR Variable hasn't been set yet lets prompt them to choose 
        if not set -q EDITOR
            # Check if f-says is available
            if type -q f-says
                f-says "Please select your preferred editor"
            else
                echo "Please select your preferred editor"
            end

            set installed_editors
            # Check  if code is installed
            if type -q code
                set installed_editors $installed_editors "code"
            end
            # Check if nano is installed
            if type -q nano
                set installed_editors $installed_editors "nano"
            end
            # Check if vim is installed
            if type -q vim
                set installed_editors $installed_editors "vim"
            end
            # Check if emacs is installed
            if type -q emacs
                set installed_editors $installed_editors "emacs"
            end
            # Check if gedit is installed
            if type -q gedit
                set installed_editors $installed_editors "gedit"
            end

            choose $installed_editors

            # If $STATUS is not 0, then the user didn't select an editor
            if test $STATUS -ne 0
                echo "No editor selected. Please set the \$EDITOR environment variable."
                return
            end

            set -gx EDITOR $CAULDRON_LAST_CHOICE
        end


        if test -n "$EDITOR"
            functions -D $selected_function | read -l function_path
            $EDITOR $function_path
        end
    end
end
