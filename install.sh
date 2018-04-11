#!/usr/bin/env bash

set -e

install_source="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
install_script="$install_source/$(basename "${BASH_SOURCE[0]}")"

main() {
  determine_environment

  if [[ $1 ]]; then
    "$@"
    return
  fi
  if [[ $own_computer ]]; then
    root_start
  else
    user_start
  fi
}

infect() {
  local tmpdir

  check_for_requirements
  tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t infect)

  echo 'Downloading dotfiles archive...'
  cd "$tmpdir"
  wget_master paul-nechifor/dotfiles

  echo 'Starting installation...'
  bash dotfiles-master/install.sh

  echo 'Cleaning up...'
  cd
  rm -fr "$tmpdir"

  echo -e "\033[33m☢ \033[0m Infection complete. \033[33m☢ \033[0m"
}

determine_environment() {
  if [[ ! $ran_before ]]; then
    echo 'Determining environment...'
    export ran_before=true
  fi

  set +e

  is_vagrant="$(id -u vagrant 2>/dev/null && echo 1)"
  if [[ ! $username ]]; then
    username=$(whoami)
  fi

  if [[ $(id -u) -eq 0 ]]; then
    install_dir="$(su "$username" -c "echo \$HOME")/.pn-dotfiles"
  else
    install_dir="$HOME/.pn-dotfiles"
  fi
  export config_dir="$install_dir/config"

  is_linux=$([[ $OSTYPE == linux-gnu ]] && echo 1)
  is_freebsd=$([[ $OSTYPE == freebsd* ]] && echo 1)
  if [[ $is_linux ]]; then
    is_ubuntu=$(grep Ubuntu /etc/issue && echo 1)
    is_centos=$(grep CentOS /etc/issue && echo 1)
  fi
  own_computer=$([[ $is_ubuntu && ! $is_vagrant ]] && echo 1)

  export is_vagrant install_dir config_dir is_linux is_freebsd is_ubuntu
  export is_centos own_computer

  set -e
}

check_for_requirements() {
  local to_install=""

  if [[ ! $(unzip -v 2>/dev/null) ]]; then
    to_install+=" unzip"
  fi

  if [[ ! "$to_install" ]]; then
    return
  fi

  echo 'Trying to install requirements...'

  if [[ $is_ubuntu ]]; then
    sudo -SE apt-get -y install -qq "$to_install"
  elif [[ $is_centos ]]; then
    sudo -SE yum -y install "$to_install"
  else
    echo "Could not find or install requirements: $to_install"
    exit 1
  fi
}

root_start() {
  local exports=(
    ran_before="$ran_before"
    http_proxy="$http_proxy"
    https_proxy="$https_proxy"
    ignore_security_because_why_not="$ignore_security_because_why_not"
    username="$username"
  )
  if [[ $(id -u) -ne 0 ]]; then
    echo 'Switching to root...'
    sudo -SE su -c "${exports[*]} bash '$install_script' root_start"
    return
  fi

  check_for_requirements

  create_user
  su "$username" -c "${exports[*]}; bash '$install_script' install_dotfiles"
  link_root_files
  su "$username" -c "${exports[*]}; bash '$install_script' link_user_files"

  if grep 'Ubuntu 16.04' /etc/issue &>/dev/null; then
    bash "$install_source"/provision/ubuntu16.04.sh
  elif lsb_release -r | egrep '\b18\.\b' &>/dev/null; then
    bash "$install_source"/provision/ubuntu18.sh
  fi
}

user_start() {
  check_for_requirements
  install_dotfiles
  link_user_files
  post_install
}

create_user() {
  id -u "$username" >/dev/null
  if [[ $? -eq 0 ]]; then
    return
  fi
  echo "Creating user ${username}..."
  adduser "$username" --home "/home/$username"
}

install_dotfiles() {
  echo 'Installing dotfiles...'
  rm -fr "$install_dir"
  cp -r "$install_source/" "$install_dir/"
}

link_root_files() {
  echo 'Linking root files...'
  link_common_files

  rm -f /usr/share/X11/xkb/symbols/ro
  ln -s "$config_dir/xkb/layout" /usr/share/X11/xkb/symbols/ro
  dpkg-reconfigure xkb-data
}

# Remove a directory (relative to home) and recreate it.
wipeout() {
  rm -fr "${HOME:?}/$1"
  mkdir -p "$HOME/$1" 2>/dev/null || true
}

