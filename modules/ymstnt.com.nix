{
  config,
  lib,
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
  services.phpfpm.pools."ymstnt.com" = {
    user = "shared";
    settings = {
      pm = "dynamic";
      "listen.owner" = config.services.nginx.user;
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
    };
    phpEnv."PATH" =
      with pkgs;
      lib.makeBinPath [
        curl
      ];
  };

  services.nginx.virtualHosts."ymstnt.com" = {
    enableACME = true;
    forceSSL = true;
    root = website;
    extraConfig = ''
      error_page 404 /404.html;
    '';
    locations = {
      "~ ^/(auth|explode|gepDrive|geputils|header|libs|global.css)".extraConfig = ''
        return 301 https://gd.tchfoo.com$request_uri;
      '';
      "~ ^/seboard(/.*)?$".extraConfig = ''
        if ($1 = "") {
          set $1 "/";
        }
        return 301 https://sb.tchfoo.com$1;
      '';
    };
  };

  systemd.tmpfiles.rules = [
    # Type Path                           Mode User   Group   Age Argument
    " d    /var/www/ymstnt.com            0775 shared shared"
  ];
}
