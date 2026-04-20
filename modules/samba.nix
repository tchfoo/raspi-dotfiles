{
...
}:

{
  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "raspi5-doboz";
        "netbios name" = "raspi5-doboz";
        "security" = "user";
        "hosts allow" = "192.168.1. 100. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "media" = {
        "path" = "/hdd/media";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      "torrents" = {
        "path" = "/hdd/torrents";
        "browseable" = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      "ymstnt" = {
        "path" = "/home/ymstnt/Files";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "ymstnt";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "ymstnt";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
