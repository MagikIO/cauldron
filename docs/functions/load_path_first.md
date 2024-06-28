# `load_path_first`

[`load_path_first`](../../functions/load_path_first.fish) is designed to modify the `PATH` environment variable in the Fish shell, moving a specified directory to the beginning of `PATH`. This ensures that commands in the specified directory are prioritized over other directories in `PATH`.

## Synopsis

```shell
load_path_first <directory>
```

- `<directory>`: The directory you want to prioritize in the `PATH` environment variable.

## Examples

To prioritize a directory `/usr/local/bin` in your `PATH`:

```shell
load_path_first /usr/local/bin
```

This command will adjust the `PATH` environment variable so that `/usr/local/bin` is searched before any other directories listed in `PATH`.
