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

  # --- i3blocks ---
  home.file.".config/i3blocks/up.conf".text = ''
    separator_block_width=10
    align=center

    # Quotes from Wheel of Time
    [wot]
    command=~/.config/i3blocks/scripts/wot.sh
    interval=300

    # Show date and calendar
    [cal]
    command=~/.config/i3blocks/scripts/cal.sh
    interval=1
  '';

  home.file.".config/i3blocks/down.conf".text = ''
    separator_block_width=10
    align=center
    separator=true

    # Screen brightness
    [brightness]
    command=~/.config/i3blocks/scripts/brightness.sh
    label=
    interval=5
    min_width=100%

    # Volume indicator
    [volume]
    command=~/.config/i3blocks/scripts/volume.sh
    instance=Master
    interval=once
    signal=10

    # Wireguard interface monitoring
    [wireguard]
    command=~/.config/i3blocks/scripts/wireguard.sh
    interval=30
    separator=true

    # Network interface monitoring
    [iface]
    command=~/.config/i3blocks/scripts/iface.sh
    interval=5
    separator=true

    # Disk usage
    [disk]
    command=~/.config/i3blocks/scripts/disk.sh
    label=/
    instance=/
    interval=30
    separator=false
    [disk]
    command=~/.config/i3blocks/scripts/disk.sh
    label=~
    instance=/home
    interval=30

    # MEM usage bar
    [membar]
    command=~/.config/i3blocks/scripts/mem.sh
    label=mem:
    align=left
    interval=10
    markup=pango
    min_width=mem: ■■■■■

    # CPU usage bar
    [cpubar]
    command=~/.config/i3blocks/scripts/cpu.sh
    label=
    align=left
    interval=5
    markup=pango
    min_width= ■■■■■

    # Battery indicator
    [batterybar]
    command=~/.config/i3blocks/scripts/batterybar.sh
    label=⚡
    align=left
    interval=30
    markup=pango
    min_width=⚡ ■■■■■

    # Key indicators
    [keyindicator]
    command=~/.config/i3blocks/scripts/keyindicator.sh
    instance=CAPS
    interval=once
    signal=11
  '';

  # i3blocks scripts
  home.file.".config/i3blocks/scripts/wot.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      curl -s https://wotquotes.com/ \
        | grep quotescollection-2 \
        | cut -d'>' -f4 \
        | cut -d'<' -f1 \
        | sed -r -e 's/&#8230;/.../g' -e "s/&#8217;/'/g" \
               -e 's/,\.\.\./\.\.\./g' -e 's/\. \. \. \./\.\.\.\./g' \
               -e 's:<br />: :g'
    '';
  };

  home.file.".config/i3blocks/scripts/cal.sh" = {
    executable = true;
    text = ''
      #!/bin/sh
      WIDTH=''${WIDTH:-200}
      HEIGHT=''${HEIGHT:-200}
      DATEFMT=''${DATEFMT:-"+  W:%V %Y-%m-%d  %H:%M:%S"}
      SHORTFMT=''${SHORTFMT:-"+%H:%M:%S"}

      case "$BLOCK_BUTTON" in
        1|2|3)
          posX=$(($BLOCK_X - $WIDTH / 2))
          i3-msg -q "exec LANG=nb_NO.utf8 yad --calendar \
            --width=$WIDTH --height=$HEIGHT \
            --undecorated --fixed \
            --close-on-unfocus --no-buttons \
            --show-weeks \
            --posx=$posX --posy=24 \
            > /dev/null"
      esac
      echo "$LABEL$(date "$DATEFMT")"
      echo "$LABEL$(date "$SHORTFMT")"
    '';
  };

  home.file.".config/i3blocks/scripts/brightness.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      if [[ "$BLOCK_BUTTON" -eq 1 ]]; then
        brightnessctl set 1% > /dev/null
      elif [[ "$BLOCK_BUTTON" -eq 2 ]]; then
        brightnessctl set 20% > /dev/null
      elif [[ "$BLOCK_BUTTON" -eq 3 ]]; then
        brightnessctl set 70% > /dev/null
      fi
      BRIGHTNESS=$(brightnessctl | grep Current | cut -d'(' -f2 | cut -d')' -f1)
      if [ "$(brightnessctl --list | grep backlight)" ]; then
        echo $BRIGHTNESS
        echo $BRIGHTNESS
      fi
    '';
  };

  home.file.".config/i3blocks/scripts/volume.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1)
      MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -oP '(yes|no)')
      if [[ "$MUTE" == "yes" ]]; then
        echo " $VOL"
      else
        echo " $VOL"
      fi
    '';
  };

  home.file.".config/i3blocks/scripts/wireguard.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      for i in $(sudo find /etc/wireguard/ -iname '*.conf' \
                   | sed 's:/etc/wireguard/::g' | sed 's/.conf//g')
      do
        sudo wg show $i >/dev/null 2>&1
        if [ $? -eq 0 ]; then
          echo ""
          echo ""
        else
          echo "$i"
          echo "$i"
          echo \#FF0000
        fi
      done
    '';
  };

  home.file.".config/i3blocks/scripts/iface.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      if [[ -n $BLOCK_INSTANCE ]]; then
        IF=$BLOCK_INSTANCE
      else
        IF=$(ip route | awk '/^default/ { print $5 ; exit }')
      fi

      if [[ "$BLOCK_BUTTON" -eq 1 ]]; then
        PUBLICIP=$(curl -s https://icanhazip.com)
        notify-send -u low "Public IP is: $PUBLICIP"
        echo $PUBLICIP | xclip -selection clipboard
        PRIVATEIP=$(ip a | grep $(ip route | awk '/^default/ { print $5 }') \
          | grep inet | awk '{ print $2 }' | awk -F '/' '{ print $1 }')
        notify-send -u low "Private IP is: $PRIVATEIP"
      fi

      if [[ "$(cat /sys/class/net/$IF/operstate)" = 'up' ]]; then
        echo ""
        echo ""
      elif [[ "$(cat /sys/class/net/$IF/operstate)" = 'unknown' ]]; then
        echo ""
        echo ""
        echo \#00FF00
      else
        echo ""
        echo ""
        echo \#FF0000
      fi
    '';
  };

  home.file.".config/i3blocks/scripts/disk.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      INSTANCE=''${BLOCK_INSTANCE:-/}
      df -h "$INSTANCE" | awk 'NR==2 { print $4 " / " $2 }'
    '';
  };

  home.file.".config/i3blocks/scripts/mem.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      if [[ "$BLOCK_BUTTON" -eq 1 ]]; then
        topproc=$(ps ax --sort=-pmem --format 'command=' \
          | head -n 1 | cut -f1 -d' ' | awk -F" +|/" '{print $NF}')
        echo "<span foreground=\"#FFD000\">$topproc</span>"
      else
        memavailable=$(awk '/MemAvailable/ { printf "%.3f \n", $2/1024/1024 }' /proc/meminfo)
        memtotal=$(awk '/MemTotal/ { printf "%.3f \n", $2/1024/1024 }' /proc/meminfo)
        output=$(echo "scale=5; 100 - (($memavailable / $memtotal) * 100)" | bc | cut -f1 -d'.')
        if   [[ "$output" -lt 20 ]]; then color="#ADFF00"; squares="■"
        elif [[ "$output" -lt 40 ]]; then color="#E4FF00"; squares="■■"
        elif [[ "$output" -lt 60 ]]; then color="#FFD000"; squares="■■■"
        elif [[ "$output" -lt 80 ]]; then color="#FFB923"; squares="■■■■"
        else                              color="#FF0027"; squares="■■■■■"
        fi
        echo "<span foreground=\"$color\">$squares</span>"
      fi
    '';
  };

  home.file.".config/i3blocks/scripts/cpu_usage" = {
    executable = true;
    text = ''
      #!/usr/bin/perl
      use strict;
      use warnings;
      use utf8;
      use Getopt::Long;

      my $t_warn = 50;
      my $t_crit = 80;
      my $cpu_usage = -1;

      GetOptions("w=i" => \$t_warn, "c=i" => \$t_crit);

      $ENV{LC_ALL} = "en_US";
      open(MPSTAT, 'mpstat 1 1 |') or die;
      while (<MPSTAT>) {
        if (/^Average.*\s+(\d+\.\d+)/) {
          $cpu_usage = 100 - $1;
          last;
        }
      }
      close(MPSTAT);

      $cpu_usage eq -1 and die "Can't find CPU information";

      printf "%.2f%%\n", $cpu_usage;
      printf "%.2f%%\n", $cpu_usage;

      if ($cpu_usage >= $t_crit) {
        print "#FF0000\n"; exit 33;
      } elsif ($cpu_usage >= $t_warn) {
        print "#FFFC00\n";
      }
      exit 0;
    '';
  };

  home.file.".config/i3blocks/scripts/cpu.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      if [[ "$BLOCK_BUTTON" -eq 1 ]]; then
        topproc=$(ps ax --sort=-pcpu --format 'command=' \
          | head -n 1 | cut -f1 -d' ' | awk -F" +|/" '{print $NF}')
        echo "<span foreground=\"#FFD000\">$topproc</span>"
      else
        output=$(~/.config/i3blocks/scripts/cpu_usage | head -n 1 | cut -f1 -d'.')
        if   [[ "$output" -lt 20 ]]; then color="#ADFF00"; squares="■"
        elif [[ "$output" -lt 40 ]]; then color="#E4FF00"; squares="■■"
        elif [[ "$output" -lt 60 ]]; then color="#FFD000"; squares="■■■"
        elif [[ "$output" -lt 80 ]]; then color="#FFB923"; squares="■■■■"
        else                              color="#FF0027"; squares="■■■■■"
        fi
        echo "<span foreground=\"$color\">$squares</span>"
      fi
    '';
  };

  home.file.".config/i3blocks/scripts/batterybar.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      readarray -t output <<< $(acpi battery)
      battery_count=''${#output[@]}

      for line in "''${output[@]}"; do
        percentages+=($(echo "$line" | grep -o -m1 '[0-9]\{1,3\}%' | tr -d '%'))
        statuses+=($(echo "$line" | grep -E -o -m1 'Discharging|Charging|AC|Full|Unknown'))
        remaining=$(echo "$line" | grep -E -o -m1 '[0-9][0-9]:[0-9][0-9]')
        remainings+=("''${remaining:+ ($remaining)}")
      done

      dis_colors=("#FF0027" "#FF3B05" "#FFB923" "#FFD000" "#E4FF00" "#ADFF00" "#6DFF00" "#10BA00")
      charging_color="#00AFE3"
      full_color="#FFFFFF"
      ac_color="#535353"

      end=$((battery_count - 1))
      for i in $(seq 0 $end); do
        pct=''${percentages[$i]}
        if   (( pct <  20 )); then squares="■"
        elif (( pct <  40 )); then squares="■■"
        elif (( pct <  60 )); then squares="■■■"
        elif (( pct <  80 )); then squares="■■■■"
        else                       squares="■■■■■"
        fi
        (( pct < 10 )) && notify-send -u critical "Low battery!"

        case "''${statuses[$i]}" in
          Charging)  color="$charging_color" ;;
          Full)      color="$full_color" ;;
          AC)        color="$ac_color" ;;
          *)
            idx=$(( pct / 10 < 7 ? pct / 10 : 7 ))
            color="''${dis_colors[$idx]}"
            ;;
        esac

        (( end > 0 )) && message="$message $(($i + 1)):"
        message="$message ''${statuses[$i]} <span foreground=\"$color\">''${pct}%''${remainings[$i]}</span>"
      done
      echo $message
    '';
  };

  home.file.".config/i3blocks/scripts/keyindicator.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      KEY=''${BLOCK_INSTANCE:-CAPS}
      STATE=$(xset q | grep -i "''${KEY}" | grep -oP '(on|off)' | tail -1)
      if [[ "$STATE" == "on" ]]; then
        echo "$KEY"
        echo "$KEY"
        echo \#FFD000
      fi
    '';
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

        # CapsLock indicator — signal i3blocks to refresh keyindicator block
        "--release Caps_Lock" = "exec pkill -SIGRTMIN+11 i3blocks";
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
        { command = "unclutter -idle 2"; notification = false; }
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
