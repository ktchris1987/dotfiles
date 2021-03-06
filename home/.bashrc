export PATH=~/.bin:/usr/local/bin:/usr/local/sbin:${PATH}
export LANG=en_US.utf-8
export LC_ALL=en_US.utf-8

if [ -f ~/.bashrc.local ] ; then
    source ~/.bashrc.local
fi

if hash brew 2>/dev/null
then
    if [ -f `brew --prefix`/etc/bash_completion ]; then
        . `brew --prefix`/etc/bash_completion
    fi

    if [ -f `brew --prefix`/etc/bash_completion.d/git-prompt.sh ]; then
        . `brew --prefix`/etc/bash_completion.d/git-prompt.sh
   fi
else
    for completion in /etc/bash_completion.d/git \
                      /etc/bash_completion.d/git-prompt \
                      /usr/share/bash-completion/completions/git  \
                      /usr/share/git-core/contrib/completion/git-prompt.sh
    do
        if [ -f "$completion" ]
        then
            . "$completion"
        fi
    done
fi

# Funky git prompt
if hash __git_ps1 2>/dev/null
then
    export GIT_PS1_SHOWDIRTYSTATE=1
    export PS1='\h:\[\033[1;34m\]\W\[\033[1;30m\]$(__git_ps1 " (%s)")\[\033[0m\]\$ '
fi

# Make Midnight Command look nice
alias mc='mc --nosubshell --color --skin xoria256'

# Make the airport tool easily accessible
alias airport='/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport'

# Hint Emacs on which Python to use for Pymacs
export PYMACS_PYTHON=`which python`

export GOPATH=~/work/go
export PATH=~/work/go/bin:$PATH

if [ $(uname) == "Darwin" ] && hash go 2>/dev/null
then
    echo Darwin with Go
    launchctl setenv GOPATH $(go env GOPATH)
    launchctl setenv GOROOT $(go env GOROOT)
fi

function init_python_env ()
{
    easy_install ropemacs
    easy_install ropemode
    easy_install pylint
    easy_install elpy
}

source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
