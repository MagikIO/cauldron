
function asdf_update_go -d 'Update go to the latest version'
  if contains golang (asdf plugin list)
    asdf install golang latest
    asdf global golang latest
    # Check if there are any local .rb files
    if test -f go.mod
      asdf local golang latest
    end
  end
end
