#!/usr/bin/env fish

function bold_text -a text
    set_color --bold
    echo -n $text
    set_color normal
end

function replace_rainbow -a txt
    # replace any occurances of `rainbow` with `gay` as that is the filter name that toilet exports
    echo $txt | sed s/rainbow/gay/g
end

set preview_filter $argv[1]
set preview_filter_flag (replace_rainbow $preview_filter)

printf "The banner font is now set to: %s\n" (bold_text $CAULDRON_BANNER_FONT)
printf "The banner render option is now set to: %s\n" (bold_text $CAULDRON_BANNER_RENDER_OPTION)
printf "Currently previewing the filter: %s\n" (bold_text $preview_filter)
# Preview the banner with the selected font
toilet $CAULDRON_BANNER_RENDER_OPTION -f $CAULDRON_BANNER_FONT -F $preview_filter_flag -w 600 "The Onix Shinx Rizes"
