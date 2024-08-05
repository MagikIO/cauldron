#!/usr/bin/env fish

function visual_git_checkout
    # Get all branches, remove remote prefixes, and trim whitespace
    set branches (git branch --all | sed 's|^.*/||' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -E '^[^*]' | sort -u)

    # Use fzf to select a branch
    set selected_branch (echo $branches | tr ' ' '\n' | fzf --preview "git show --color=always --stat {}" --preview-window="right:wrap")

    if test -n "$selected_branch"
        git checkout "$selected_branch"
    else
        echo "No branch selected."
    end
end
visual_git_checkout
