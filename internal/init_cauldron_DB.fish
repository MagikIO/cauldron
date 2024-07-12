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

  # Make sure add the most recent version to the DB
  set currVersion (git ls-remote --tags $CAULDRON_GIT_REPO | awk '{print $2}' | grep -o "v[0-9]*\.[0-9]*\.[0-9]*" | sort -V | tail -n 1 | sed 's/v//')
  sqlite3 $CAULDRON_DATABASE "INSERT INTO cauldron (version) VALUES ('$currVersion')"
end
