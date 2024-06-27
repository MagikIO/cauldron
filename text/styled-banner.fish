function styled-banner --argument txt
    # IF the $CAULDRON_BANNER_ANIMATION is set we should use the corresponding animation
    if not set -q "$CAULDRON_BANNER_ANIMATION"
        banner $txt | rain-effect
    else
        switch $CAULDRON_BANNER_RENDER_OPTION
            case rain
                banner $txt | rain-effect
            case orbital-volley
                banner $txt | orbital-volley-effect
            case vhs
                banner $txt | vhs-effect
            case beam
                banner $txt | beam-effect
            case black-hole
                banner $txt | black-hole-effect
        end
    end
end
