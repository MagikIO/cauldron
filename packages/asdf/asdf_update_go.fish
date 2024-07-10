
function asdf_update_go -d 'Update go to the latest version'
  asdf install go latest
  asdf global go latest
  # Check if there are any local .rb files
  if test -f go.mod
    asdf local go latest
  end
end
