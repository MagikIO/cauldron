# `bold`

## Overview

[`bold`](../../text/bold.fish) is a utility within cauldron designed to make it easy to make print bold text to stdout. This function is useful for creating visually distinct output in scripts or terminal sessions.

## Version

- **Version**: 1.0.0
- **Category**: Text

## Syntax

```shell
bold [options] --argument text
```

## Parameters

- `--argument text`: Specifies the text to be formatted in bold. This is a required argument.

## Options

- `-v`, `--version`: Displays the version of the `bold` function.
- `-h`, `--help`: Displays help information about the `bold` function.

## Usage Examples

### Basic Usage

To print "Hello, World!" in bold:

```shell
bold 'Hello, World!'
```

### Combined Usage

To combine text, where only part of it is in bold:

```shell
echo -n "Hello "(bold 'Bilbo')"
```

This will output "Hello" in normal text followed by "Bilbo" in bold.

## Description

The `bold` function utilizes the `set_color` command available in Fish shell to apply bold formatting to the specified text. It supports two flag options for displaying version information and help documentation. This function is useful for creating visually distinct output in scripts or terminal sessions.

When the `--version` or `--help` options are used, the function will return the requested information and exit. If no options are provided, the function will proceed to format the provided text in bold and output it to the terminal.

## Additional Notes

- The appearance of bold text may vary depending on the terminal emulator and settings used.
