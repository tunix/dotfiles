# ------------------------------------------------------------------------------
#          FILE:  tunix.zsh-theme
#   DESCRIPTION:  oh-my-zsh theme file.
#        AUTHOR:  Alper Kanat (alperkanat@raptiye.org)
#       VERSION:  1.0
#    SCREENSHOT:  http://cl.ly/KjX0
# ------------------------------------------------------------------------------

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo '('`basename $VIRTUAL_ENV`') '
}

MODE_INDICATOR="%{$fg_bold[red]%}❮%{$reset_color%}%{$fg[red]%}❮❮%{$reset_color%}"

local return_status="%{$fg[red]%}%(?..⏎)%{$reset_color%}"
local privilege="%(!.#.$)"

PROMPT='%{$fg[yellow]%}%D{[%H:%M]} %{$fg[red]%}(%{$reset_color%}%n@%m %~%{$fg[red]%})%{$reset_color%}${privilege} '

ZSH_THEME_GIT_PROMPT_PREFIX="[ %{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%} ]"

RPROMPT='%{$fg[green]%}$(virtualenv_info)%{$reset_color%}${return_status} $(git_prompt_info)$(git_prompt_status)%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg[green]%} ✚%{$reset_color%} ]"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg[blue]%} ✹%{$reset_color%} ]"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg[red]%} ✖%{$reset_color%} ]"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg[magenta]%} ➜%{$reset_color%} ]"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg[yellow]%} ═%{$reset_color%} ]"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[cyan]%} ✭%{$reset_color%} ]"
