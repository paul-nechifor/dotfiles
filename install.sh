#!/bin/bash

install_dir="$HOME/.pn-dotfiles"
config_dir="$install_dir/config"
install_source="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
install_script="$install_source/$( basename "${BASH_SOURCE[0]}" )"

determine_environment() {
  if [[ ! $ran_before ]]; then
    echo 'Determining environment...'
    export ran_before=true
  fi

  if [[ $(id -u pnechifor 2>/dev/null) ]]; then
    username=pnechifor
  else
    username=p
  fi

  export is_linux=`if [[ "$OSTYPE" == "linux-gnu" ]]; then echo true; fi`
  export is_freebsd=`if [[ "$OSTYPE" == "freebsd"* ]]; then echo true; fi`
  if [[ $is_linux ]]; then
    export is_ubuntu=`if [[ $(grep Ubuntu /etc/issue) ]]; then echo true; fi`
    export is_centos=`if [[ $(grep CentOS /etc/issue) ]]; then echo true; fi`
  fi
  export own_computer=$is_ubuntu
}

root_start() {
  if [ "`id -u`" != "0" ]; then
    echo 'Switching to root...'
    sudo bash '$install_script' install_dotfiles
    return
  fi

  create_user
  su $username -c "bash '$install_script' install_dotfiles"
  link_root_files
  su $username -c "bash '$install_script' link_user_files"
}

user_start() {
  install_dotfiles
  link_user_files
}

create_user() {
  id -u $username >/dev/null
  if [ "$?" -eq 0 ]; then
    return
  fi
  echo "Creating user ${username}..."
  adduser $username --home /home/$username
}

install_dotfiles() {
  echo 'Installing dotfiles...'
  mkdir -p "$install_dir" 2>/dev/null
  rsync -a --del "$install_source/" "$install_dir/"
}

link_root_files() {
  echo 'Linking root files...'
  link_common_files

  rm -f /usr/share/X11/xkb/symbols/ro
  ln -s "$config_dir/xkb/layout" /usr/share/X11/xkb/symbols/ro
  dpkg-reconfigure xkb-data
  setxkbmap ro
}

link_user_files() {
  echo 'Linking user files...'
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

  rm -f ~/.cmus/autosave
  mkdir ~/.cmus 2>/dev/null
  ln -s "$config_dir/cmus/autosave" ~/.cmus/autosave

  provision_vim
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

infect() {
  echo 'Downloading dotfiles archive...'
  wget -q 'https://github.com/paul-nechifor/dotfiles/archive/master.zip'
  unzip -q master.zip
  rm master.zip

  echo 'Starting installation...'
  bash dotfiles-master/install.sh

  echo 'Cleaning up...'
  rm -fr dotfiles-master

  echo 'Sourcing runcom...'
  . ~/.bashrc

  echo -e "\033[33m☢  Infection complete ☢ \033[0m\033[0;0m"
}

main() {
  determine_environment

  if [ "$#" -eq 0 ]; then
    if [[ $own_computer ]]; then
      root_start
    else
      user_start
    fi
  else
    $1
  fi
}

main "$@"
