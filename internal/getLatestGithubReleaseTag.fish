#!/usr/bin/env fish

function getLatestGithubReleaseTag --argument target
    # Check if the target is empty
    if test -z $target
        echo "Error: No target provided to getLatestGithubReleaseTag"
        return 1
    end

    # Fetch the latest GitHub release information as JSON and store it in a variable
    set json (getLatestGithubReleaseAsJSON $target -s)

    # Parse the 'tag_name' from the JSON
    set latestVersion (echo $json | jq -r '.tag_name')

    # Use the latest version as needed
    echo $latestVersion

    return 0
end
