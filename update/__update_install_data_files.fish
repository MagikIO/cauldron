#!/usr/bin/env fish

function __update_install_data_files -d 'Copy data files to config directory'
  # Returns: 0 on success

  set -l data_dir "$CAULDRON_CONFIG_DIR/data"
  mkdir -p $data_dir
  
  if test -f "$CAULDRON_PATH/data/palettes.json"
    cp -f "$CAULDRON_PATH/data/palettes.json" $data_dir/palettes.json 2>/dev/null
  end
  
  if test -f "$CAULDRON_PATH/data/spinners.json"
    cp -f "$CAULDRON_PATH/data/spinners.json" $data_dir/spinners.json 2>/dev/null
  end

  return 0
end
