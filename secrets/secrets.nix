let
  inherit (builtins)
    attrNames
    listToAttrs
    readDir
    removeAttrs
    ;

  ymstnt = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFMbDkjW4Bei6BIQRNzoAyed+1klLFjumE6Og6GhMsz";
  gep = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID3olHivyTuztxmwefBJ5EtsaG2Kff7kDGVUacrFMIFQ";
  raspi-doboz = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK3vrYOUtZIZhwoYihWYUzglxs7w8GGq647OX9vNcPRP";
  raspi5-doboz = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl1OF5isvGFJ5HSsDz2iXV8I/lxSjzxOMPkl2IK4FT+";

  keys = [
    ymstnt
    gep
    raspi-doboz
    raspi5-doboz
  ];
  secretFiles = attrNames (removeAttrs (readDir (toString ./.)) [ "secrets.nix" ]);
  result = listToAttrs (
    map (x: {
      name = x;
      value = {
        publicKeys = keys;
      };
    }) secretFiles
  );
in
result
