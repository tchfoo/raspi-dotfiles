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
    port
    submodule
    ;
in
{
  options.hosts = mkOption {
    type = attrsOf (submodule {
      options = {
        port = mkOption {
          type = port;
        };
      };
    });
  };

  config.hosts = {
    raspi-doboz = {
      port = 42727;
    };
    raspi5-doboz = {
      port = 42728;
    };
  };
}
