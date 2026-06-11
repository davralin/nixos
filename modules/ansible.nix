{ config, pkgs, ... }:

{
  # Define a user account for ansible
  users.users.ansible = {
    isSystemUser = true;
    description = "ansible";
    group = "wheel";
    home = "/tmp";
    shell = "${pkgs.bash}/bin/bash";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJPAMGtseoJt0rtkc2U8PM09W5AlCivFo646ZiUDnd0M" # AWX
    ];
  };
  environment.systemPackages = with pkgs; [
    python3
  ];
}
