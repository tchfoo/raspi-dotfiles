{
  config,
  ...
}:

let
  perHost = {
    # swaps to a slow hdd: compress as much as possible, keep the page cache over anonymous memory
    raspi-doboz = {
      memoryPercent = 100;
      swappiness = 150;
      swapfileSize = 4 * 1024;
    };
    # a zram page is still held in memory, keep it small so a big build can be swapped out to the nvme
    raspi5-doboz = {
      memoryPercent = 20;
      swappiness = 30;
      swapfileSize = 12 * 1024;
    };
  };
  cfg = perHost.${config.networking.hostName};
in
{
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = cfg.memoryPercent;
  };

  boot.kernel.sysctl = {
    "vm.swappiness" = cfg.swappiness;
    "vm.page-cluster" = 0;
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = cfg.swapfileSize;
    }
  ];
}
