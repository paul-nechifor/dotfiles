#!/bin/bash

# # Bash run commands

export is_vagrant; is_vagrant=$([[ -e /vagrant ]] && echo 1)

# ## System detection
#
# This exports some boolean variables that are later used to customise behaviour
# based on the detected OS and distribution.
export is_linux; is_linux=$([[ $OSTYPE == "linux-gnu" ]] && echo 1)
export is_freebsd; is_freebsd=$([[ $OSTYPE == "freebsd"* ]] && echo 1)
if [[ $is_linux ]]; then
  export is_ubuntu; is_ubuntu=$(grep -q Ubuntu /etc/issue && echo 1)
  export is_centos; is_centos=$(grep -q CentOS /etc/issue && echo 1)
fi
export own_computer; own_computer=$([[ $is_ubuntu && ! $is_vagrant ]] && echo 1)

# ## Bash settings

# Set vi mode.
set -o vi

# Use arrow keys for searching in the history.
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

# Don't match hidden files when tab-completing file names.
bind 'set match-hidden-files off'

# Append to `~/.bash_history`.
shopt -s histappend

# Enable using '**' like in 'ack word **/*.py'.
shopt -s globstar 2>/dev/null

# Remember an incredible amount of commands in the history.
export HISTSIZE=1000000
export HISTCONTROL=ignoreboth
export HISTFILESIZE=1000000000

# Add a timestamp to every history command.
export HISTTIMEFORMAT="%F %T"

# ## Bash prompt

PS1=
ucolor=$(if [[ $(id -u) -eq 0 ]]; then echo 31; else echo 32; fi)
# Only include my username if it's not one I expect.
if [[ ! ( $(whoami) =~ (^p$|^pnechifor$|^vagrant$|^root$) ) ]]; then
  PS1+='\[\e[0;'"$ucolor"'m\]\u@\[\e[0m\]'
fi
# Only include the host I'm not directly on my computer.
if [[ ! $own_computer ]]; then
  PS1+='\[\e[1;'"$ucolor"'m\]\h\[\e[0;30m\]:\[\e[0m\]'
fi
PS1+='\[\e[0;'"$ucolor"'m\]$(get_home_relative_path)\[\e[0m\] \n'
PS1+='\[\e[1;'"$ucolor"'m\]● \[\e[0m\] '
unset ucolor

# ## Environment variables

export LESS_TERMCAP_mb; LESS_TERMCAP_mb=$(printf "\e[1;37m")
export LESS_TERMCAP_md; LESS_TERMCAP_md=$(printf "\e[1;37m")
export LESS_TERMCAP_me; LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se; LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so; LESS_TERMCAP_so=$(printf "\e[1;47;30m")
export LESS_TERMCAP_ue; LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us; LESS_TERMCAP_us=$(printf "\e[0;36m")

