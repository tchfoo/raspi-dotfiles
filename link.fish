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

set source $argv[1]
set target $argv[2]

# check if target is symlink
if test -n "$argv[3]"
  if sudo test -L $target
    exit 0
  end
else
  if test -L $target
    exit 0
  end
end

if test -e $target # exists
  if read_confirm "Do you want to delete $target?"
    if test -n "$argv[3]"
      sudo rm -rf $target
    else
      rm -rf $target
    end
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
