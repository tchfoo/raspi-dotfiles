# NixOS

- for first install
  - copy hardware config: `cp /etc/nixos/hardware-configuration.nix raspi-dotfiles/hardware-configuration-raspi.nix`
  - copy the boot options from `/etc/nixos/configuration.nix` to `raspi-dotfiles/configuration-raspi.nix`, add `grub.enable = false;` if necessary
  - copy secrets.nix.example to secrets.nix and fill it out
- rebuild with `./rebuild.sh .#raspi` or with `./rebuild.sh .#vm`
- when making a commit make sure that secrets.nix is NOT added, rebuild.sh needs to add it to git
- mysql
  - run `mysql_secure_installation`: set root password, remove anonymous users
  - restore existing gepDrive users database: `sudo mysql users < users.sql`
- run `sudo tailscale up`: authenticate Tailscale with tailnet, and share out the host
- moe
  - in secrets.nix: fill out moe.token, moe.owners
  - restore existing database to /var/moe/storage.db
