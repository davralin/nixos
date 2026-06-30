{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/secrets/mierin.nix
      ../../modules/secrets/nullmailer.nix
      ../../modules/acme.nix
      ../../modules/ansible.nix
      ../../modules/auto-update.nix
      ../../modules/common.nix
      ../../modules/garbage-collect.nix
      ../../modules/impermanence-root.nix
      ../../modules/libvirtd.nix
      ../../modules/locale.nix
      ../../modules/mikr.nix
      ../../modules/node-exporter.nix
      ../../modules/physical.nix
      ../../modules/docker-registry-cache.nix
      ../../modules/router.nix
      ../../modules/ssh.nix
      ../../modules/sudo.nix
      ../../modules/unfree.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Mierin";
  networking.useDHCP = false;

  # Define HAOS VM in libvirt after boot (persists across tmpfs /etc/libvirt/qemu)
  systemd.services.define-haos-vm = {
    description = "Define HAOS VM in libvirt";
    after = [ "libvirtd.service" ];
    wants = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      if [ ! -f /opt/local/vms/haos_VARS.fd ]; then
        cp /run/libvirt/nix-ovmf/edk2-i386-vars.fd /opt/local/vms/haos_VARS.fd
      fi
      ${pkgs.libvirt}/bin/virsh define ${./haos-domain.xml}
    '';
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
