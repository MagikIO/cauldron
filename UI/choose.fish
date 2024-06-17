function choose
    if not type -q shiny
        echo "shiny is not here. Please gather it first."
        return 1
    end

    # They must pass values for the choices
    if test (count $argv) -eq 0
        echo "You must pass in choices for the user to choose from."
        return 1
    end

    set -Ux CAULDRON_LAST_CHOICE (shiny choose $argv)

    # Now we see if the var is set, if so we exit successfully
    if test -n "$CAULDRON_LAST_CHOICE"
        return 0
    else
        return 1
    end
end
