## Set values
# Hide welcome message
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT "1"
set -x MANPAGER "sh -c 'col -bx | batcat -l man -p'"

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

## Starship prompt
if status --is-interactive
   source (starship init fish --print-full-init | psub)
end

## Functions
# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
  switch (commandline -t)
  case "!"
    commandline -t $history[1]; commandline -f repaint
  case "*"
    commandline -i !
  end
end

function __history_previous_command_arguments
  switch (commandline -t)
  case "!"
    commandline -t ""
    commandline -f history-token-search-backward
  case "*"
    commandline -i '$'
  end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ];
  bind -Minsert ! __history_previous_command
  bind -Minsert '$' __history_previous_command_arguments
else
  bind ! __history_previous_command
  bind '$' __history_previous_command_arguments
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp -r $filename $filename.bak
end

# Copy DIR1 DIR2
function copy
    set count (count $argv | tr -d \n)
    if test "$count" = 2; and test -d "$argv[1]"
	set from (echo $argv[1] | trim-right /)
	set to (echo $argv[2])
        command cp -r $from $to
    else
        command cp $argv
    end
end

## Useful aliases

# Replace grep with ripgrep
alias grep='rg -i --color=auto'

# Replace ls with exa
alias ls='exa --color=always --group-directories-first --icons' # preferred listing
alias la='ls -lag'                                              # all files and dirs
alias lt='ls -aT'                                               # tree listing
alias lf='la | grep'                                            # list and find

# Replace some more things with better alternatives
alias cat='batcat --style rules --style snip --style changes --style header'
[ ! -x /usr/bin/yay ] && [ -x /usr/bin/paru ] && alias yay='paru --bottomup'

# Package manager 
alias pacf='paru -Ss'
function pacff
  paru -Ss $argv[1] | grep $argv[1]
end
function pacfi
  paru -Ss $argv[1] | grep \\[Installed\\]
end
alias apti='sudo apt install -y'
alias aptr='sudo apt remove -y'
alias aptrr='sudo apt autoremove'
alias aptu='sudo apt update && sudo apt upgrade'

# Common use
alias ff='find | grep'
alias hisf='history | grep'
alias rmf='sudo rm -rf'
alias fishreload='source ~/.config/fish/config.fish'
function vim -a file
  bash -c "nvim $file"
end
alias v='vim'

alias wget='wget -c '

function chgep
  sudo chown -R $USER $argv[1]
  sudo chgrp -R $USER $argv[1]
end

function ssh-make-key
  read -P 'Enter email: ' email
  ssh-keygen -t ed25519 -C $email
  bash -c 'eval "$(ssh-agent -s)"'
  ssh-add ~/.ssh/id_ed25519
  set ssh_add_link 'https://github.com/settings/ssh/new'
  xdg-open $ssh_add_link
  echo "Add it to github via $ssh_add_link"
  echo "------------- PUBLIC KEY --------------"
  batcat --style snip ~/.ssh/id_ed25519.pub
  echo "---------- END OF PUBLIC KEY ----------"
end

function java-upgrade
  sudo ln -vsf /bin/java-18 /bin/java
end

function java-downgrade
  sudo ln -vsf /bin/java-8 /bin/java
end

