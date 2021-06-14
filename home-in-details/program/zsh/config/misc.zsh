zstyle ':completions:*' menu select
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

__chpwd_show_dir() {
	if [[ ! $PWD =~ '/nix/store/*' ]];then
		ls
	fi
}

if [[ -v chpwd_functions ]];then
	chpwd_functions+=(__chpwd_show_dir)
else
	chpwd_functions=(__chpwd_show_dir)
fi

get-name() {
	echo ${1:r}
}

get-extesion() {
	echo ${1:e}
}

e() {
	eval "${(P)1} ${@:2}"
}
