# # Bash run commands
export is_vagrant=$(id -u vagrant 2>/dev/null && echo 1)
export is_linux=$([[ $OSTYPE == "linux-gnu" ]] && echo 1)
export is_freebsd=$([[ $OSTYPE == "freebsd"* ]] && echo 1)
if [[ $is_linux ]]; then
  export is_ubuntu=$(grep -q Ubuntu /etc/issue && echo 1)
  export is_centos=$(grep -q CentOS /etc/issue && echo 1)
fi
export own_computer=$([[ $is_ubuntu && ! $is_vagrant ]] && echo 1)

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

# Remember an incredible amount of commands.
export HISTSIZE=1000000
export HISTCONTROL=ignoreboth
export HISTFILESIZE=1000000000

# Add a timestamp to every history command.
export HISTTIMEFORMAT="%F %T"

# ## Bash prompt

PS1=
if [[ ! $own_computer ]]; then
  if [[ ! ( $(whoami) =~ (^p$|^pnechifor$|^vagrant$|^root$) ) ]]; then
    if [[ $(id -u) -eq 0 ]]; then
      PS1+='\[\e[0;35m\]\u@\[\e[0m\]'
    else
      PS1+='\[\e[0;34m\]\u@\[\e[0m\]'
    fi
  fi
  if [[ $(id -u) -eq 0 ]]; then
    PS1+='\[\e[1;35m\]\h\[\e[0m\] '
  else
    PS1+='\[\e[1;34m\]\h\[\e[0m\] '
  fi
  if [[ $(id -u) -eq 0 ]]; then
    PS1+='\[\e[0;35m\]\w\[\e[0m\] '
  else
    PS1+='\[\e[0;34m\]\w\[\e[0m\] '
  fi
  PS1+='\n'
fi
if [[ $own_computer ]]; then
  if [[ $(id -u) -eq 0 ]]; then
    PS1+='\[\e[1;31m\]● \[\e[0m\] '
  else
    PS1+='\[\e[1;32m\]● \[\e[0m\] '
  fi
else
  if [[ $(id -u) -eq 0 ]]; then
    PS1+='\[\e[1;35m\]● \[\e[0m\] '
  else
    PS1+='\[\e[1;34m\]● \[\e[0m\] '
  fi
fi

# ## Exports

export LESS_TERMCAP_mb=$(printf "\e[1;37m")
export LESS_TERMCAP_md=$(printf "\e[1;37m")
export LESS_TERMCAP_me=$(printf "\e[0m")
export LESS_TERMCAP_se=$(printf "\e[0m")
export LESS_TERMCAP_so=$(printf "\e[1;47;30m")
export LESS_TERMCAP_ue=$(printf "\e[0m")
export LESS_TERMCAP_us=$(printf "\e[0;36m")

export EDITOR="vim"
export TERM="xterm-256color"

export PATH="$PATH:$HOME/.pn-dotfiles/bin"

if [[ -d $HOME/local/.ownbin ]]; then
  export PATH="$HOME/local/.ownbin/bin:$PATH"
  export LD_LIBRARY_PATH="$HOME/local/.ownbin/lib:$LD_LIBRARY_PATH"
fi

if [[ -d $HOME/.ownbin ]]; then
  export PATH="$HOME/.ownbin/bin:$PATH"
  export LD_LIBRARY_PATH="$HOME/.ownbin/lib:$LD_LIBRARY_PATH"
fi

# ## File system management
if [[ $is_linux ]]; then
  alias ls="ls --color=auto"
  function l() {
    # h = human readable
    # l = list
    # G = no groups
    # tail -> remove 'total XXXk' line
    # shellcheck disable=SC2012
    ls --color=always --group-directories-first -hlG --si "$@" |
    tail --lines=+2
  }
  alias la="l -A"
  if [[ $is_centos ]]; then
    alias tree="tree -Cvh --dirsfirst"
  else
    alias tree="tree -Cvh --du --dirsfirst"
  fi
  alias df="df -ah --si"
  alias du="du -h"