man() {
  env \
  LESS_TERMCAP_mb="$(printf "\e[1;31m")" \
  LESS_TERMCAP_md="$(printf "\e[1;31m")" \
  LESS_TERMCAP_me="$(printf "\e[0m")" \
  LESS_TERMCAP_se="$(printf "\e[0m")" \
  LESS_TERMCAP_so="$(printf "\e[1;44;33m")" \
  LESS_TERMCAP_ue="$(printf "\e[0m")" \
  LESS_TERMCAP_us="$(printf "\e[1;32m")" \
  man "$@"
}

if [[ ! $is_freebsd ]]; then
  # Load the colors to be used in `ls`.
  eval "$(dircolors ~/.dircolors)"
fi

export EDITOR="vim"

if [[ $is_freebsd ]]; then
  export TERM="xterm-256color"
else
  export TERM="screen-256color"
fi

export PATH="$HOME/.pn-dotfiles/bin:$PATH:$HOME/.local/bin"

if [[ -d $HOME/local/.ownbin ]]; then
  export PATH="$HOME/local/.ownbin/bin:$PATH"
  export LD_LIBRARY_PATH="$HOME/local/.ownbin/lib:$LD_LIBRARY_PATH"
fi

if [[ -d $HOME/.ownbin ]]; then
  export PATH="$HOME/.ownbin/bin:$PATH"
  export LD_LIBRARY_PATH="$HOME/.ownbin/lib:$LD_LIBRARY_PATH"
fi

export LIBRARY_PATH="$LD_LIBRARY_PATH"

export PYTHONSTARTUP="$HOME/.pythonrc"

# ## File system management
if [[ $is_linux ]]; then
  alias ls="ls --color=auto"
  alias la="l -A"
  if [[ $is_centos ]]; then
    alias tree="tree -Cvh --dirsfirst"
  else
    alias tree="tree -Cvh --du --dirsfirst"
  fi
  alias df="df -ah --si"
  alias du="du -h"
elif [[ $is_freebsd ]]; then
  alias la="ls -lhaG"
  alias tree="tree -Cvh --dirsfirst"
  alias df="df -ah"
fi

alias du="du -h"

# Define lazy level commands for `tree`: `tree1`, `tree2`, ...
for i in {1..6}; do
  # shellcheck disable=SC2139
  alias "tree$i=tree -L $i"
done

# Go to a directory and delete all pyc files in there.
change_dir() {
  cd "$@" && (rm ./*.pyc &>/dev/null || true) && l
}

o() {
  if [[ $# -eq 0 || -d "$1" ]]; then
    change_dir "$@"
  else
    command vim -p "$@"
  fi
}

z() {
  local file="$HOME/pro/$1"
  if [[ -f $file && -x $file ]]; then
      "$file"
  else
      d "$file"
  fi
}

_z() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  # shellcheck disable=SC2010
  COMPREPLY=( $(compgen -W "$(ls ~/pro | grep "^$cur")" ) )
}

complete -F _z -o dirnames z

# Create and go to a directory (possibly nested).
dc() {
  mkdir -p "$@"
  cd "$@"
}

# Create aliases for going up, i.e. '..'='cd ..', '...'='cd ../..', &c.
for i in {1..9}; do
  # shellcheck disable=SC2139,SC2030,SC2031
  alias "..$(for ((j=1; j < i; j += 1)); do echo -n .; done)=d ..$(
    for ((j=1; j < i; j += 1)); do
      echo -n '/..'
    done
  )"
done

a() {
  separator —

  if which ag &>/dev/null; then
    ag --color "$@" | cut -c1-400
  else
    ack --color "$@" | cut -c1-400
  fi
}

# Replace `top` with `htop` if it exits.
if which htop &>/dev/null; then
  alias top="htop"
fi

get_home_relative_path() {
  local wd; wd="$(readlink -f "$(pwd)")"
  local home; home="$(readlink -f "$(eval echo ~"$(whoami)")")"
  sed "s#^$home/##" <<<"$wd"
}

if [[ $is_freebsd ]]; then
  get_home_relative_path() {
    pwd
  }
fi

p() {
    echo -n "$(whoami) $(hostname)$(tput setaf 0):$(tput setaf 12)"
    echo "$(get_home_relative_path)$(tput sgr0)"
}

rm() {
  command rm "$@"
  # If everything that's deleted is from the current dir then list the dir so I
  # can know what's left.
  if ! echo "$@" | grep / &>/dev/null; then
    separator —
    l
  fi
}

alias python="ipython --no-banner --no-confirm-exit"
alias vim="vim -p"
alias sudo="sudo -E"
alias gdb="gdb -q"

sink() {
  pactl -- set-sink-volume 40 "$1%"
}

if [[ $own_computer ]]; then
  alias am="alsamixer"
  alias b="thunar . >/dev/null 2>&1 &"
  alias t="gnome-terminal >/dev/null 2>&1 &"
fi

if [[ $is_linux ]]; then
  alias egrep="egrep --color=auto"
  alias grep="grep --color=auto"
fi

alias dt="du -ba| sort -n | tail -50"

alias less="less -FiSsr"

# Reinstall the dotfiles from the repo.
alias infect="wget -q -O- https://github.com/paul-nechifor/dotfiles/raw/master/install.sh | bash -s - infect && . ~/.bashrc"

# Recursively reset all files in the current dir to 644 for normal and 755 for
# dirs.
alias resetmod="find . -type f -exec chmod 644 {} + ; find . -type d -exec chmod 755 {} +"

alias c=cmus

# ## Fun things
3men() {
  festival --tts <<EOF
And we sit there, by its margin while the moon, who loves it too, stoops down to
kiss it with a sister's kiss, and throws her silver arms around it clingingly;
and we watch it as it flows, ever singing, ever whispering, out to meet its
king, the sea -- till our voices die away in silence, and the pipes go out --
till we, commonplace, everyday young men, feel strangely full of thoughts, half
sad, half sweet, and do not care or want to speak -- till we laugh, and rising,
knock the ashes from our burnt-out pipes, and say "Good night" and, lulled by
the lapping water and the rustling trees, we fall asleep beneath the great,
still stars, and dream that the world is young again -- young and sweet as she
used to be ere the centuries of fret and care had made old her loving heart --
sweet as she was in those bygone days when a new-made mother, she nursed us, her
children, upon her own deep breast -- ere the wiles of painted civilization had
lured us away from her fond arms, and the poisoned sneers of artificiality had
made us ashamed of the simple life we led with her, and the simple, stately home
where mankind was born so many thousands of years ago.
EOF
}

# ## Local bashrc

if [[ -f ~/.bashrc-local ]]; then
  . ~/.bashrc-local
fi
