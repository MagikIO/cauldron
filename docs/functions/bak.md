# `bak`

[`bak`](../../functions/bak.fish) is designed to create backup copies of files or directories. It simplifies the process of saving previous versions of your work by appending a timestamp or a custom suffix to the file or directory name.

## Version

- **Version:** [Your Version Here]

## Synopsis

```shell
bak [options] <file_or_directory>
```

## Options

- `-h`, `--help`: Display this help message.
- `-v`, `--version`: Display the version of the function.
- `-s`, `--suffix`: Specify a custom suffix for the backup. Defaults to a timestamp.
- `-d`, `--directory`: Backup an entire directory.
- `-c`, `--compress`: Compress the backup into a zip file.

## Description

The `bak.fish` function is a utility for quickly creating backups of files or directories. By default, it appends a timestamp to the file or directory name to create a unique backup. Users can also specify a custom suffix with the `-s` option or choose to compress the backup into a zip file with the `-c` option. This function is particularly useful for preserving the state of files or directories before making significant changes.

### 📝 Backup Creation

To create a backup of a file with a timestamp:

```shell
bak myfile.txt
```

To create a backup of a directory and compress it:

```shell
bak -d -c mydirectory
```

Upon execution, the function will create a backup of the specified file or directory, applying the chosen options.
