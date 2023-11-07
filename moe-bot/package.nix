{ buildDotnetModule
, fetchFromGitHub
}:

buildDotnetModule rec {
  pname = "moe-bot";
  version = "2023-11-05";

  src = fetchFromGitHub {
    owner = "ymstnt";
    repo = pname;
    rev = "3c0f22f0ff1a04cf1ebb2817908f1b496474bbb8";
    hash = "sha256-lnBn8oVYAaBFmplkmtauAu8mOzlphzCNmwO4eSrWBjc=";
  };

  # to update deps.nix:
  # $ git clone git@github.com:gepbird/nixpkgs -b moebot-fetch-deps --depth 1
  # $ nixpkgs/pkgs/tools/moebot/update.sh
  # copy nixpkgs/pkgs/tools/moebot/deps.nix to this directory
  nugetDeps = ./deps.nix;

  projectFile = [ "MoeBot.csproj" ];

  executables = [ "MoeBot" ];
}
