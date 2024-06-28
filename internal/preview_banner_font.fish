#!/usr/bin/env fish

set preview_render_font $argv[1]
set render_flags -s -S -k -W -o
set render_flag_names default smush kerning full-width output-width

for index in (seq (count $render_flags))
    hr
    set option $render_flags[$index]
    echo (bold $preview_render_font) with render mode (underline $option"/"$render_flag_names[$index])
    toilet -f $preview_render_font -w 600 $option "The Onix Shinx Rizes"
    echo
end
