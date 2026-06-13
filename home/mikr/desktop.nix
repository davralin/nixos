{ config, pkgs, lib, ... }:

{
  home.username = "mikr";
  home.homeDirectory = "/home/mikr";
  home.stateVersion = "26.05";

  # User packages
  home.packages = with pkgs; [
    discord
    signal-desktop
    speedcrunch
    nextcloud-client
    variety
    # System tray / X utilities (user-facing)
    xclip
    xsel
    pavucontrol
  ];

  # --- Alacritty ---
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary = { background = "#020221"; foreground = "#b4b4b9"; };
        cursor  = { text = "#020221"; cursor = "#ffe8c0"; };
        normal = {
          black   = "#000004"; red     = "#ff3600"; green   = "#718e3f";
          yellow  = "#ffc552"; blue    = "#635196"; magenta = "#ff761a";
          cyan    = "#34bfa4"; white   = "#b4b4b9";
        };
        bright = {
          black   = "#020221"; red     = "#ff8e78"; green   = "#b1bf75";
          yellow  = "#ffd392"; blue    = "#99a4bc"; magenta = "#ffb07b";
          cyan    = "#8bccbf"; white   = "#f8f8ff";
        };
      };
      window = {
        decorations = "Full";
        dynamic_title = true;
        opacity = 0.99;
      };
      scrolling.history = 100000;
      font = {
        normal = { family = "Hack"; style = "Bold"; };
        size = 8;
        builtin_box_drawing = true;
      };
    };
  };

  # --- Rofi ---
  programs.rofi = {
    enable = true;
    font = "hack 12";
    theme = "Arc-Dark";
    extraConfig = {
      modi = "combi";
      show-icons = true;
      combi-modi = "window,run,ssh";
    };
  };

  # --- Firefox ---
  programs.firefox.enable = true;

  # --- Picom ---
  services.picom = {
    enable = true;
    backend = "glx";
    shadow = true;
    shadowOffsets = [ (-5) (-5) ];
    shadowOpacity = 0.5;
    shadowExclude = [
      "! name~=''"
      "name = 'Notification'"
      "name *= 'Firefox'"
      "class_g ?= 'Notify-osd'"
    ];
    fade = true;
    fadeDelta = 10;
    fadeSteps = [ 0.1 0.1 ];
    inactiveOpacity = 0.9;
    activeOpacity = 1.0;
    settings = {
      mark-wmwin-focused = true;
      use-ewmh-active-win = true;
      detect-rounded-corners = true;
      vsync = true;
      detect-transient = true;
      detect-client-leader = true;
      wintypes = {
        tooltip = { shadow = false; opacity = 0.85; focus = true; };
      };
    };
  };

  # --- Dunst ---
  services.dunst = {
    enable = true;
    settings = {
      global = {
        follow = "mouse";
        geometry = "300x5-30+20";
        indicate_hidden = true;
        transparency = 30;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        frame_width = 3;
        frame_color = "#aaaaaa";
        separator_color = "frame";
        sort = true;
        idle_threshold = 120;
        font = "Hack 8";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        word_wrap = true;
        show_indicators = true;
        icon_position = "off";
        sticky_history = true;
        history_length = 20;
        browser = "firefox -new-tab";
      };
      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+grave";
        context = "ctrl+shift+period";
      };
      urgency_low = {
        frame_color = "#ffffff";
        background = "#222222";
        foreground = "#888888";
        timeout = 5;
      };
      urgency_normal = {
        frame_color = "#112299";
        background = "#285577";
        foreground = "#ffffff";
        timeout = 10;
      };
      urgency_critical = {
        background = "#900000";
        foreground = "#ffffff";
        frame_color = "#ff0000";
        timeout = 15;
      };
    };
  };

  # --- Gammastep ---
  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 59.9;
    longitude = 10.7;
  };

  # --- i3 scripts ---
  home.file.".config/i3/scripts/i3lockblur.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      rm -f /tmp/screenshot.png
      scrot -z /tmp/screenshot.png
      notify-send -u low -t 2000 -- 'Now locking...'
      convert /tmp/screenshot.png -blur 0x5 /tmp/screenshotblur.png
      convert /tmp/screenshotblur.png -fill red -gravity South -pointsize 25 -annotate +0+300 'enter password' /tmp/screenshot.png
      rm -f /tmp/screenshotblur.png
      i3lock -i /tmp/screenshot.png
    '';
  };

  home.file.".config/i3/scripts/shutdown_menu.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      entries="Lock\nLogout\nSuspend\nHibernate\nReboot\nShutdown"
      selected=$(echo -e "$entries" | rofi -dmenu -i -p "Power:")
      case "$selected" in
        Lock)      ~/.config/i3/scripts/i3lockblur.sh ;;
        Logout)    i3-msg exit ;;
        Suspend)   systemctl suspend ;;
        Hibernate) systemctl hibernate ;;
        Reboot)    systemctl reboot ;;
        Shutdown)  systemctl poweroff ;;
      esac
    '';
  };

  # --- i3 ---
  xsession.windowManager.i3 = {
    enable = true;
    config = let
      bg-color            = "#2f343f";
      inactive-bg-color   = "#2f343f";
      text-color          = "#f3f4f5";
      inactive-text-color = "#676E7D";
      urgent-bg-color     = "#E53935";
      modifier            = "Mod4";
      terminal            = "alacritty";
    in {
      modifier = modifier;
      terminal = terminal;
      fonts = { names = [ "hack" ]; size = 10.0; };

      colors = {
        focused         = { border = bg-color; background = bg-color; text = text-color;          indicator = "#00ff00"; childBorder = bg-color; };
        unfocused       = { border = inactive-bg-color; background = inactive-bg-color; text = inactive-text-color; indicator = "#00ff00"; childBorder = inactive-bg-color; };
        focusedInactive = { border = inactive-bg-color; background = inactive-bg-color; text = inactive-text-color; indicator = "#00ff00"; childBorder = inactive-bg-color; };
        urgent          = { border = urgent-bg-color;   background = urgent-bg-color;   text = text-color;          indicator = "#00ff00"; childBorder = urgent-bg-color; };
      };

      bars = [
        {
          statusCommand = "i3blocks -c ~/.config/i3blocks/up.conf";
          position = "top";
          workspaceButtons = false;
          trayOutput = "none";
          extraConfig = ''
            binding_mode_indicator no
            output primary
          '';
          colors = {
            background = bg-color;
            separator  = "#757575";
            focusedWorkspace  = { border = bg-color;          background = bg-color;          text = text-color; };
            inactiveWorkspace = { border = inactive-bg-color; background = inactive-bg-color; text = inactive-text-color; };
            urgentWorkspace   = { border = urgent-bg-color;   background = urgent-bg-color;   text = text-color; };
          };
        }
        {
          statusCommand = "i3blocks -c ~/.config/i3blocks/down.conf";
          position = "bottom";
          trayOutput = "primary";
          colors = {
            background = bg-color;
            separator  = "#757575";
            focusedWorkspace  = { border = bg-color;          background = bg-color;          text = text-color; };
            inactiveWorkspace = { border = inactive-bg-color; background = inactive-bg-color; text = inactive-text-color; };
            urgentWorkspace   = { border = urgent-bg-color;   background = urgent-bg-color;   text = text-color; };
          };
        }
      ];

      keybindings = lib.mkOptionDefault {
        # Terminal & launcher
        "${modifier}+Return"      = "exec ${terminal}";
        "${modifier}+d"           = "exec rofi -show drun -modi drun";
        "${modifier}+Shift+d"     = "exec rofi -show run -modi run";
        "${modifier}+Tab"         = "exec rofi -show window -modi window";
        "Mod1+Tab"                = "workspace back_and_forth";

        # Layout
        "${modifier}+h"           = "split h";
        "${modifier}+v"           = "split v";
        "${modifier}+s"           = "layout stacking";
        "${modifier}+w"           = "layout tabbed";
        "${modifier}+e"           = "layout toggle split";
        "${modifier}+f"           = "fullscreen toggle";
        "${modifier}+Shift+space" = "floating toggle";
        "${modifier}+space"       = "focus mode_toggle";

        # Multi-monitor
        "${modifier}+m"           = "move workspace to output left";
        "${modifier}+n"           = "move workspace to output right";

        # Paste
        "--release Control+Shift+v" = "exec --no-startup-id xdotool key --clearmodifiers Shift+Insert";

        # Screenshots
        "Print"                   = "exec --no-startup-id flameshot full -c";
        "Shift+Print"             = "exec --no-startup-id flameshot screen -c";
        "Control+Print"           = "exec --no-startup-id flameshot gui";

        # Brightness
        "XF86MonBrightnessUp"     = "exec brightnessctl set +5%";
        "XF86MonBrightnessDown"   = "exec brightnessctl set 5%-";

        # Volume
        "XF86AudioRaiseVolume"    = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +5%";
        "XF86AudioLowerVolume"    = "exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -5%";
        "XF86AudioMute"           = "exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle";

        # Lock / power
        "${modifier}+Shift+x"     = "exec ~/.config/i3/scripts/i3lockblur.sh";
        "${modifier}+Shift+s"     = "exec ~/.config/i3/scripts/i3lockblur.sh && systemctl suspend-then-hibernate";
        "${modifier}+Shift+e"     = "exec ~/.config/i3/scripts/shutdown_menu.sh";

        # Apps
        "${modifier}+Shift+f"     = "exec thunar";
        "${modifier}+Shift+w"     = "exec firefox";
        "${modifier}+p"           = "exec autorandr --change";
        "${modifier}+Shift+p"     = "exec autorandr --load laptop";

        # Scratchpad
        "${modifier}+i"           = "move scratchpad";
        "${modifier}+Shift+i"     = "sticky toggle";

        # Dropdown terminal
        "F12" = "[class=\"Alacritty\" instance=\"dropdown\"] scratchpad show; resize set 80 ppt 80 ppt; move position center";

        # Calculator scratchpad
        "${modifier}+c" = "[class=\"SpeedCrunch\"] scratchpad show; move position mouse";
      };

      assigns = {
        "8" = [{ class = "Steam"; }];
        "9" = [{ class = "discord"; } { class = "Signal"; }];
        "10" = [{ class = "buffer"; }];
      };

      floating.criteria = [
        { class = "Yad"; }
        { class = "pavucontrol"; }
        { class = "SpeedCrunch"; }
        { class = "discord"; }
        { class = "Signal"; }
      ];

      window.hideEdgeBorders = "both";

      startup = [
        { command = "nm-applet"; notification = false; }
        { command = "lxpolkit"; notification = false; }
        { command = "gammastep"; notification = false; }
        { command = "unclutter-xfixes -idle 2"; notification = false; }
        { command = "thunar --daemon"; notification = false; }
        { command = "udiskie --smart-tray --file-manager thunar"; notification = false; }
        { command = "xautolock -detectsleep -time 120 -locker '~/.config/i3/scripts/i3lockblur.sh' -notify 30 -notifier \"notify-send -u critical -t 5000 -- 'LOCKING screen in 30 seconds'\""; notification = false; }
        { command = "autorandr --change"; notification = false; }
        { command = "variety"; notification = false; }
        { command = "nextcloud --background"; notification = false; }
        { command = "flatpak run org.gnome.gitlab.cheywood.Buffer"; notification = false; }
        { command = "speedcrunch"; notification = false; }
        { command = "alacritty --class Alacritty,dropdown"; notification = false; }
        { command = "gnome-keyring-daemon --start --components=secrets,pkcs11"; notification = false; }
        { command = "i3-msg workspace 1"; notification = false; }
      ];
    };

    extraConfig = ''
      # Dropdown terminal scratchpad rules
      for_window [class="Alacritty" instance="dropdown"] floating enable
      for_window [class="Alacritty" instance="dropdown"] move scratchpad
      for_window [class="Alacritty" instance="dropdown"] border pixel 0

      # SpeedCrunch scratchpad rules
      for_window [class="SpeedCrunch"] move scratchpad
      for_window [class="SpeedCrunch"] resize set 400 200

      # Discord / Signal tabbed layout
      for_window [class="discord"] layout tabbed
      for_window [class="Signal"] layout tabbed

      # Workspace output preferences
      workspace 7 output eDP-1 left primary
      workspace 9 output eDP-1 left primary
      workspace 10 output DP-1-1 right primary
    '';
  };
}
