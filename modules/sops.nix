{
  config,
  sops-nix,
  ...
}:

{
  imports = [
    sops-nix.nixosModules.sops
  ];
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    secrets = {
      hello = { };
    };
  };

  system.activationScripts."sops-test" = ''
    echo hello secret is $(cat ${config.sops.secrets.hello.path}) 1>&2
  '';
}
