local ret_status="%(?:%{$fg_bold[green]%}%Bλ%b:%{$fg_bold[red]%}%Bλ%b)"
local dot="%(?:%{$fg_bold[green]%}%B.%b:%{$fg_bold[red]%}%B.%b)"

function lam_theme_working_loc(){
  local direc=`print -P %~`
  if [[ "$direc" == "/" ]];then
      direc="%{$fg[cyan]%}%Bρ%b%{$reset_color%}"
  elif [[ "$direc" =~ "^/.*" ]];then
      direc=${direc/\//%{$fg[cyan]%}%Bρ%b %{$fg[cyan]%}}
      direc="${direc//\// }%{$reset_color%}"
  else
      direc=${direc/\~/%{$fg[cyan]%}%Bµ%b%{$fg[cyan]%}}
      direc="${direc//\// }%{$reset_color%}"
  fi
  echo "$direc"
}

function lam_theme_nix_env(){
	if [[ -v "NIXIFY_NAME" ]];then
		echo "%{$fg_bold[yellow]%}%B(${NIXIFY_NAME})%b "
	elif [[ -v "NIX_CHROOTENV" ]];then
		echo "%{$fg_bold[yellow]%}%B(nix)%b "
	fi
}

PROMPT='${ret_status} $(lam_theme_working_loc) ${dot} $(git_prompt_info)$(lam_theme_nix_env)'

precmd() {
    echo ''
}

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(git %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%} %{$fg[yellow]%}✗%{$fg_bold[blue]%})"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
