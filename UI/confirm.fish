function confirm --description 'Prompts the user with a yes or no prompt' --argument prompt
    shiny confirm $prompt

    if test $status = 0
        set -Ux CAULDRON_LAST_CONFIRM true
        return 0
    else
        set -Ux CAULDRON_LAST_CONFIRM false
        return 1
    end
end
