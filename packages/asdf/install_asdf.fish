function install_asdf
  print_center "🎠 Installing ASDF 🎠"
  brew install asdf
  echo -e "\nsource "(brew --prefix asdf)"/libexec/asdf.fish" >>~/.config/fish/config.fish
  source ~/.config/fish/config.fish
  print_center "🎡 Installing ASDF plugin / dependencies 🎡"
  installs dirmngr gpg curl gawk
  asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf install nodejs latest
  print_center "🤹 ASDF Installed 🤹"

  # Set asdf as the preferred version manager
  set -Ux cauldron_packman_pref asdf
end
