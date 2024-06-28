function bak -d 'Backup a file (make a copy with .bak extension)' -a file -d "File to backup" -a max_copies -d "Maximum number of copies to keep"
  # Version Number
  set -l func_version "1.0.2"
  # Flag options
  set -l options "v/version" "h/help" "V/verbose" "n/dry-run"
  argparse -n bak $options -- $argv

  # if they asked the version just return it
  if set -q _flag_version
    echo $func_version
    exit 0
  end

  # if they asked for help, show it
  if set -q _flag_help
    echo "Usage: bak [options] file"
    echo "Backup a file (make a copy with .bak extension)"
    echo ""
    echo "Options:"
    echo "  -v, --version  Show version number"
    echo "  -h, --help     Show this help"
    echo "  -V, --verbose  Show verbose output"
    echo "  -n, --dry-run  Show what would be done, but don't actually do it"
    exit 0
  end

  function print_verbose -a message
    if set -q _flag_verbose
      printf $message
    end
  end

  # if they didn't give a file, show an error
  if not set -q file
    echo "You must provide a file to edit"
    return
  end

  # if the file doesn't exist, show an error
  if not test -e $file
    echo "$file does not exist, at least not where I'm looking"
    return
  end

  # if the file is a directory, show an error
  if test -d $file
    echo "The $file is a directory, what are you trying to do?"
    return
  end

  # if the file is a symlink, show an error
  if test -L $file
    echo "The file $file is a symlink, this is not supported, or safe come to think of it"
    return
  end

  # if the file is not readable, show an error
  if not test -r $file
    echo "$file is not readable, I can't back it up, sorry.."
    return
  end

  # No more than 5 copies by default
  if not set -q max_copies
    set -l max_copies 5
  end

  ## The behavior should go:
  # 1. If there is no backup, make one as .bak
  # 2. If there is a backup, but no number suffixed backup, the backup called `.bak` should be renamed to `.1.bak` and a new `.bak` should be created
  # 3. If there is a backup with a number, the number should be incremented and a new `.bak` should be created
  # 4. If there are more than the max the user passed (or 5) backups, the oldest should be deleted
  if test -e $file.bak
    print_verbose "There is a backup of "(set_color green)$file(set_color normal)", let's see what we need to do"
    
    # If there is a backup, but no number suffixed backup, the backup called `.bak` should be renamed to `.1.bak` and a new `.bak` should be created
    if not test -e $file.1.bak
      print_verbose "There is a backup of "(set_color green)$file(set_color normal)" called "(set_color green)$file.bak(set_color normal)", but no numbered backups, let's fix that"
      mv $file.bak $file.1.bak
      print_verbose "Renamed "(set_color green)$file.bak(set_color normal)" to "(set_color green)$file.1.bak(set_color normal)"\n"
      cp $file $file.bak
      print_verbose "Created a new backup called "(set_color green)$file.bak(set_color normal)"\n"
    else
      # If there is a backup with a number, the number should be incremented and a new `.bak` should be created
      if test -e $file.1.bak
        print_verbose "There is a backup of "(set_color green)$file(set_color normal)" called "(set_color green)$file.1.bak(set_color normal)", let's see how many backups there are"
        for i in (seq $max_copies -1  1)
          if test -e $file.$i.bak
            print_verbose "There is a backup of "(set_color green)$file(set_color normal)" called "(set_color green)$file.$i.bak(set_color normal)", let's see if we are at max"
            # If we are at max, we need to delete the oldest
            if test $i -eq $max_copies
              print_verbose "There are already "(set_color green)$max_copies(set_color normal)" backups, let's delete the oldest one"
              rm $file.$i.bak
              print_verbose "Deleted "(set_color green)$file.$i.bak(set_color normal)"\n"
              break
            end

            # If we are above 1, we need to copy this backup to the next highest number
            if test $i -gt 1
              mv $file.$i.bak $file.($i + 1).bak
              print_verbose "Moved "(set_color green)$file.$i.bak(set_color normal)" to "(set_color green)$file.($i + 1).bak(set_color normal)"\n"
            else
              # If we are at 1, we need to make a new .bak
              mv $file.bak $file.1.bak
              print_verbose "Renamed "(set_color green)$file.bak(set_color normal)" to "(set_color green)$file.1.bak(set_color normal)"\n"
              cp $file $file.bak
              print_verbose "Created a new backup called "(set_color green)$file.bak(set_color normal)"\n"
            end
          end
        end
      end
    end
  else
    # If there is no backup, make one as .bak
    cp $file $file.bak
    print_verbose "Created a new backup called "(set_color green)$file.bak(set_color normal)"\n"
  end
end
