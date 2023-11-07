#!/run/current-system/sw/bin/bash

# When building from a flake only files that are staged are copied to the nix store
# Due to this limitation we can't put the secret.nix in .gitignore as the build would fail
# As a workaround: stage this file, rebuild the system then unstage the file
# Warning: custom local git exclude file will be overwritten
echo "" > .git/info/exclude
git add secret.nix >/dev/null
sudo nixos-rebuild switch --flake $1
git reset HEAD secret.nix >/dev/null
echo "secret.nix" > .git/info/exclude
