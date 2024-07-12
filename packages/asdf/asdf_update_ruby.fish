#!/usr/bin/env fish

function asdf_update_ruby -d 'Update Ruby to the latest version'
  # We should run `asdf plugin list` and check if ruby is installed
  if contains ruby (asdf plugin list)
    asdf install ruby latest
    asdf global ruby latest
    # Check if there are any local .rb files
    if test -f .ruby-version -o -f Gemfile
      asdf local ruby latest
    end
  end
end
