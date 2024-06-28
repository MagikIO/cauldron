# [`save_theme`](../../functions/save_theme.fish)

## Overview

[`save_theme`](../../functions/save_theme.fish) is a utility script designed for the Aquarium theme management system. It allows users to save, list, edit, and remove theme variables that are set on launch.

## Features

- **Save Variables**: Persistently save theme variables for the Fish shell environment.
- **List Variables**: Display all saved theme variables.
- **Edit Theme File**: Open the theme file in the default or specified text editor for manual modifications.
- **Remove Variables**: Delete specific theme variables from the theme configuration.

## Usage

```fish
save_theme [options] var_key var_value
```

### Options

- `-v`, `--version`: Display the script version.
- `-h`, `--help`: Show the help message with usage instructions.
- `-r`, `--remove`: Remove a specified variable from the theme configuration.
- `-l`, `--list`: List all variables saved in the theme configuration.
- `-e`, `--edit`: Open the theme configuration file in the default or specified text editor.

### Examples

- **Save a Variable**: `save_theme _SIMPLE_GIT_ICON \ue708`
- **List Variables**: `save_theme -l`
- **Edit Theme File**: `save_theme -e`
- **Remove a Variable**: `save_theme -r _SIMPLE_GIT_ICON`

## Implementation Details

- **Theme Configuration File**: The script operates on a theme configuration file defined by the `AQUA__CONFIG_FILE` environment variable. This file is typically located at `$AQUARIUM_INSTALL_DIR/user_theme.fish`.
- **Editor Selection**: If the `-e` option is used, the script attempts to open the theme configuration file in the user's preferred editor. It defaults to Visual Studio Code (`code -n`) if available, or falls back to `nano` if no preference is set.
- **Variable Management**: The script can add new variables to the theme configuration file or update existing ones. When removing a variable, it searches for the specific `set -Ux var_key` pattern and deletes the corresponding line.

## Requirements

- **Fish Shell**: As this script is written for the Fish shell, it requires Fish to be installed and configured on the system.
- **Aquarium Installation**: The script is part of the Aquarium project. Ensure that Aquarium is properly installed and configured before using this script.

For more information about the Aquarium project and its features, visit the [Aquarium GitHub repository](https://github.com/anandamideio/aquarium).
