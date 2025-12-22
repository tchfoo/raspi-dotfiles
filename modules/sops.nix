{
  lib,
  pkgs,
  sops-nix,
  ...
}:

let
  inherit (builtins)
    concatStringsSep
    fromJSON
    listToAttrs
    readFile
    ;
  inherit (lib)
    filterAttrs
    mapAttrsToListRecursive
    nameValuePair
    ;

  # register all secrets from the yaml file to be available from config.sops.secrets
  secretsYaml = fromJSON (
    readFile (
      pkgs.runCommand "secrets.yaml.json" { }
        ''${pkgs.yj}/bin/yj < "${../secrets/secrets.yaml}" > "$out"''
    )
  );
  secretsOnlyYaml = filterAttrs (name: value: name != "sops") secretsYaml;
  secretNames = mapAttrsToListRecursive (name: value: name) secretsOnlyYaml;
  secretNamesFlattened = map (concatStringsSep "/") secretNames;
  secrets = listToAttrs (map (secretName: (nameValuePair secretName { })) secretNamesFlattened);
in
{
  imports = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    inherit secrets;
  };

  environment.systemPackages = [ pkgs.sops ];
}
