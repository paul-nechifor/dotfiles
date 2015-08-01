#!/usr/bin/env bash

set -e

install_path="$HOME/.ownbin"
tmpdir=$(mktemp -dt provisionXXXXXXXX)

main() {
  # You have to `export root_req=1` before running the script in order to
  # install the root packages required if they are not present.
  [[ $root_req ]] && install_root_requirements

  if ! which gcc > /dev/null 2>&1; then
    echo "$(tput setaf 1)No GCC found.$(tput sgr0)"
    return
  fi

  [[ -d "$install_path" ]] || mkdir -p "$install_path"
  install_python || soft_fail 'Failed to install Python.'
  install_vim || soft_fail 'Failed to install Vim'
  install_tmux || soft_fail 'Failed to install Tmux'
  rm -fr "$tmpdir"
}

install_root_requirements() {
  local packages=(
    ack
    bzip2-devel
    compat-readline5
    docker-io
    glib2-devel
    glibc-static
    gnutls-devel
    htop
    libuv
    libuv-devel
    libxslt
    libxslt-devel
    lsof
    mysql
    mysql-devel
    mysql-server
    ncurses
    ncurses-devel
    nodejs
    npm
    openldap-clients
    openldap-devel
    openssl-devel
    readline-devel
    realpath
    redis
    sqlite-devel
    tmux
    tree
    vim-common
    vim-enhanced
    xmlsec1
    xmlsec1-devel
    xz-devel
    zlib-devel
  )

  cd /tmp
  local file="epel-release-6-8.noarch.rpm"
  wget -q "http://dl.fedoraproject.org/pub/epel/6/x86_64/$file"
  rpm -Uvh "$file" >/dev/null 2>&1 || true
  rm "$file"

  sudo yum -y install centos-release-SCL
  sudo yum -y shell <<<"
    update
    groupinstall 'Development tools'
    install ${packages[@]}
    run
  "
}

install_python() {
  local version=2.7.9

  [[ -e "$install_path/bin/python2.7" ]] && return

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
  [[ -e "$install_path/bin/vim" ]] && return

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

install_tmux() {
  [[ -e "$install_path/bin/tmux" ]] && return

  cd "$tmpdir"
  local libevent="libevent-2.0.21-stable"
  wgetf "https://github.com/downloads/libevent/libevent/${libevent}.tar.gz" libevent.tar.gz
  tar -xzf libevent.tar.gz
  cd "$libevent"
  ./configure --prefix="$install_path"
  make && make install

  cd "$tmpdir"
  wgetf https://github.com/tmux/tmux/releases/download/1.8/tmux-1.8.tar.gz tmux.tar.gz
  tar -xzf tmux.tar.gz
  cd tmux-1.8
  ./configure CFLAGS="-I$install_path/include" LDFLAGS="-L$install_path/lib" --prefix="$install_path"

  make && make install
}

wgetf() {
  wget -q --no-check-certificate "$1" -O- > "$2"
}

soft_fail() {
  echo "$(tput setaf 1)$1$(tput sgr0)"
}

main
