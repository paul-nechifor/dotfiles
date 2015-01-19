#!/usr/bin/env bash

set -e

tmux=tmux-1.8
ncurses=ncurses-5.9
libevent=libevent-2.0.19-stable

install=$HOME/.local-installs
provision=$HOME/provision-tmp

setup() {
  if [[ -f ~/.freebsd-provisioned ]]; then
    echo 'Remove ~/.freebsd-provisioned to reprovision.'
    exit
  fi

  rm -fr "$install" "$provision"
  mkdir -p "$install" "$provision" 2>/dev/null || true
}

teardown() {
  rm -fr "$provision"
  touch ~/.freebsd-provisioned
}

install_tmux() {
  cd "$provision"

  wget -O ${tmux}.tar.gz http://sourceforge.net/projects/tmux/files/tmux/${tmux}/${tmux}.tar.gz/download
  wget -O ${libevent}.tar.gz http://sourceforge.net/projects/levent/files/libevent/libevent-2.0/${libevent}.tar.gz/download
  wget http://ftp.gnu.org/gnu/ncurses/${ncurses}.tar.gz

  tar xvzf ${libevent}.tar.gz
  cd $libevent
  ./configure --prefix=$install --disable-shared
  make && make install
  cd ..

  tar xvzf ${ncurses}.tar.gz
  cd $ncurses
  ./configure --prefix=$install
  make && make install
  cd ..

  tar xvzf ${tmux}.tar.gz
  cd $tmux
  ./configure CFLAGS="-I$install/include -I$install/include/ncurses" LDFLAGS="-L$install/lib -L$install/include/ncurses -L$install/include" CPPFLAGS="-I$install/include -I$install/include/ncurses" LDFLAGS="-static -L$install/include -L$install/include/ncurses -L$install/lib"
  make
  cp tmux $install/bin
}

install_vim() {
  cd "$provision"
  wget --no-check-certificate https://github.com/b4winckler/vim/archive/master.zip
  unzip master.zip
  cd vim-master
  ./configure --with-features=huge --enable-multibyte --enable-pythoninterp --prefix=$install
  make install
  cd ..
  rm -fr vim-master
}

main() {
  setup
  install_vim
  install_tmux
  teardown
}

main
