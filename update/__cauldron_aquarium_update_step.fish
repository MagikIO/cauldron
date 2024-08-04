#!/usr/bin/env fish

function __cauldron_aquarium_update_step
    if functions -q aquarium
        # Create a log file to pipe the output to
        mkdir -p $CAULDRON_PATH/logs
        set log_file $CAULDRON_PATH/logs/aqua_update.txt
        touch $log_file

        # Reset the log file and add a time stamp
        echo (date -u) >$log_file

        # Check the most recent version using `getLatestGithubReleaseTag anandamideio/aquarium`
        # Which will look like "v1.0.0"
        set latestAquaVersion (getLatestGithubReleaseTag anandamideio/aquarium | string trim)
        echo "Latest version of Aquarium is" $latestAquaVersion >>$log_file
        # Get the current version of aquarium (returns in format "1.0.0", minus the "v" and without color codes)
        set currentAquaVersion (echo "v"(aquarium -v) | string trim)
        echo "Current version of Aquarium is" $currentAquaVersion >>$log_file

        # If the versions are the same, then we don't need to update
        if test "$latestAquaVersion" = "$currentAquaVersion"
            echo (badge green "Aquarium") "is already up to date"
            return 0
        end

        # If the versions are different, then we need to prompt the user to confirm it's okay to update
        confirm "Would you like to update Aquarium to $latestAquaVersion?"

        # If the user says no, then we don't update
        if $CAULDRON_LAST_CONFIRM = false
            return 0
        end

        # If the user says yes, then we update
        echo "Updating Aquarium to $latestAquaVersion" >>$log_file

        # Remove the old aquarium (if it exists)
        if test -d ~/.cache/aquarium
            rm -rf ~/.cache/aquarium
        end

        # Make sure the folder exist
        mkdir -p ~/.cache/aquarium

        # Clone the aquarium repo
        git clone https://github.com/anandamideio/aquarium.git ~/.cache/aquarium

        # Install the aquarium
        pushd ~/.cache/aquarium/bin/
        ./install
        popd

        # Check the version again to make sure it installed correctly
        set -l newAquaVersion (aquarium -v)
        echo "New version of Aquarium is" $newAquaVersion >>$log_file

        return 0
    end
end
