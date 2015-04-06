# set the prompt to useful and a bit of colour...
export PS1="[\[\033[32m\[\u@Development \[\033[33m\]\W]\[\033[0m\]\$ "

# Deal with the config file and any other required startup tasks...
scripts/StartupTasks.pl
# source in the environment variables from config if it exists ...
if [  -e /home/extra_env ]; then
	source /home/extra_env
fi

# so gcc etc can find the libraries and headers, some (eg Ruby) have problems finding otherwise ...
export CFLAGS="-I/mingw/include"
export CPATH=/mingw/include
export LIBRARY_PATH=/mingw/lib

# so openssl can be found...
export OPENSSL_PREFIX=/mingw

# set a few useful aliases...
alias ls='ls --color -h'
alias ll='ls -Al'
alias cdh='cd $HOME'
alias clear='cls'
