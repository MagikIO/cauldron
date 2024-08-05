# Changelog

All notable changes to this project will be documented in this file.

## [unreleased]

### 🚜 Refactor

- Improve directory creation and copying logic in cauldron_update.fish
- Improve directory creation and copying logic in cauldron_update.fish
- Improve directory creation and copying logic in cauldron_update.fish
- Update Homebrew and yarn in update_repo.fish
- Update package manager preference logic in choose_packman.fish
- Update ASDF installation logic and add Node.js plugin installation
- Update ASDF installation logic and add Node.js plugin installation
- Update ASDF installation logic and add Node.js plugin installation
- Update ASDF installation logic and add Node.js plugin installation
- Update ASDF installation logic and add Node.js plugin installation
- Update ASDF installation logic and add Node.js plugin installation
- Update ASDF installation logic and add Node.js plugin installation
- Update ASDF installation logic and add Node.js plugin installation
- Update ASDF installation logic and add Node.js plugin installation
- Add visual_git_checkout function for easier branch selection
- Add visual_git_checkout function for easier branch selection
- Improve visual_git_checkout function for easier branch selection
- Update Aquarium installation logic and add version check
- Update Aquarium installation logic, add version check, and improve visual_git_checkout function
- Update getLatestGithubReleaseTag function to handle empty target and improve error handling
- Update Aquarium installation logic and version check
- Update Aquarium installation logic to include verbose flag for version check
- Update update_repo function to include ASDF and Git updates
- Update update_repo function to include ASDF and Git updates
- Update devDependencies in package.json
- Update update_repo function to include ASDF and Git updates
- Update update_repo function to include ASDF and Git updates
- Update update_repo function to include ASDF and Git updates
- Update update_repo function to include ASDF and Git updates
- Update update_repo function to include ASDF and Git updates
- Update update_repo function to include ASDF and Git updates
- Update update_repo function to include ASDF and Git updates
- Update update_repo function to include ASDF and Git updates
- Update update_repo function to include ASDF and Git updates
- Include "update" folder in CAULDRON_LOCAL_DIRS
- Include "update" folder in CAULDRON_LOCAL_DIRS
- Update Cauldron update script to include version check and help option
- Update Cauldron update script to include version check and help option
- Update Cauldron update script to include version check and help option
- Update Cauldron update script to include version check and help option
- Update package.json script to remove unnecessary tag argument

## [0.3.1] - 2024-07-12

### 🚜 Refactor

- Improve directory creation and copying logic in cauldron_update.fish

### ⚙️ Miscellaneous Tasks

- Bump version to 0.3.1 and update changelog script

## [0.3.0] - 2024-07-12

### 🚜 Refactor

- Improve directory creation and copying logic in cauldron_update.fish
- Move init_cauldron_DB.fish to tools directory and rename to __init_cauldron_DB.fish
- Bump version to 0.3.0 in package.json

## [0.2.1] - 2024-07-12

### 🐛 Bug Fixes

- *(update)* Fixed a bug that caused the users data directory to not correctly back up

## [0.2.1] - 2024-07-12

### 🚜 Refactor

- Update cauldron_update.fish to improve directory creation and copying logic
- Improve directory creation and copying logic in cauldron_update.fish
- Improve directory creation and copying logic in cauldron_update.fish
- Update cauldron_update.fish to improve directory creation and copying logic
- Improve directory creation and copying logic in cauldron_update.fish
- Improve directory creation and copying logic in cauldron_update.fish
- Improve directory creation and copying logic in cauldron_update.fish

### ⚙️ Miscellaneous Tasks

- Update npm dependency to latest stable version
- Update npm dependency to latest stable version

## [0.2.0] - 2024-07-12

### 🚀 Features

- Update Cauldron to the latest version and improve installation process
- Update Cauldron to the latest version and improve installation process
- Add new function to update Git alias definition
- Add Yoda, Woodstock, Vault-Boy, and Wheatley cow files
- Add asdf_update_go and asdf_update_ruby scripts
- Add initial database schema and sample data
- Add function to initialize the database
- Add init_DB function to initialize the database
- Update cauldron CLI version to 1.1.0

### 🚜 Refactor

- Rename init_DB function to init_cauldron_DB
- Remove unnecessary code in test.fish

### 📚 Documentation

- Adds documentation for `bold` and `italic` fn
- Minor change to the formatting of `peet-at-fish` documentation
- Add `update_git_alias` documentation

### ⚙️ Miscellaneous Tasks

- Add familiar function to speak and think messages
- Update CAULDRON_LOCAL_DIRS in install.fish
- Refactor install.fish to use INSERT OR REPLACE for updating dependencies table
- Refactor cauldron.fish to add new options and update dependencies
- Update .gitignore to include excluded files and directories
- Update Node.js and TypeScript dependencies
- Update asdf_update_go and asdf_update_ruby scripts
- Update choose_packman.fish to version 1.0.1
- Update .gitignore to include excluded files and directories
- Update npm dependency to latest stable version
- Update npm dependency to latest stable version
- Update npm dependency to latest stable version
- Update npm dependency to version 0.2.0

## [unreleased]

### 🚀 Features

- Refactor cpfunc.fish function to use argparse for command line options
- Add `dev-it` function documentation
- Update documentation path and add new-docs flag to cauldron command
- Refactor fished.fish and peek-at-fish.fish functions, improve code readability and remove unused code
- Add `peek-at-fish` function for enhanced Fish shell experience
- Add `load_path_first` function to modify the `PATH` environment variable in Fish shell

### ⚙️ Miscellaneous Tasks

- Update iterate.fish to generate changelogs and push to main branch
- Update .gitignore to include all version control files
- Update .gitignore to include all version control files

## [0.0.8] - 2024-06-28

### 🚀 Features

- Add iterate function to move npm package forward and post it up
- Refactor node_init.fish function to improve readability and add command line options

### ⚙️ Miscellaneous Tasks

- Update changelog
- Update package.json repository URL to use git+https protocol
- Update iterate.fish to generate changelogs and push to main branch
- Update changelog

## [0.0.7] - 2024-06-27

### 🚀 Features

- Add getLatestGithubReleaseAsJSON function to retrieve the latest release of a GitHub repository
- Add getLatestGithubReleaseTag function to retrieve the latest GitHub release tag
- Add update_cauldron.fish script to check for Cauldron updates
- Add orbiting-volley-effect function
- Add rain-effect function
- Add shebang line to vhs-effect.fish
- Update update_cauldron.fish script to improve Cauldron update prompt
- Update npm dependency to latest stable version

### ⚙️ Miscellaneous Tasks

- Moved `shiny.fish` into the alias dir, from the text dir
- Refactor rainbow-fish.fish to move it from the text directory to the alias directory
- Marked styled-banner as not ready for release
- Update .vscode settings to exclude version control files and directories
- Update npm dependency to latest stable version

## [0.0.5] - 2024-06-26

### 🚀 Features

- Add new fish shell aliases
- Add palettes.json file with predefined color palettes
- Add installs.fish function for installing software
- Add palettes.json and move palettes.json to config directory
- Add familiars to cauldron.json
- Add new functions for bold, italic, and underline text formatting
- Add new functions for bold, italic, and underline text formatting
- Add SQLite3 to dependencies.json
- Add cpfunc to install.fish script
- Add aliases for nodejs installation and management
- Add nvm_update_node function for managing Node.js versions
- Add install_aquarium.fish script to install the Aquarium CLI
- Add Ouroboros CI workflow

### ⚙️ Miscellaneous Tasks

- Add VS Code settings and extensions configuration files

<!-- generated by git-cliff -->
