#!/bin/bash

username="p"
homeInstall="pro/dotfiles-installed"
installSource="`pwd`"

function main() {
    if [ "$@" == "run-as-user" ]; then
        runAsUser
    else
        runAsRoot
    fi
    
}

function runAsRoot() {
    if [ "`id -u`" != "0" ]; then
        echo "You are not root."
        exit 1
    fi

    createUser

    su $username -c 'bash install.sh run-as-user'

    installForRoot
}

function runAsUser() {
    installDotfiles
}

function createUser() {
    id -u $username >/dev/null
    if [ $? -eq 0 ]; then
        echo "#### User $username exists."
        return
    fi
    echo "#### Running 'useradd' to create the user."
    adduser $username --home /home/$username
}

function installDotfiles() {
    cd ~
    mkdir -p "$homeInstall" 2>/dev/null
    echo "#### Installing the dotfiles."
    rsync -a --del "$installSource/" "$homeInstall/"
}

function installForRoot() {
    cd /root
}

main "$@"
