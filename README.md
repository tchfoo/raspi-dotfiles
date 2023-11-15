# NixOS

- for first install, copy secrets.nix.example to secret.nix and fill it out
- rebuild with `./rebuild.sh .#raspi` or with `./rebuild.sh .#vm`
- when making a commit make sure that secret.nix is NOT added, rebuild.sh needs to add it to git
- mysql
  - run `mysql_secure_installation`: set root password, remove anonymous users
  - restore existing gepDrive users database: `sudo mysql users < users.sql`
- run `sudo tailscale up`: authenticate Tailscale with tailnet, and share out the host
- moe
  - in secret.nix: fill out moe.token, moe.owners
  - restore existing database to /var/moe/storage.db
