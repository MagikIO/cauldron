#!/usr/bin/env fish

function __update_install_functions -d 'Copy all Fish functions from source to config directory'
  # Returns: Number of functions copied

  set -l functions_dir "$CAULDRON_CONFIG_DIR/functions"
  mkdir -p "$functions_dir"
  
  set -l updated_count 0

  # Copy all function directories
  set -l function_dirs alias cli config effects functions familiar internal setup text UI update
  for dir in $function_dirs
    if test -d "$CAULDRON_PATH/$dir"
      for func_file in "$CAULDRON_PATH/$dir"/*.fish
        if test -f $func_file
          cp -f $func_file "$functions_dir/" 2>/dev/null
          set updated_count (math $updated_count + 1)
        end
      end
    end
  end

  # Copy package functions
  if test -d "$CAULDRON_PATH/packages/asdf"
    for func_file in "$CAULDRON_PATH/packages/asdf"/*.fish
      if test -f $func_file
        cp -f $func_file "$functions_dir/" 2>/dev/null
        set updated_count (math $updated_count + 1)
      end
    end
  end

  if test -d "$CAULDRON_PATH/packages/nvm"
    for func_file in "$CAULDRON_PATH/packages/nvm"/*.fish
      if test -f $func_file
        cp -f $func_file "$functions_dir/" 2>/dev/null
        set updated_count (math $updated_count + 1)
      end
    end
  end

  if test -f "$CAULDRON_PATH/packages/choose_packman.fish"
    cp -f "$CAULDRON_PATH/packages/choose_packman.fish" "$functions_dir/" 2>/dev/null
    set updated_count (math $updated_count + 1)
  end

  echo $updated_count
  return 0
end
