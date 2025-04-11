{
  ...
}:

{
  virtualisation.docker = {
    enable = true;
  };

  users.users = {
    ymstnt.extraGroups = [ "docker" ];
    gep.extraGroups = [ "docker" ];
  };
}
