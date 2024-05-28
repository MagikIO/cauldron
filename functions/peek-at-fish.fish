function peek-at-fish
    set selected_function (functions | fzf --preview "functions -D {} | read -l function_path; bat --color=always --style=numbers \$function_path" --preview-window="right:wrap")
    if test -n "$selected_function"
        if test -n "$EDITOR"
            functions -D $selected_function | read -l function_path
            $EDITOR $function_path
        else
            echo "No editor set. Please set the \$EDITOR environment variable."
        end
    else
        echo "No function selected."
    end
end
