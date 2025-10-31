## Before reinstall

### Dump databases

List databases (press `Ctrl+D` to exit from `mysql`/`psql`):

```sh
sudo mariadb
MariaDB > SHOW DATABASES;

sudo -u postgres psql
postgres=# \l
```

Dump each database, for example to dump `users` MySQL and `miniflux` PostgreSQL database:

```sh
sudo mariadb-dump users > users.sql

sudo -u postgres pg_dump miniflux > miniflux.sql
```

## After a fresh NixOS install

### Enter a nix-shell with some tools

```sh
nix-shell -p <text-edito> git mariadb postgresql
```

### Access to old data

Mount the old drive that contains all the database dumps, ssh keys, webserver data, etc.

```sh
lsblk
sudo mount /dev/sda1 /mnt
```

### Set up databases before starting other services

#### Enable databases

Add this to `/etc/nixos/configuration.nix` then rebuild:

```nix
services.mysql = {
  enable = true;
  package = pkgs.mariadb;
};

services.postgresql = {
  enable = true;
  authentication = ''
    #type database  DBuser  auth-method
    local all       all     trust
  '';
};
```

```sh
sudo nixos-rebuild switch
```

#### MySQL secure installation

```sh
sudo mysql_secure_installation
```

Answer with yes to everything and paste the password.

#### Restore databases

Crete each database:

```sh
sudo mysql
MariaDB > CREATE DATABASE users;

sudo -u postgres psql
CREATE DATABASE miniflux;
```

Restore each database:

```sh
sudo mysql users < users.sql

sudo -u postgres psql -d miniflux < miniflux.sql
```

### Prepare raspi-dotfiles

#### Clone the repo

```sh
git clone https://github.com/ymstnt-com/raspi-dotfiles
cd raspi-dotfiles
```

#### Update hardware configuration

```sh
cp /etc/nixos/hardware-configuration.nix ./hosts/raspi-doboz/hardware-configuration.nix
```

#### Update state version

Check current state version and update it in `./hosts/raspi-doboz/configuration.nix`:

```sh
grep stateVersion /etc/nixos/configuration.nix
```

#### Copy ssh keys

Make sure permissions are preserved with the `-p` flag:

```sh
sudo cp -p /mnt/etc/ssh/host_host* /etc/ssh/
```

#### Rebuild and reboot

> [!WARNING]
> In order to not run out of memory, disable heavy builds first: ignoring the modules `gep` and `ymstnt` in `./hosts/raspi-doboz/configuration.nix` should be enough (or temporarily add more swap)

> [!NOTE]
> Use `boot` rather than `switch` for the first time to avoid issues like getting disconnected from ssh due to enabling `NetworkManager`.

```sh
sudo nixos-rebuild boot --flake .#raspi-doboz
sudo reboot
```

### Set up services and restore their data

#### Tailscale

Run `sudo tailscale up`: authenticate Tailscale with tailnet, and share out the host.

#### Moe

Restore database:

```sh
sudo cp -p /mnt/var/moe/storage.db /var/moe/storage.db
sudo chown moe:shared /var/moe/storage.db
```

#### Borgmatic

To fix borg error 81 _Remote: Host key verification failed._ you need to have a key at `/etc/ssh/borg` and the borgbase repo needs to be in `known_hosts`.

Either copy over the previous keys:

```sh
sudo cp -p /mnt/etc/ssh/borg* /etc/ssh/
sudo chown borgmatic:shared /etc/ssh/borg*
```

or generate new keys and upload them to Borgbase:

```sh
sudo ssh-keygen -t ed_25519 as /etc/ssh/borg
sudo chown borgmatic:shared /etc/ssh/borg*
```

Finally add Borgbase to `known_hosts`:

```sh
sudo -u borgmatic ssh khrfjql1@khrfjql1.repo.borgbase.com
```
