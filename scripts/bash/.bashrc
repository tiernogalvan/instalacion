#  _   _                                   _                  
# | |_(_) ___ _ __ _ __   ___   __ _  __ _| |_   ____ _ _ __  
# | __| |/ _ \ '__| '_ \ / _ \ / _` |/ _` | \ \ / / _` | '_ \ 
# | |_| |  __/ |  | | | | (_) | (_| | (_| | |\ V / (_| | | | |
#  \__|_|\___|_|  |_| |_|\___/ \__, |\__,_|_| \_/ \__,_|_| |_|
#                              |___/                          
#
#  IES Enrique Tierno Galván
#

umask 077

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

export HISTFILESIZE=20000
export HISTSIZE=10000
# Ignore duplicates, ls without options and builtin commands
export HISTIGNORE="&:ls:[bf]g:exit"
# Causes bash to append to history instead of overwriting it so if you start a new terminal, you have old session history
PROMPT_COMMAND='history -a'
# Allow ctrl-S for history navigation (with ctrl-R)
# stty -ixon
# Don't put duplicate lines in the history
HISTCONTROL=ignorespace:ignoredups:erasedups
HISTFILESIZE=99999
HISTSIZE=99999
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
shopt -s checkwinsize   # Check window size after each command
shopt -s histappend     # append to the history file, don't overwrite it
shopt -s cmdhist        # Combine multiline commands into one in history
shopt -s histreedit
shopt -s histverify
shopt -s lithist

# Ignore case on auto-completion
bind "set completion-ignore-case on"
# Show auto-completion list automatically, without double tab
bind "set show-all-if-ambiguous On"
# Disable the bell
bind "set bell-style visible"

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

export LS_OPTIONS='--color=auto'
alias la='ls -Alh' # show hidden files
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

export GREP_OPTIONS=' --color=auto'
export EDITOR=nano

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alF'
alias la='ls -Al'
alias l='ls -CFl'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

