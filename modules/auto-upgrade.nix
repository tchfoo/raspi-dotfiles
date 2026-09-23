{
  config,
  ...
}:

{
  system.autoUpgrade = {
    enable = true;
    flake = "git+https://git.tchfoo.com/tchfoo/raspi-dotfiles#${config.networking.hostName}";
    flags = [
      "--accept-flake-config"
      "--keep-going"
      "--max-jobs"
      "0"
    ];
    dates = "13:00";
    allowReboot = true;
    upgrade = false;
  };
}
