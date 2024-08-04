#!/usr/bin/env fish

function visual_git_checkout
    set selected_branch (git branch --all | string replace -r "^.*\/" "" | string trim | sort -u | sed "s/^\* //g" | fzf --preview "git show --color=always --stat {}" --preview-window="right:wrap")
    if test -n "$selected_branch"
        git checkout "$selected_branch"
    else
        echo "No branch selected."
    end
end
