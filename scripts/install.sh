#!/bin/bash

username="p"
install_dir="/opt/pn-dotfiles"
config_dir="/opt/pn-dotfiles/config"
install_source="`pwd`"
install_script="$install_source/$0"

function main() {
  if [ "$#" -eq 0 ]; then
    root_start
  else
    # Run which ever parameter is given.
    $1
  fi
}

root_start() {
  if [ "`id -u`" != "0" ]; then
    echo "You are not root."
    exit 1
  fi

  create_user
  install_dotfiles
  link_root_files

  su $username -c "bash '$install_script' user_start"
}

user_start() {
  link_user_files
}

create_user() {
  id -u $username >/dev/null
  if [ "$?" -eq 0 ]; then
    return
  fi
  adduser $username --home /home/$username
}

install_dotfiles() {
  mkdir -p "$install_dir" 2>/dev/null
  rsync -a --del "$install_source/" "$install_dir/"
}

link_root_files() {
  link_common_files

  rm -f /usr/share/X11/xkb/symbols/ro
  ln -s "$config_dir/xkb/layout" /usr/share/X11/xkb/symbols/ro
  dpkg-reconfigure xkb-data
  setxkbmap ro

  provision_vim
}

link_user_files() {
  link_common_files

  rm -f ~/.gitconfig
  ln -s "$config_dir/git/config" ~/.gitconfig

  rm -f ~/.gitignore
  ln -s "$config_dir/git/ignore" ~/.gitignore

  rm -f ~/.tmux.conf
  ln -s "$config_dir/tmux/tmux.conf" ~/.tmux.conf

  rm -f ~/.i3/config
  mkdir ~/.i3 2>/dev/null
  ln -s "$config_dir/i3/config" ~/.i3/config

  rm -f ~/.config/i3status/config
  mkdir -p ~/.config/i3status 2>/dev/null
  ln -s "$config_dir/i3/status" ~/.config/i3status/config
}

link_common_files() {
  rm -f ~/.bashrc
  ln -s "$config_dir/bash/bashrc" ~/.bashrc

  rm -f ~/.vimrc
  ln -s "$config_dir/vim/vimrc" ~/.vimrc
}

provision_vim() {
  bash "$install_dir/provision/vim.sh"
}

main "$@"
