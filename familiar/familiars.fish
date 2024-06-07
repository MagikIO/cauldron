#!/usr/bin/env fish

function familiars
    # Lets use fzf to select a familiar from cowsay

    # Get a list of what familiars they have unlock from `$CAULDRON_PATH/config/cauldron.json`
    # This JSON follows the format of:
    # {
    #   "familiars": ["koala", "hellokitty", "suse", "tux", "duck"]
    # }
    set -l familiars (jq -r '.familiars[]' $CAULDRON_PATH/config/cauldron.json)

    set -l username (whoami)
    for familiar in $familiars
        echo $familiar
    end | fzf --preview "cowsay -f {} 'Hi $username'" | read -l familiar

    set -Ux CAULDRON_FAMILIAR $familiar

    # We will use the `new-name` fish function which returns a first and last name,
    # Then split the space, and use the first word
    set -Ux CAULDRON_FAMILIAR_NAME (new-name | string split " ")[1]
    # Now we can use the familiar
    f-says "Hello, $username! I am "(bold $CAULDRON_FAMILIAR_NAME)", your new familiar!/n You can press 'r' to roll a new name for me, 'e' to edit my name, or 'q' if you're happy with the name and want to dismiss me for now." | rainbow-fish


    set HALF_TERM_WIDTH (math (tput cols) / 2)

    # Now we prompt the user to press 'r' to roll a new name, 'e' to edit the name, or 'q' to quit
    while true
        box $CAULDRON_FAMILIAR_NAME -w $HALF_TERM_WIDTH
        read -l -P "Press 'r' to roll a new name, 'e' to edit my name, or 'q' to quit: [r/e/q]" action
        switch $action
            case r
                set -Ux CAULDRON_FAMILIAR_NAME (new-name | string split " ")[1]
                f-says "Hello, $username! I am $CAULDRON_FAMILIAR_NAME, your new familiar!/n You can press 'r' to roll a new name for me, 'e' to edit my name, or 'q' if you're happy with the name and want to dismiss me for now." | rainbow-fish
            case e
                read -l -P "Enter a new name for me: " new_name
                set -Ux CAULDRON_FAMILIAR_NAME $new_name
                f-says "Hello, $username! I am $CAULDRON_FAMILIAR_NAME, your new familiar!/n You can press 'r' to roll a new name for me, 'e' to edit my name, or 'q' if you're happy with the name and want to dismiss me for now." | rainbow-fish
            case q
                break
        end
    end

    banner "New Familiar!"
end
