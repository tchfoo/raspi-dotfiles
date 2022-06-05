#!/bin/fish

function read_confirm
  while true
    read -l -P "$argv[1] [y/N] " confirm
    switch $confirm
      case Y y
        return 0
      case '' N n
        return 1
    end
  end
end

set SCRIPT_DIR (cd (dirname (status --current-filename)); and pwd)
set source "$SCRIPT_DIR/$argv[1]"
set target $argv[2]

if test -L $target
  exit 0
end

if test -e $target # exists
  if read_confirm "Do you want to delete $target?"
    sudo rm -rf $target
  else
    exit 1
  end
end

if test -n "$argv[3]" # super user
  sudo mkdir -vp (dirname $target)
  sudo ln -vsf $source $target
else 
  mkdir -vp (dirname $target)
  ln -vsf $source $target
end
