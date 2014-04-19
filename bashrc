# Bash settings ----------------------------------------------------------------

# Bash search
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

# Append to `~/.bash_history`.
shopt -s histappend

# Bash history controls.
export HISTSIZE=1000000
export HISTCONTROL=ignoreboth
export HISTFILESIZE=1000000000
export HISTTIMEFORMAT="%F %T"

# Bash prompt ------------------------------------------------------------------
if [ `id -u` -eq 0 ]; then
    PS1='`if [ $? -ne 0 ]; then echo \e[31mಠ_ಠ; echo \e[33m; else echo \e[33m; fi`\[\e[1;31m\]● \[\e[0m\] '
else
    PS1='`if [ $? -ne 0 ]; then echo \e[31mಠ_ಠ; echo \e[33m; else echo \e[33m; fi`\[\e[1;32m\]● \[\e[0m\] '
fi

# Exports ----------------------------------------------------------------------

export LESS_TERMCAP_mb=$(printf "\e[1;37m")
export LESS_TERMCAP_md=$(printf "\e[1;37m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;47;30m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[0;36m")

# Java 6
#export JAVA_HOME="/usr/lib/jvm/java-6-openjdk"
# Java 7
export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64"

export TERM='xterm-256color'

# Lazy aliases -----------------------------------------------------------------

alias ..="cd .."
alias df="df -ah --si"
alias du="du -h"
alias ls="ls --color=auto -h"
alias l="ls -l"
alias la="ls -lA"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias v="vim"
alias am="alsamixer"
alias brow="nautilus --no-desktop . &"

# Complex aliases --------------------------------------------------------------

alias dt="du -ba| sort -n | tail -50"
alias xp="echo -n 'NAME, CLASS = '; xprop | grep 'WM_CLASS' | cut -c20-"

# Recursively reset all files in the current dir to 644 for normal and 755 for
# dirs.
alias resetmod="find . -type f -exec chmod 644 {} + ; find . -type d -exec chmod 755 {} +"

# Script aliases ---------------------------------------------------------------

alias light="bash ~/pro/dotfiles-installed/scripts/gnome-terminal-theme.sh solarized-ish-light"
alias dark="bash ~/pro/dotfiles-installed/scripts/gnome-terminal-theme.sh solarized-ish-dark"

# Functions --------------------------------------------------------------------

# Go to dir and list the contents.
function d() {
    cd "$1" && l
}

# Create and go to a directory (possibly nested).
function dc() {
    dir="$@"
    mkdir -p "$dir"
    cd "$dir"
}

function die() {
    kill $1 || (sleep 3; kill -15 $1) || (sleep 3; kill -2 $1) || (sleep 3; kill -1 $1) || (sleep 5; kill -9 $1)
}

function dirdiff() {
    # -Ewb ignore the bulk of whitespace changes
    # -N detect new files
    # -u unified
    # -r recurse
    diff -ENwbur "$1" "$2"  | kompare -o -
}

# Git aliases and functions ----------------------------------------------------

alias g="git"
alias gg="gitg"

function gac() {
    message="$@"
    git add --all
    git commit -m "$message"
}
