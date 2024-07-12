#!/usr/bin/env fish

# Get a list of what familiars they have from DB View "unlocked_familiars"
# This will return in the format of:
# name|cow_src_ext
#
# Ex: koala| hellokitty| suse| tux| cock| duck| trogdor|1
set familiars (sqlite3 $CAULDRON_DATABASE "SELECT name, (cow_src_ext = 1) AS cow_src_ext_is_true FROM unlocked_familiars;")

set -l username (whoami)
for familiar in $familiars
    echo $familiar
end | fzf --preview '
    set -l split_familiar (string split "|" {})
    set -l familiar_name $split_familiar[1]
    set -l cow_src_ext $split_familiar[2]
    if set -q cow_src_ext; and test (math $cow_src_ext 2>/dev/null || echo 0) -eq 1
        cowsay -f $CAULDRON_PATH/data/$familiar_name.cow "Hi $username"
    else
        cowsay -f $familiar_name  "Hi $username"
    end
' | read -l familiar

set -gx CAULDRON_FAMILIAR (string split "|" $familiar)[1]
