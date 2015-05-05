# source in the git-completion bash script if exists ...
if [ -e /home/scripts/git-completion.bash ]; then
	source /home/scripts/git-completion.bash
fi
# source in the git-prompt bash script if exists otherwise use std prompt ...
# no longer using this script but leave for future tweaking
if [ -e /home/scripts/git-prompt.sh ]; then
	. /home/scripts/git-prompt.sh
	export PS1="[\[\033[32m\[\u@Development \[\033[33m\]\W$(__git_ps1 " (%s)")]\[\033[0m\]\$ "
else
	export PS1="[\[\033[32m\[\u@Development \[\033[33m\]\W]\[\033[0m\]\$ "
fi

# Deal with the config file and any other required startup tasks...
/home/scripts/StartupTasks.pl
# source in the environment variables from config if it exists ...
if [  -e /home/extra_env ]; then
	source /home/extra_env
fi

# so gcc etc can find the libraries and headers, some (eg Ruby) have problems finding otherwise ...
export CFLAGS="-I/mingw/include"
export CPATH=/mingw/include
export LIBRARY_PATH=/mingw/lib

# set default editor to 'nano', used by git commit
export EDITOR="nano"

# so openssl can be found...
export OPENSSL_PREFIX=/mingw

# set a few useful aliases...
alias ls='ls --color -h'
alias ll='ls -Al'
alias cdh='cd $HOME'
alias clear='cls'
