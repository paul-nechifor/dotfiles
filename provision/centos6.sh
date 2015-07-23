#!/usr/bin/env bash

set -e

install_path="$HOME/.ownbin"
tmpdir=$(mktemp -dt provisionXXXXXXXX)

main() {
  [[ -d "$install_path" ]] || mkdir -p "$install_path"
  install_python
  install_vim
  rm -fr "$tmpdir"
}

install_python() {
  local version=2.7.9

  if which python2.7 >/dev/null 2>&1; then
    return
  fi

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
  if vim --version | grep -q 'IMproved 7.4'; then
    return
  fi

  cd "$tmpdir"
  local vim_source="https://github.com/b4winckler/vim/archive/master.zip"
  wgetf "$vim_source" master.zip
  unzip -q master.zip
  cd vim-master
  local vim_options=(
    --disable-gui
    --enable-multibyte
    --enable-pythoninterp
    --with-features=huge
    --with-python-config-dir="$install_path/lib/python2.7/config"
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
