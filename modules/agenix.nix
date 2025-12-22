{
  lib,
  pkgs,
  agenix,
  ...
}:

let
  inherit (builtins)
    attrNames
    listToAttrs
    readDir
    removeAttrs
    ;

  inherit (lib)
    replaceString
    ;

  secretsFolder = toString ../secrets;
  secretFileNames = attrNames (removeAttrs (readDir secretsFolder) [ "secrets.nix" "secrets.yaml" ]);

  secrets = listToAttrs (
    map (fileName: {
      name = replaceString ".age" "" fileName;
      value = {
        file = secretsFolder + "/" + fileName;
      };
    }) secretFileNames
  );

in
{
  imports = [ agenix.nixosModules.default ];

  nixpkgs.overlays = [ agenix.overlays.default ];

  environment.systemPackages = [ pkgs.agenix ];

  age.secrets = secrets;
}
