function getLatestGithubReleaseTag --argument target
# Fetch the latest GitHub release information as JSON and store it in a variable
set json (getLatestGithubReleaseAsJSON -s $target)

# Parse the 'tag_name' from the JSON
set latestVersion (echo $json | jq -r '.tag_name')

# Use the latest version as needed
echo $latestVersion
end
