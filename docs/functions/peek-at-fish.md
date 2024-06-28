# `peek-at-fish`

[`peek-at-fish`](../../functions/peek-at-fish.fish) enhances your Fish shell experience by allowing you to quickly preview and edit Fish functions. It utilizes `fzf` for fuzzy finding and `bat` for syntax-highlighted previews, providing an efficient way to navigate through your functions.

## Synopsis

```shell
peek-at-fish
```

## Description

When invoked, `peek-at-fish` presents a list of all available Fish functions using `fzf`. The right side of the `fzf` interface displays a preview of the function's source code, thanks to `bat`, with syntax highlighting and line numbers.

If the `EDITOR` environment variable is not set, `peek-at-fish` prompts the user to select a preferred editor from the installed options, including `code` (Visual Studio Code), `nano`, `vim`, `emacs`, and `gedit`. The selection process is facilitated by a custom `choose` function, and the chosen editor is then set globally for the current session.

Once a function is selected and an editor is set, `peek-at-fish` opens the function's source code in the chosen editor, allowing for immediate editing.

## Prerequisites

- `fzf`: For fuzzy finding and selecting functions.
- `bat`: For syntax-highlighted previews of function source code.
- One of the supported editors (`code`, `nano`, `vim`, `emacs`, `gedit`) installed, if the `EDITOR` environment variable is not already set.

## Setting the `EDITOR` Environment Variable

To streamline the use of `peek-at-fish`, you can predefine your preferred editor by setting the `EDITOR` environment variable in your Fish configuration file (`~/.config/fish/config.fish`):

```shell
set -gx EDITOR code # Replace 'code' with your preferred editor
```

This step is optional but recommended for users who frequently use `peek-at-fish` or other command-line tools that rely on the `EDITOR` variable.

## Example Usage

Simply run:

```shell
peek-at-fish
```

Use the keyboard to navigate through the list of functions. The preview pane on the right will automatically update to show the selected function's source code. Press `Enter` to open the selected function in your editor for editing.
