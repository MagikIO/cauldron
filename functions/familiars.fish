#!/usr/bin/env fish

function familiars
    # Lets use fzf to select a familiar from cowsay
    set -l familiars (cowsay -l | tail -n +2 | string split " ")
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

    # Now we prompt the user to press 'r' to roll a new name, 'e' to edit the name, or 'q' to quit
    while true
        echo (string pad -c _ -w (tput cols) | rainbow-fish)
        echo (string pad " " 80 | string join "" | rainbow-fish)
        read -l -P "Press 'r' to roll a new name, 'e' to edit my name, or 'q' to quit: [r/e/q]" action
        switch $action
            case r
                set -Ux CAULDRON_FAMILIAR_NAME (new-name | string split " ")[1]
                f-says "Hello, $username! I am $CAULDRON_FAMILIAR_NAME, your new familiar!/n You can press 'r' to roll a new name for me, 'e' to edit my name, or 'q' if you're happy with the name and want to dismiss me for now." | rainbow-fish
            case e
                read -p "Enter a new name for me: " new_name
                set -Ux CAULDRON_FAMILIAR_NAME $new_name
                f-says "Hello, $username! I am $CAULDRON_FAMILIAR_NAME, your new familiar!/n You can press 'r' to roll a new name for me, 'e' to edit my name, or 'q' if you're happy with the name and want to dismiss me for now." | rainbow-fish
            case q
                break
        end
    end

    banner "New Familiar!"
end

familiars
