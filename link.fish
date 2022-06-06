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

if test -n "$argv[3]" # if super user
  if test -e $target && ! sudo test -L $target # if exists and not symlink
    if read_confirm "Do you want to delete $target?"
      sudo rm -rf $target
    else
      exit 0
    end
  end
  sudo mkdir -vp (dirname $target)
  sudo ln -vsf $source $target
else
  if test -e $target && ! test -L $target # if exists and not symlink
    if read_confirm "Do you want to delete $target?"
      rm -rf $target
    else
      exit 0
    end
  end
  mkdir -vp (dirname $target)
  ln -vsf $source $target
end
