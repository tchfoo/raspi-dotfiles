{
  config,
  ...
}:

let
  perHost = {
    raspi-doboz = {
      swapfileSize = 6 * 1024;
    };
    raspi5-doboz = {
      swapfileSize = 8 * 1024;
    };
  };
  cfg = perHost.${config.networking.hostName};
in
{
  boot.zswap.enable = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = cfg.swapfileSize;
    }
  ];
}
