# `update_repo`

[`update_repo`](../../functions/update_repo.fish) is a tool designed to streamline the maintenance process of your projects. This script automates several routine tasks to ensure that the development environment remains up-to-date and optimized for performance. It's designed to be run automatically whenever Visual Studio Code is opened, but can also be executed manually from the terminal.

## Version

- **Version:** 1.3.0

## Synopsis

```fish
update_repo
```

## Features

- **Aquarium Installation Check:** Ensures that the Aquarium toolset is installed. If not, it attempts to install it.
- **Package Manager Preference:** Determines the user's preferred Node.js package manager (`asdf` or `nvm`) and ensures the correct Node.js version is set.
- **Repository Updates:** Fetches the latest changes from the repository, allows the user to choose a working branch, and pulls the latest changes for that branch.
- **Branch Cleanup:** Removes local branches that are no longer present on the remote repository.
- **System Updates:** Performs a system-wide update for installed packages and cleans up unnecessary packages.
- **Homebrew Management:** Updates, upgrades, and performs maintenance on the Homebrew package manager.
- **Yarn Dependency Management:** Updates Yarn dependencies and allows interactive upgrades.
