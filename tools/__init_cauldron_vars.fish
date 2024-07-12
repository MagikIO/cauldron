#!/usr/bin/env fish

# Path must exist for us to use
if not set -q CAULDRON_PATH
  set -Ux CAULDRON_PATH $HOME/.config/cauldron

  if not test -d $CAULDRON_PATH
    mkdir -p $CAULDRON_PATH
  end
end

if not set -q __CAULDRON_DOCUMENTATION_PATH
  set -Ux __CAULDRON_DOCUMENTATION_PATH $CAULDRON_PATH/docs

  if not test -d $__CAULDRON_DOCUMENTATION_PATH
    mkdir -p $__CAULDRON_DOCUMENTATION_PATH
  end
end

if not set -q CAULDRON_GIT_REPO
  set -Ux CAULDRON_GIT_REPO "https://github.com/MagikIO/cauldron.git"
end

if not set -q CAULDRON_DATABASE
  set -Ux CAULDRON_DATABASE $CAULDRON_PATH/data/cauldron.db

  if not test -f $CAULDRON_DATABASE
    mkdir -p $CAULDRON_PATH/data
    touch $CAULDRON_DATABASE
  end
else
  if not set -q CAULDRON_VERSION
    set -gx CAULDRON_VERSION (sqlite3 $CAULDRON_DATABASE "SELECT version FROM cauldron") 2> /dev/null

    if test -z $CAULDRON_VERSION
      set -gx CAULDRON_VERSION (git ls-remote --tags $CAULDRON_GIT_REPO | awk '{print $2}' | grep -o "v[0-9]*\.[0-9]*\.[0-9]*" | sort -V | tail -n 1 | sed 's/v//')
      sqlite3 $CAULDRON_DATABASE "INSERT INTO cauldron (version) VALUES ('$CAULDRON_VERSION')"
    end
  end
end

if not set -q CAULDRON_INTERNAL_TOOLS
  set -Ux CAULDRON_INTERNAL_TOOLS $CAULDRON_PATH/tools

  if not test -d $CAULDRON_INTERNAL_TOOLS
    mkdir -p $CAULDRON_INTERNAL_TOOLS
  end
end
