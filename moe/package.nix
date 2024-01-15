{ buildDotnetModule
, fetchFromGitHub
, lib
}:

# to update deps.nix:
# checkout out github:gepbird/nixpkgs/moebot-fetch-deps
# update version number, rev and hash
# $ pkgs/tools/moebot/update.sh
# copy pkgs/tools/moebot/deps.nix to this directory
buildDotnetModule rec {
  pname = "moe";
  version = "2024-01-15";

  src = fetchFromGitHub {
    owner = "ymstnt";
    repo = pname;
    rev = "dcb687b7058626ddbc17f13eff7c95f7fe4b1404";
    hash = "sha256-Zja4V2SOnuYa3g1xGjj63P5EsHvs61rZ5UvOouRgAZg=";
  };

  nugetDeps = ./deps.nix;

  projectFile = [ "moe.csproj" ];

  executables = [ "moe" ];

  meta = with lib; {
    description = "A multi-purpose Discord bot made using Discord.Net";
    homepage = "https://github.com/ymstnt/moe/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ gepbird ];
    platforms = platforms.all;
    mainProgram = "moe";
  };
}
