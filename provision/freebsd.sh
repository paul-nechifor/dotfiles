#!/usr/bin/env bash

set -e

lock_file="$HOME/local/.freebsd-provisioned"
install_path="$HOME/local/.ownbin"
provision=$(mktemp -dt provision)

main() {
  setup

  if [[ -f $lock_file && ! $force_provisioning ]]; then
    echo "Remove '$lock_file' to reprovision or set 'force_provisioning'."
  else
    install_all
  fi

  teardown
}

setup() {
  local mkhome="/usr/local/mintel/shared/utils/mk_local_home"
  if [[ ! -e "$HOME/local" ]]; then
    if [[ -e $mkhome ]]; then
      sudo "$mkhome"
    else
      mkdir -p "$HOME/local"
    fi
  fi

  rm -fr "$install_path"
  mkdir -p "$install_path" 2>/dev/null || true
}

teardown() {
  rm -fr "$provision"
  touch "$lock_file"
}

install_all() {
  install_vim
}

install_vim() {
  cd "$provision"
  local vim_source="https://github.com/b4winckler/vim/archive/master.zip"
  wget -q --no-check-certificate "$vim_source" -O- > master.zip
  unzip master.zip
  cd vim-master
  export LDFLAGS="-static"
  local vim_options=(
    --disable-gui
    --enable-multibyte
    --enable-pythoninterp
    --with-features=huge
    --without-x
  )
  ./configure "${vim_options[@]}" --prefix="$install_path"
  make install
  cd ..
  rm -fr vim-master
}

main
