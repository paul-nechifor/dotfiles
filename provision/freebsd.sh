#!/usr/bin/env bash

set -e

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

install_vim() {
  cd "$provision"
  wget --no-check-certificate https://github.com/b4winckler/vim/archive/master.zip
  unzip master.zip
  cd vim-master
  export LDFLAGS="-static"
  ./configure --with-features=huge --without-x --disable-gui \
      --enable-multibyte --enable-pythoninterp --prefix=$install
  make install
  cd ..
  rm -fr vim-master
}

main() {
  setup
  install_vim
  teardown
}

main
