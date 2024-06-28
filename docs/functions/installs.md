# [`installs.fish`](../../functions/installs.fish)

[`installs.fish`](../../functions/installs.fish) is a comprehensive Fish shell script designed to streamline the installation of software across different package managers including APT (for Debian-based systems), Homebrew (for macOS and Linux), and Snap (for Snap-supported Linux distributions). This script not only facilitates the installation of individual programs but also supports batch installations from a JSON-formatted dependency file.

## Version

- **Version:** 2.1.0

## Synopsis

```shell
installs [options] <program> [program] [program] ...
```

### Options

- `-v`, `--version`: Displays the script version.
- `-h`, `--help`: Shows the help message with usage instructions.
- `-s`, `--snap`: Specifies programs to be installed using Snap.
- `-b`, `--brew`: Specifies programs to be installed using Homebrew.
- `-f`, `--file`: Specifies a JSON file containing a list of programs to install.
- `-d`, `--dry-run`: Shows what would be installed without actually performing the installation.
- `-z`, `--debug`: Enables debug mode for additional output.

### Examples

- Install individual programs:

  ```shell
  installs bat curl git
  ```
  
- Install programs using specific package managers:

  ```shell
  installs -s "lolcat-c" -b "glow fzf timg"
  ```
  
- Install programs from a dependency file:

  ```shell
  installs -f dependencies.json
  ```

## Dependency File Format

The dependency file should be in JSON format with keys for each package manager (`apt`, `brew`, `snap`) and an array of program names as values. Example:

```json
{
  "apt": ["bat", "curl"],
  "brew": ["glow", "fzf"],
  "snap": ["lolcat-c"]
}
```
