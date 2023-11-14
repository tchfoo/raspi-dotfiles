{ buildDotnetModule
, fetchFromGitHub
}:

buildDotnetModule rec {
  pname = "moe";
  version = "2023-11-14";

  src = fetchFromGitHub {
    owner = "ymstnt";
    repo = pname;
    rev = "5c01058b5ea3bcac5ce38d3374eae54734199c35";
    hash = "sha256-EOxX98fOaHVvsgtVCVBIUl0kg9mHMIsG0d/RwmcAiA8=";
  };

  # to update deps.nix:
  # $ git clone git@github.com:gepbird/nixpkgs -b moebot-fetch-deps --depth 1
  # update the revision an the hash in nixpkgs/pkgs/tools/moebot/default.nix
  # $ nixpkgs/pkgs/tools/moebot/update.sh
  # copy nixpkgs/pkgs/tools/moebot/deps.nix to this directory
  nugetDeps = ./deps.nix;

  projectFile = [ "moe.csproj" ];

  executables = [ "moe" ];
}
