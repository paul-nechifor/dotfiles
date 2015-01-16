#!/bin/bash

set -e

clean_previous() {
  rm -fr ~/.vim
}

create_structure() {
  mkdir ~/.vim
  mkdir ~/.vimswap 2>/dev/null || true
  cd ~/.vim
  mkdir autoload bundle doc plugin syntax
}

get_pathogen() {
  cd ~/.vim/autoload
  wget 'https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim'
}

install_from_git() {
  cd ~/.vim/bundle
  git clone --depth=1 "$2" $1
  rm -fr $1/.git
}

install() {
  install_from_git ctrlp 'https://github.com/kien/ctrlp.vim'
  install_from_git nerdtree 'https://github.com/scrooloose/nerdtree.git'
  install_from_git coffee-script 'https://github.com/kchmck/vim-coffee-script.git'
  install_from_git gitgutter 'https://github.com/airblade/vim-gitgutter.git'
  install_from_git stylus 'https://github.com/wavded/vim-stylus.git'
  install_from_git jade 'https://github.com/digitaltoad/vim-jade.git'
}

main() {
  init_dir="`pwd`"

  clean_previous
  create_structure
  get_pathogen
  install

  cd $init_dir
}

main
