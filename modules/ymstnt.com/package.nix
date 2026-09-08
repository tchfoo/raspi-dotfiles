{
  fetchFromGitea,
  rustPlatform,
  stdenvNoCC,
  ymstnt-website,
  zola,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ymstnt-website";
  version = builtins.substring 0 8 ymstnt-website.lastModifiedDate or "dirty";

  src = ymstnt-website;

  nativeBuildInputs = [
    finalAttrs.passthru.zola_0_22
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
    # 0.23.0 made some breaking changes, duckquill doesn't build
    zola_0_22 = zola.overrideAttrs (
      finalAttrs: old: {
        version = "0.22.1";
        src = old.src.overrideAttrs {
          hash = "sha256-mynoXNJE7IcP/0bMLUr/pJQbaEVEj2q/488Z4c9Tr5A=";
        };
        cargoDeps = rustPlatform.fetchCargoVendor {
          inherit (finalAttrs) pname version src;
          hash = "sha256-AEgyaKenTMKAoJjzcklFFWjy5H5hkNZvVnlMZmqQxlM=";
        };
      }
    );
  };
})
