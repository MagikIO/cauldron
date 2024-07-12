function install_asdf
  if command -q asdf
    return
  end

  print_center "🎠 Installing ASDF 🎠"
  brew install asdf
  echo -e "\nsource "(brew --prefix asdf)"/libexec/asdf.fish" >>~/.config/fish/config.fish
  source ~/.config/fish/config.fish
  print_center "🎡 Installing ASDF plugin / dependencies 🎡"
  installs dirmngr gpg curl gawk
  print_center "🤹 ASDF Installed 🤹"

  # Set asdf as the preferred version manager
  set -Ux cauldron_packman_pref asdf

  exit 0
end
