function init_cauldron_DB
  # First we need to make sure the DB exists and the var is set
  if not set -q CAULDRON_DATABASE
    set -Ux CAULDRON_DATABASE $CAULDRON_PATH/data/cauldron.db
  end

  # Now we need to make sure the DB exists
  if not test -f $CAULDRON_DATABASE
    touch $CAULDRON_DATABASE
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/schema.sql
  end

  # Now we need to make sure the DB is up to date
  if test -f $CAULDRON_PATH/data/update.sql
    sqlite3 $CAULDRON_DATABASE < $CAULDRON_PATH/data/update.sql
  end
end
