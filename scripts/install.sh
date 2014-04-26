#!/bin/bash

username="p"
install_dir="/opt/pn-dotfiles"
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
  ln -s "$install_dir/xkb_layout" /usr/share/X11/xkb/symbols/ro

  provision_vim
}

link_user_files() {
  link_common_files

  rm -f ~/.gitconfig
  ln -s "$install_dir/gitconfig" ~/.gitconfig

  rm -f ~/.gitignore
  ln -s "$install_dir/gitignore" ~/.gitignore

  rm -f ~/.i3/config
  mkdir ~/.i3 2>/dev/null
  ln -s "$install_dir/i3-config" ~/.i3/config
}

link_common_files() {
  rm -f ~/.bashrc
  ln -s "$install_dir/bashrc" ~/.bashrc

  rm -f ~/.vimrc
  ln -s "$install_dir/vimrc" ~/.vimrc
}

provision_vim() {
  bash "$install_dir/provision/vim.sh"
}

main "$@"
