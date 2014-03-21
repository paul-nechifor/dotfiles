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

    su $username -c 'bash scripts/install.sh run-as-user'

    installForRoot
}

function runAsUser() {
    installDotfiles
    installI3
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

function installI3() {
    installFile="/home/$username/.i3/config"
    wantFile="/home/$username/$homeInstall/i3-config"
    replace=true
    if [ -f $installFile ]; then
        read -p "#### Replace $installFile ? (y|n) " replaceI3
        if [ "$replaceI3" = 'y' ]; then
            replace=true
        else
            replace=false
        fi
    fi
    if [ "$replace" = true ]; then
        rm -fr $installFile
        ln -s $wantFile $installFile
    fi
}

main "$@"
