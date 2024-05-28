#!/usr/bin/env fish

set render_flags -s -S -k -W -o
set render_option $argv
# Now we need to split the render_option into the index and name
set option (echo $render_option | string split -m 1 ':')
set render_option_name $option[2]
set render_option_index $option[1]
set render_option_flag $render_flags[$render_option_index]

echo "The render option is now set to: $render_option_name"
echo "The render option flag is now set to: $render_option_flag"

# Preview the banner with the selected font
toilet $render_option_flag -f $CAULDRON_BANNER_FONT -w 600 "The Onix Shinx Rizes"
