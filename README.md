# NixOS

- for first install, copy secrets.nix.example to secret.nix and fill it out
- rebuild with `./rebuild.sh .#raspi` or with `./rebuild.sh .#vm`
- when making a commit make sure that secret.nix is NOT added, rebuild.sh needs to add it to git

# Installation

```
git clone git@github.com:gutyina70/raspi-doboz-setup     # make sure your github ssh key will be used
cd raspi-doboz-setup
./preinstall.sh
```
## Choose what do you want to install

### Everything

`./install.fish`

### Only some tools, for example ufw

`./install.fish ufw`

### Most of the tools, but excluding some
1. Open install.fish in your preferred text editor
1. Go to the bottom, or search for *CHOOSE YOUR TOOLS BELOW*
1. Uncomment or delete the tools you want to exclude
1. Run `./install.fish`

# Notes
 - This script tries to automate most of the install process, but unfortunately some tools require user interaction
 - Running the same install function won't cause any damage, most of the time it will be skipped if it was installed already
 - Don't run it with sudo, there are user specific configurations
