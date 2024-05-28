function choose_banner_font
    # Lets use fzf to select a font from toilet
    set -l fonts (ls /usr/share/figlet/ | string replace -r '\..*' '' | string match -v '*_*')

    # Loop through each font, echo its name and display a sample
    for font in $fonts
        echo $font
    end | fzf --preview "$CAULDRON_PATH/bin/preview_banner_font.fish {}" --preview-window=right:90% | read -l font

    # Set the CAULDRON_BANNER_FONT universal variable to the selected font
    set -Ux CAULDRON_BANNER_FONT $font

    ######################################################################################

    set render_flags -s -S -k -W -o
    set render_flag_names default smush kerning full-width output-width
    # Loop through each render option, echo its name and display a sample

    for i in (seq (count $render_flags))
        echo "$i:$render_flag_names[$i]"
    end | fzf --preview "$CAULDRON_PATH/bin/preview_banner_render_modes.fish {}" --preview-window=right:90% | read selected_option

    # Split the selected option into index and name
    set selected_option (echo $selected_option | string split -m 1 ':')
    set selected_option_name $selected_option[2]
    set selected_option_index $selected_option[1]

    # Find the corresponding render_option for the selected render_option_name
    set render_option $render_flags[$selected_option_index]

    # Set the CAULDRON_BANNER_RENDER_OPTION universal variable to the selected render option
    set -Ux CAULDRON_BANNER_RENDER_OPTION $render_option

    ######################################################################################

    # Loop through each filter option, echo its name and display a sample
    set -l filter_options rainbow metal flop:rainbow flop:metal border border:rainbow border:metal
    set -l filter_option

    for filter_option in $filter_options
        echo $filter_option
    end | fzf --preview "$CAULDRON_PATH/bin/preview_banner_filters.fish {}" --preview-window=right:90% | read -l filter_option

    function replace_rainbow -a txt
        # replace any occurances of `rainbow` with `gay` as that is the filter name that toilet exports
        echo $txt | sed s/rainbow/gay/g
    end

    # Set the CAULDRON_BANNER_FILTER_OPTION universal variable to the selected filter option
    set -Ux CAULDRON_BANNER_FILTER_OPTION (replace_rainbow $filter_option)

    ######################################################################################

    # Preview the banner with the selected font, render option, and filter option
    toilet $CAULDRON_BANNER_RENDER_OPTION -f $CAULDRON_BANNER_FONT -F $CAULDRON_BANNER_FILTER_OPTION -w 600 Finished
end
