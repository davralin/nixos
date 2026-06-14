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

  # Audio — PipeWire with PulseAudio compatibility
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Flatpak — for Buffer
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";

  # Steam
  programs.steam.enable = true;

  # Brightness without sudo
  hardware.brillo.enable = true;

  # Thunar + plugins
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    hack-font
    noto-fonts
    noto-fonts-color-emoji
  ];

  # System packages — tools needed system-wide or used in i3 scripts/autoruns
  environment.systemPackages = with pkgs; [
    # WM helpers
    i3blocks
    i3lock
    autorandr
    xrandr
    arandr

    # Screen locker deps
    scrot
    imagemagick

    # Tray / session
    networkmanagerapplet
    lxsession             # lxpolkit
    udiskie
    unclutter-xfixes      # installs as 'unclutter'
    xautolock

    # Input / X utils
    xdotool
    brightnessctl
    libnotify             # notify-send

    # Audio
    pavucontrol
    pulseaudio            # provides pactl for i3blocks volume script

    # i3blocks script deps
    yad                   # calendar popup (cal.sh)
    sysstat               # mpstat for cpu_usage
    bc                    # math for mem.sh
    acpi                  # battery info for batterybar.sh
  ];

  # Home-manager — desktop user config for mikr
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.mikr = import ../home/mikr/desktop-i3.nix;
  };
}