elif [[ $is_freebsd ]]; then
  alias l="ls -lhG"
  alias la="ls -lhaG"
  alias tree="tree -Cvh --dirsfirst"
  alias df="df -ah"
fi

alias du="du -h"

for i in {2..6}; do
  # shellcheck disable=SC2139
  alias "tree$i=tree -L $i"
done

f() {
  find . -iname "*${@}*" 2>/dev/null  |
  egrep -v '\.(git|svn)' |
  awk '{print substr($0,3)}' |
  grep -i "$@"
}

# Go to dir and list the contents.
d() {
  if [ $# -eq 0 ]; then
    cd && l .
  else
    cd "$@" && l .
  fi
}

z() {
  d ~/pro/"$1"
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

if ! which ack >/dev/null 2>&1; then
  alias ack="ack-grep"
fi

if which htop >/dev/null 2>&1; then
  alias top="htop"
fi

# ## Lazy aliases

alias p="pwd"
alias v="vim -p"
alias sudo="sudo -E"

sink() {
  pactl -- set-sink-volume 0 "$1%"
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

# ## Complex aliases

alias dt="du -ba| sort -n | tail -50"

alias less="less -r"

# Reinstall the dotfiles from the repo.
alias infect="wget -q -O- https://github.com/paul-nechifor/dotfiles/raw/master/install.sh | bash -s - infect && . ~/.bashrc"

# Recursively reset all files in the current dir to 644 for normal and 755 for
# dirs.
alias resetmod="find . -type f -exec chmod 644 {} + ; find . -type d -exec chmod 755 {} +"

# ## Git aliases and functions

ga() {
  if [[ $# -eq 0 ]]; then
    git add --all .
  else
    git add --all "$@"
  fi
}

alias g="git"
alias gc="g c"
alias gca="g c --amend"
alias gd="g diff -M"
alias gdd="git-vimdiff"
alias gdc="g diff --cached -M"
alias gad="ga && gdc"
alias gg="gitg"
alias gl="git-pretty-log"
alias gs="g s"

gac() {
  local message="$*"
  git add --all
  git commit -m "$message"
}

# ## SVN aliases and functions

s() {
  case $1 in
    diff)
      svn "$@" | vim +'set bt=nowrite' +'set syntax=diff' - ;;
    log)
      svn "$@" --limit 40 | svn-pretty-log ;;
    st)
      svn info | grep '^URL' | awk '{print "url:", $NF}'
      svn "$@" --ignore-externals 2>&1 | color-svn-status ;;
    add|checkout|co|cp|del|export|remove|rm)
      svn "$@" 2>&1 | color-svn-status ;;
    *)
      svn "$@" ;;
  esac
}

alias sa="s add"
alias sd="s diff"
alias sl="s log"
alias st="s st"
alias sup="s up && sl"

color-svn-status() {
  local color
  while read -r line; do
    if [[ $line =~ ^\ ?M ]]; then color="\033[34m";
    elif [[ $line =~ ^\ ?C ]]; then color="\033[41m\033[37m\033[1m";
    elif [[ $line =~ ^A ]]; then color="\033[32m\033[1m";
    elif [[ $line =~ ^D ]]; then color="\033[31m\033[1m";
    elif [[ $line =~ ^X ]]; then color="\033[30m\033[1m";
    elif [[ $line =~ ^! ]]; then color="\033[43m\033[37m\033[1m";
    elif [[ $line =~ ^I ]]; then color="\033[33m";
    elif [[ $line =~ ^R ]]; then color="\033[35m";
    elif [[ $line =~ ^svn:\ E ]]; then color="\033[31m\033[1m";
    elif [[ $line =~ ^Performing ]]; then color="\033[30m\033[1m";
    else color=""
    fi
    echo -e "$color${line/\\/\\\\}\033[0m\033[0;0m"
  done
}

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

# Load local bashrc

if [ -f ~/.bashrc-local ]; then
  source ~/.bashrc-local
fi
