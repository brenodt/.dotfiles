#!/usr/bin/env bash
#
# EXAMPLE OF cht.sh USAGES
# curl cht.sh/{language}/query+string
# curl cht.sh/{language}/learn:string
# curl cht.sh/{language}/:learnstring
#
# curl cht.sh/{core-util}~{operation}


selected=`cat ~/.dotfiles/.tmux-cht-langs ~/.dotfiles/.tmux-cht-cmds | fzf`
if [[ -z $selected ]]; then
    exit 0
fi

read -p "Enter query: " query

if grep -qs "$selected" ~/.dotfiles/.tmux-cht-langs; then
    query=`echo $query | tr ' ' '+'`
    tmux neww bash -c "echo \"curl cht.sh/$selected/$query/\" & curl cht.sh/$selected/$query & while [ : ]; do sleep 1; done"
else
    tmux neww bash -c "curl cht.sh/$selected~$query | less"
fi
