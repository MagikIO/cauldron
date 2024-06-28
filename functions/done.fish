function done
    # Choose the type of commit
    set TYPE (gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")

    # Prompt for the scope
    set SCOPE (gum input --placeholder "scope")

    # Wrap the scope in parentheses if it has a value
    test -n "$SCOPE" && set SCOPE "($SCOPE)"

    # Pre-populate the summary input with the type(scope): so that the user may change it
    set SUMMARY (gum input --value "$TYPE$SCOPE: " --placeholder "Summary of this change")

    # Prompt for the description
    set DESCRIPTION (gum write --placeholder "Details of this change")

    # Confirm with the user before committing
    gum confirm "Commit changes?" && git commit -m "$SUMMARY" -m "$DESCRIPTION"
end
