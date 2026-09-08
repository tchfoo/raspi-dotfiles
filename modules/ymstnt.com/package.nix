{
  fetchFromGitea,
  stdenvNoCC,
  ymstnt-website,
  zola,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ymstnt-website";
  version = builtins.substring 0 8 ymstnt-website.lastModifiedDate or "dirty";

  src = ymstnt-website;

  nativeBuildInputs = [
    zola
  ];

  buildPhase = ''
    runHook preBuild

    cp -r ${finalAttrs.passthru.duckquill}/* themes/duckquill/
    chmod +w -R themes/duckquill

    zola build --output-dir $out

    runHook postBuild
  '';

  passthru = {
    duckquill = fetchFromGitea {
      domain = "codeberg.org";
      owner = "daudix";
      repo = "duckquill";
      tag = "v6.3.0";
      hash = "sha256-eyo4E//A0Akckeux2VDcPLSNFDPwCpqmtY3falrKBkg=";
    };
  };
})
