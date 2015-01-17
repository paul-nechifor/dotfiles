#!/usr/bin/env bash

set -e

install_source="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
install_script="$install_source/$( basename "${BASH_SOURCE[0]}" )"

determine_environment() {
  if [[ ! $ran_before ]]; then
    echo 'Determining environment...'
    export ran_before=true
  fi

  export is_vagrant=$(if [[ "$(id -u vagrant 2>/dev/null)" ]]; then echo true; fi)

  if [[ $is_vagrant ]]; then
    username=vagrant
  elif [[ $(id -u pnechifor 2>/dev/null) ]]; then
    username=pnechifor
  else
    username=p
  fi

  if [ "`id -u`" == "0" ]; then
    export install_dir="$(su $username -c 'echo $HOME')/.pn-dotfiles"
  else
    export install_dir="$HOME/.pn-dotfiles"
  fi
  export config_dir="$install_dir/config"

  export is_linux=`if [[ "$OSTYPE" == "linux-gnu" ]]; then echo true; fi`
  export is_freebsd=`if [[ "$OSTYPE" == "freebsd"* ]]; then echo true; fi`
  if [[ $is_linux ]]; then
    export is_ubuntu=`if [[ $(grep Ubuntu /etc/issue) ]]; then echo true; fi`
    export is_centos=`if [[ $(grep CentOS /etc/issue) ]]; then echo true; fi`
  fi
  export own_computer=$(if [[ $is_ubuntu && ! $is_vagrant ]]; then echo true; fi)
}

check_for_requirements() {
  local to_install=""

  if [[ ! "`unzip -v 2>/dev/null`" ]]; then
    to_install+=" unzip"
  fi

  if [[ ! "$to_install" ]]; then
    return
  fi

  echo 'Trying to install requirements...'

  if [[ $is_ubuntu ]]; then
    sudo -SE apt-get -y install -qq $to_install
  elif [[ $is_centos ]]; then
    sudo -SE yum -y install $to_install
  else
    echo "Could not find or install requirements: $to_install"
    exit 1
  fi
}

root_start() {
  local exports="export ran_before=$ran_before http_proxy='$http_proxy' https_proxy='$https_proxy' ignore_security_because_why_not=$ignore_security_because_why_not"
  if [ "`id -u`" != "0" ]; then
    echo 'Switching to root...'
    sudo -SE su -c "$exports; bash '$install_script' root_start"
    return
  fi

  check_for_requirements

  create_user
  su $username -c "$exports; bash '$install_script' install_dotfiles"
  link_root_files
  su $username -c "$exports; bash '$install_script' link_user_files"
}

user_start() {
  check_for_requirements
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
  mkdir ~/.i3 2>/dev/null || true
  ln -s "$config_dir/i3/config" ~/.i3/config

  rm -f ~/.config/i3status/config
  mkdir -p ~/.config/i3status 2>/dev/null || true
  ln -s "$config_dir/i3/status" ~/.config/i3status/config

  rm -f ~/.cmus/autosave
  mkdir ~/.cmus 2>/dev/null || true
  ln -s "$config_dir/cmus/autosave" ~/.cmus/autosave

  provision_vim

  if [[ $DISPLAY ]]; then
    setxkbmap ro
  fi
}

link_common_files() {
  rm -f ~/.bashrc
  ln -s "$config_dir/bash/bashrc" ~/.bashrc

  rm -f ~/.vimrc
  ln -s "$config_dir/vim/vimrc" ~/.vimrc
}

create_vim_structure() {
  echo '  Recreating Vim folder structure...'
  mkdir ~/.vimswap ~/.vimundo 2>/dev/null || true
  rm -fr ~/.vim
  mkdir ~/.vim
  cd ~/.vim
  mkdir autoload bundle doc plugin syntax
}

wgetq() {
  if [[ $ignore_security_because_why_not ]]; then
    args=--no-check-certificate
  fi
  wget $args -q "$1"
}

get_pathogen() {
  cd ~/.vim/autoload
  echo '  Downloading pathogen...'
  wgetq https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
}

wget_master() {
  wgetq https://github.com/$1/archive/master.zip
  unzip -q master.zip
  rm master.zip
}

install_from_github() {
  cd ~/.vim/bundle
  echo "  Downloading module $1..."
  wget_master $2
  mv *-master $1
}

install_vim_modules() {
  install_from_github coffee-script kchmck/vim-coffee-script
  install_from_github ctrlp kien/ctrlp.vim
  install_from_github gitgutter airblade/vim-gitgutter
  install_from_github jade digitaltoad/vim-jade
  install_from_github move matze/vim-move
  install_from_github nerdtree scrooloose/nerdtree
  install_from_github stylus wavded/vim-stylus
}

provision_vim() {
  echo 'Provisioning Vim...'
  create_vim_structure
  get_pathogen
  install_vim_modules
}

infect() {
  check_for_requirements

  echo 'Downloading dotfiles archive...'
  wget_master paul-nechifor/dotfiles

  echo 'Starting installation...'
  bash dotfiles-master/install.sh

  echo 'Cleaning up...'
  rm -fr dotfiles-master

  echo -e "\033[33m☢ \033[0m Infection complete. \033[33m☢ \033[0m"
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
