function update_cauldron
    # Check if ~/.config/cauldron/latestRelease.json exists
    if test -f ~/.config/cauldron/latestRelease.json
        # Now we use the getLatestGithubReleaseAsJSON function to get the latest release to compare against
        # We will use the jq command to parse the JSON, and compare the 'tag_name' to the current version
        set latestInstalledVersion (jq -r '.tag_name' ~/.config/cauldron/latestRelease.json)
        # Store a version of the latest release in a temp file
        set incomingFileLocation ~/.config/cauldron/_temp_latestRelease.json
        # Generate a new temp file with the latest release
        getLatestGithubReleaseAsJSON MagikIO/cauldron -s >$incomingFileLocation
        # Get the version of the incoming release
        set incomingVersion (cat $incomingFileLocation | jq -r '.tag_name')
        if test $latestInstalledVersion = $incomingVersion
            f-says "Our Cauldron is shiny and up-to-date!"
            return
        else
            # We should prompt the user and ask if we can update the Aquarium CLI
            # As well as show them a brief changelog, from the incoming release
            set changelog (cat $incomingFileLocation | jq -r '.body')
            echo "🔮 Cauldron Update Available 🔮" | rain-effect
            echo $changelog | shiny pager
        end
    else
        # They have never run the update tool before, so lets run it for them
        # Store a version of the latest release in a temp file
        set incomingFileLocation ~/.config/cauldron/_temp_latestRelease.json
        # Generate a new temp file with the latest release
        getLatestGithubReleaseAsJSON MagikIO/cauldron -s >$incomingFileLocation
        # Get the version of the incoming release
        set incomingVersion (cat $incomingFileLocation | jq -r '.tag_name')
        # We should prompt the user and ask if we can update the Aquarium CLI
        # As well as show them a brief changelog, from the incoming release
        set changelog (cat $incomingFileLocation | jq -r '.body')
        banner "Update Avail!" | rain-effect
        echo $changelog | shiny pager
    end
end
