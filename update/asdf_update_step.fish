function asdf_update_step
    # If asdf is their preferred version manager, we need to make sure it's installed and set the node version
    if test $cauldron_packman_pref = asdf; or test $cauldron_packman_pref = none; or test $cauldron_packman_pref = asdf_preferred
        # First we need to see if they have asdf installed
        if not type -q asdf
            install_asdf
        end
        # Then we need to set the node version
        gum spin --spinner moon --title "Updating Node..." -- fish -c asdf_update_node
        gum spin --spinner moon --title "Updating Ruby..." -- fish -c asdf_update_ruby
        gum spin --spinner moon --title "Updating Go..." -- fish -c asdf_update_go
    end

    # If they prefer nvm
    if test $cauldron_packman_pref = nvm
        # We need to set the node version
        gum spin --spinner moon --title "Updating Node..." -- fish -c nvm_update_node
    end
end
