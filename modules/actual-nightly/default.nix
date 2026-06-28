{
  nixpkgs.overlays = [
    (final: prev: {
      actual-server = prev.actual-server.overrideAttrs (old: rec {
        src = prev.fetchFromGitHub {
          owner = "actualbudget";
          repo = "actual";
          rev = "33da5a3d26cdaceb64aa01ad3ff1d3f72bb0e8b7";
          hash = "sha256-tQoz50lEU2pjKMeFObJcPEzC5TYlWpOYvziedexLrgs=";
        };
        sourceRoot = "${src.name}/";
        srcs = [
          src
          old.passthru.translations
        ];
        patches = [
          ./actual.patch
        ];
        missingHashes = ./missing-hashes.json;
        offlineCache = prev.yarn-berry.fetchYarnBerryDeps {
          inherit src patches missingHashes;
          hash = "sha256-52xKLFDkdn8xYBLQov5XEuwLJXK2x3tTTzIunGDmLKk=";
        };
      });
    })
  ];
}
