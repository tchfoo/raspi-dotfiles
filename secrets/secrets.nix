let
  inherit (builtins)
    attrNames
    listToAttrs
    readDir
    removeAttrs
    ;

  keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBFMbDkjW4Bei6BIQRNzoAyed+1klLFjumE6Og6GhMsz ymstnt@raspi-doboz"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICff3KjuI1VI2aIZvrEJQ8L6pXWrWIBI8GtTdd1BBcul ymstnt@raspi5-doboz"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID3olHivyTuztxmwefBJ5EtsaG2Kff7kDGVUacrFMIFQ gep@raspi-doboz"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGp3MDIeetPKbS95IkRhQm/4Q1tRKd8iVKBcNaWR2TIk gep@raspi5-doboz"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK3vrYOUtZIZhwoYihWYUzglxs7w8GGq647OX9vNcPRP root@raspi-doboz"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAl1OF5isvGFJ5HSsDz2iXV8I/lxSjzxOMPkl2IK4FT+ root@raspi5-doboz"
  ];
  secretFiles = attrNames (removeAttrs (readDir (toString ./.)) [ "secrets.nix" "secrets.yaml" ]);
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
