{
  lib,
  ...
}:

let
  inherit (lib)
    mkOption
    types
    ;
  inherit (types)
    attrsOf
    int
    port
    str
    submodule
    ;
in
{
  options.hosts = mkOption {
    type = attrsOf (submodule {
      options = {
        domain = mkOption {
          type = str;
        };
        jobs = mkOption {
          type = int;
        };
        port = mkOption {
          type = port;
        };
        rootSshKey = mkOption {
          type = str;
        };
      };
    });
  };

  config.hosts = {
    raspi-doboz = {
      domain = "raspi.tchfoo.com";
      jobs = 1;
      port = 42727;
      rootSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK3vrYOUtZIZhwoYihWYUzglxs7w8GGq647OX9vNcPRP root@raspi.tchfoo.com";
    };
    raspi5-doboz = {
      domain = "raspi5.tchfoo.com";
      jobs = 4;
      port = 42728;
      rootSshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl1OF5isvGFJ5HSsDz2iXV8I/lxSjzxOMPkl2IK4FT+ root@raspi5.tchfoo.com";
    };
  };
}