link_file() {
  rm -f "$HOME/$2"
  ln -s "$config_dir/$1" "$HOME/$2"
}

link_user_files() {
  echo 'Linking user files...'
  link_common_files

  link_file ack/rc .ackrc
  link_file git/config .gitconfig
  link_file git/ignore .gitignore
  link_file input/inputrc .inputrc
  link_file tmux/tmux.conf .tmux.conf
  link_file x/modmap .Xmodmap
  link_file x/resources .Xresources

  wipeout .i3
  link_file i3/config .i3/config

  wipeout .config/i3status
  link_file i3/status .config/i3status/config

  mkdir -p "$HOME/.cmus"
  link_file cmus/autosave .cmus/autosave

  wipeout .config/dunst
  link_file dunst/rc .config/dunst/dunstrc

  link_file python/pythonrc.py .pythonrc

  mkdir -p ~/.subversion >/dev/null 2>&1
  link_file svn/config .subversion/config

  provision_vim

  if [[ $DISPLAY ]]; then
    setxkbmap ro
  fi

  if [[ $is_freebsd ]]; then
    bash "$install_dir/provision/freebsd.sh"
  fi

  if [[ $is_centos ]]; then
    bash "$install_dir/provision/centos6.sh"
  fi

  mkdir ~/.local-build-commands 2>/dev/null || true

  touch ~/.hushlogin
}

link_common_files() {
  rm -f ~/.bashrc
  ln -s "$config_dir/bash/bashrc.sh" ~/.bashrc

  rm -f ~/.vimrc
  ln -s "$config_dir/vim/vimrc.vim" ~/.vimrc

  rm -f ~/.vim-spellfile.utf8.add
  ln -s "$config_dir/vim/spellfile" ~/.vim-spellfile.utf8.add

  rm -f ~/.dircolors
  ln -s "$config_dir/dircolors/dircolors" ~/.dircolors
}

post_install() {
  cd /tmp
  # Change 'push.default' from 'simple' to 'matching' for ancient versions.
  if git clone x 2>&1 | grep -q 'Malformed value for push.default'; then
    git config --global push.default matching
  fi
}

create_vim_structure() {
  echo '  Recreating Vim dir structure...'
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

  if [[ $2 ]]; then
    wget $args -q "$1" -O- > "$2"
  else
    wget $args -q "$1"
  fi
}

get_pathogen() {
  cd ~/.vim/autoload
  echo '  Downloading pathogen...'
  wgetq https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
}

wget_master() {
  wgetq "https://github.com/$1/archive/master.zip" master.zip
  unzip -q master.zip
  rm master.zip
}

install_from_github() {
  cd ~/.vim/bundle
  echo "  Downloading module $1..."
  wget_master "$2"
  mv ./*-master "$1"
}

install_vim_modules() {
  install_from_github ack mileszs/ack.vim
  install_from_github coffee-script kchmck/vim-coffee-script
  install_from_github commentary tpope/vim-commentary
  install_from_github ctrlp ctrlpvim/ctrlp.vim
  install_from_github easymotion Lokaltog/vim-easymotion
  install_from_github fugitive tpope/vim-fugitive
  install_from_github gitgutter airblade/vim-gitgutter
  install_from_github jade digitaltoad/vim-jade
  install_from_github javascript pangloss/vim-javascript
  install_from_github markdown tpope/vim-markdown
  install_from_github matchem ervandew/matchem
  install_from_github nerdtree scrooloose/nerdtree
  install_from_github perl vim-perl/vim-perl
  install_from_github rename danro/rename.vim
  install_from_github scss cakebaker/scss-syntax.vim
  install_from_github stylus wavded/vim-stylus
  install_from_github supertab ervandew/supertab
  install_from_github svn-blame paul-nechifor/vim-svn-blame
  install_from_github syntastic scrooloose/syntastic
  install_from_github textmanip t9md/vim-textmanip
  install_from_github tmux-navigator christoomey/vim-tmux-navigator

  # Patch CtrlP:
  if [[ $is_linux ]]; then
    sed -i "s/, '.svn'//" ~/.vim/bundle/ctrlp/autoload/ctrlp.vim
  else
    sed -i '' "s/, '.svn'//" ~/.vim/bundle/ctrlp/autoload/ctrlp.vim
  fi
}

provision_vim() {
  echo 'Provisioning Vim...'
  create_vim_structure
  get_pathogen
  install_vim_modules
  echo 'Provisioning Vim complete.'
}

main "$@"
