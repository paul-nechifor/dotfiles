#!/bin/bash

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
  export own_computer=$is_ubuntu
}

root_start() {
  if [ "`id -u`" != "0" ]; then
    echo 'Switching to root...'
    sudo -S su -c "export ran_before=$ran_before; bash '$install_script' root_start"
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

  setxkbmap ro
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

get_pathogen() {
  cd ~/.vim/autoload
  echo '  Downloading pathogen...'
  wget -q 'https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim'
}

install_from_git() {
  cd ~/.vim/bundle
  echo "  Downloading module $1..."
  git clone -q --depth=1 "$2" $1
  rm -fr $1/.git
}

install_vim_modules() {
  install_from_git coffee-script 'https://github.com/kchmck/vim-coffee-script.git'
  install_from_git ctrlp 'https://github.com/kien/ctrlp.vim'
  install_from_git gitgutter 'https://github.com/airblade/vim-gitgutter.git'
  install_from_git jade 'https://github.com/digitaltoad/vim-jade.git'
  install_from_git move 'https://github.com/matze/vim-move'
  install_from_git nerdtree 'https://github.com/scrooloose/nerdtree.git'
  install_from_git stylus 'https://github.com/wavded/vim-stylus.git'
}

provision_vim() {
  echo 'Provisioning Vim...'
  create_vim_structure
  get_pathogen
  install_vim_modules
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
