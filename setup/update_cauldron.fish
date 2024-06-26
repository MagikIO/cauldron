function update_cauldron
  # getLatestGithubReleaseAsJSON MagikIO/cauldron >~/.config/cauldron/latestRelease.json
  # Check if ~/.config/cauldron/latestRelease.json exists
  if test -f ~/.config/cauldron/latestRelease.json
    # Now we use the getLatestGithubReleaseAsJSON function to get the latest release to compare against
    # We will use the jq command to parse the JSON, and compare the 'tag_name' to the current version
    set latestInstalledVersion (jq -r '.tag_name' ~/.config/cauldron/latestRelease.json)
    # Store a version of the latest release in a temp file
    set incomingFileLocation ~/.config/cauldron/_temp_latestRelease.json
    getLatestGithubReleaseAsJSON MagikIO/cauldron -s >$incomingFileLocation
    set incomingVersion (cat $incomingFileLocation | jq -r '.tag_name')
    if test $latestInstalledVersion = $incomingVersion
      f-says "Our Cauldron is shiny and up-to-date! 🧙‍♂️🔮🧙‍♀️"
      return
    else
      # We should prompt the user and ask if we can update the Aquarium CLI
      # As well as show them a brief changelog, from the incoming release
      set changelog (cat $incomingFileLocation | jq -r '.body')
      styled-banner "🔮🧙‍♂️🔮🧙‍♀️ Cauldron Update Available 🔮🧙‍♂️🔮🧙‍♀️"
    end
  end
end
