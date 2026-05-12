{
  pkgs,
  ymstnt-website,
  ...
}:

let
  website = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "ymstnt-website";
    version = builtins.substring 0 8 ymstnt-website.lastModifiedDate or "dirty";

    src = ymstnt-website;

    nativeBuildInputs = with pkgs; [
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
      duckquill = pkgs.fetchFromGitea {
        domain = "codeberg.org";
        owner = "daudix";
        repo = "duckquill";
        tag = "v6.2.0";
        hash = "sha256-IpJ1cmkSGEBycGPc+O/pGbVDWWB0KSla12SPoL1HMbw=";
      };
    };
  });
in
{
  services.nginx.virtualHosts."ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    root = website;
    extraConfig = ''
      error_page 404 /404.html;
    '';
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /var/www/ymstnt.com            0775 shared shared"
  ];
}
