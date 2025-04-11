# Read all files and folders in the current directory and return an attrset containing the modules
# A utility function to import everything except some specified modules is also included
# Example output:
# {
#   moe = import /nix/store/xxxx-source/modules/moe.nix;
#   miniflux = import /nix/store/xxxx-source/modules/miniflux.nix;
#   allModulesExcept = <LAMBDA [ "transmission" ] -> [ import .../moe ]>;
# }

let
  inherit (builtins)
    attrNames
    removeAttrs
    readDir
    listToAttrs
    replaceStrings
    attrValues
    ;

  modulesDir = toString ./.;

  filesAndDirectories = attrNames (removeAttrs (readDir modulesDir) [ "default.nix" ]);

  allModules = listToAttrs (
    map (name: {
      name = replaceStrings [ ".nix" ] [ "" ] name;
      value = import "${modulesDir}/${name}";
    }) filesAndDirectories
  );

  allModulesExcept = exceptions: attrValues (removeAttrs allModules exceptions);
in
allModules
// {
  inherit allModulesExcept;
}
