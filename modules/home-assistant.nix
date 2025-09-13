{
  ...
}:

{
  # https://wiki.nixos.org/wiki/Home_Assistant#OCI_container
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
      environment.TZ = "Europe/Berlin";
      # Note: The image will not be updated on rebuilds, unless the version label changes
      image = "ghcr.io/home-assistant/home-assistant:stable";
      extraOptions = [
        # Use the host network namespace for all sockets
        "--network=host"
        # Pass devices into the container, so Home Assistant can discover and make use of them
        "--device=/dev/ttyUSB0:/dev/ttyACM0"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [
    8123
  ];
}
