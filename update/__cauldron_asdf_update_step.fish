#!/usr/bin/env fish

function __cauldron_asdf_update_step
    # If asdf is their preferred version manager, we need to make sure it's installed and set the node version
    if test $cauldron_packman_pref = asdf; or test $cauldron_packman_pref = none; or test $cauldron_packman_pref = asdf_preferred
        # Create a log file to pipe the output to
        mkdir -p $CAULDRON_PATH/logs
        set log_file $CAULDRON_PATH/logs/asdf_update.txt
        touch $log_file

        echo >$log_file

        # First we need to see if they have asdf installed
        if not type -q asdf
            install_asdf | tee -a $log_file
        end

        # Then we need to set the node version
        gum spin --spinner moon --title "Updating Node..." -- fish -c __cauldron_asdf_update_node >>$log_file
        gum spin --spinner moon --title "Updating Ruby..." -- fish -c __cauldron_asdf_update_ruby >>$log_file
        gum spin --spinner moon --title "Updating Go..." -- fish -c __cauldron_asdf_update_go >>$log_file
    end

    # If they prefer nvm
    if test $cauldron_packman_pref = nvm
        # We need to set the node version
        gum spin --spinner moon --title "Updating Node..." -- fish -c nvm_update_node
    end
end
