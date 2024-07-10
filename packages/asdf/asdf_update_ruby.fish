#!/usr/bin/env fish

function asdf_update_ruby -d 'Update Ruby to the latest version'
  asdf install ruby latest
  asdf global ruby latest
  # Check if there are any local .rb files
  if test -f .ruby-version -o -f Gemfile
    asdf local ruby latest
  end
end
