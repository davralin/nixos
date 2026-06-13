{ config, pkgs, inputs, lib, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # X11 + i3 + LightDM
  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    displayManager.lightdm.enable = true;
  };

  # Touchpad support (laptops)
  services.libinput.enable = true;

  # NetworkManager (nm-applet in i3 bar)
  networking.networkmanager.enable = true;

  # Polkit agent — needed for GUI privilege escalation
  security.polkit.enable = true;

  # Gnome keyring — unlocked at login via PAM
  security.pam.services.lightdm.enableGnomeKeyring = true;
  services.gnome.gnome-keyring.enable = true;

  # Flatpak — for Buffer
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  # Steam
  programs.steam.enable = true;

  # Thunar + plugins
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    hack-font
    noto-fonts
    noto-fonts-emoji
  ];

  # System packages — tools needed system-wide or used in i3 scripts/autoruns
  environment.systemPackages = with pkgs; [
    # WM helpers
    i3blocks
    i3lock
    autorandr
    xorg.xrandr
    arandr

    # Screen locker deps
    scrot
    imagemagick

    # Tray / session
    networkmanagerapplet
    lxde.lxsession    # lxpolkit
    udiskie
    unclutter-xfixes
    xautolock

    # Input / X utils
    xdotool
    brightnessctl

    # Audio control (no PipeWire yet, but useful when added)
    pavucontrol
  ];

  # Home-manager — desktop user config for mikr
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.mikr = import ../home/mikr/desktop.nix;
  };
}
