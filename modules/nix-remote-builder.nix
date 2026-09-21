{
  config,
  lib,
  ...
}:

let
  user = "nix-remote-builder";
in
{
  users = {
    groups.${user} = { };
    users.${user} = {
      isNormalUser = true;
      group = user;
      home = "/var/cache/${user}";
      openssh.authorizedKeys.keys = lib.mapAttrsToList (hostname: host: host.rootSshKey) config.hosts;
    };
  };

  programs.ssh = {
    extraConfig = lib.concatMapAttrsStringSep "\n" (hostname: host: ''
      Host ${host.domain}
        Port ${toString host.port}
    '') config.hosts;

    knownHosts = lib.mapAttrs (hostname: host: {
      hostNames = [ "[${host.domain}]:${toString host.port}" ];
      publicKey = host.rootSshKey;
    }) config.hosts;
  };


  nix = {
    distributedBuilds = true;
    settings = {
      builders-use-substitutes = true;
      trusted-users = [
        user
      ];
    };
  };

  lix.buildMachines.machines = lib.mapAttrs (hostname: host: {
    jobs = host.jobs;
    system-types = [ "aarch64-linux" ];
    uri = "ssh-ng://${user}@${host.domain}";
  }) (builtins.removeAttrs config.hosts [ config.networking.hostName ]);
}
