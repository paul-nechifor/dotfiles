#!/usr/bin/env bash

set -e

lock_file="$HOME/local/.freebsd-provisioned"
install_path="$HOME/local/.ownbin"
tmpdir=$(mktemp -dt provision)

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
}

teardown() {
  rm -fr "$tmpdir"
  touch "$lock_file"
}

install_all() {
  rm -fr "$install_path"
  mkdir -p "$install_path" 2>/dev/null || true
  install_python
  install_vim
}

install_python() {
  local version=2.7.9

  cd "$tmpdir"
  wgetf https://www.python.org/ftp/python/$version/Python-${version}.tgz Python.tgz
  tar -xzf Python.tgz
  cd Python-$version
  ./configure --prefix="$install_path"
  make && make altinstall

  wgetf https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py ez_setup.py
  "$install_path/bin/python2.7" ez_setup.py
  "$install_path/bin/easy_install-2.7" pip
  "$install_path/bin/pip2.7" install virtualenv
}

install_vim() {
  cd "$tmpdir"
  local vim_source="https://github.com/b4winckler/vim/archive/master.zip"
  wgetf "$vim_source" master.zip
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

wgetf() {
  wget -q --no-check-certificate "$1" -O- > "$2"
}

main
