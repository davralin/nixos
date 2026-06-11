{ config, pkgs, ... }:

{
  # Inspiration:
  #  - https://francis.begyn.be/blog/nixos-home-router
  #  - https://github.com/ghostbuster91/blogposts/blob/a2374f0039f8cdf4faddeaaa0347661ffc2ec7cf/router2023-part2/main.md
  #  - https://nixos.wiki/wiki/Systemd-networkd
  #  - https://wiki.nixos.org/wiki/Networking
  #  - https://dataswamp.org/~solene/2022-08-03-nixos-with-live-usb-router.html

  #powerManagement.cpuFreqGovernor = "ondemand";
  #boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  boot.kernel = {
    sysctl = {
      "net.ipv4.conf.all.forwarding" = true;
      "net.ipv6.conf.all.forwarding" = false;
    };
  };
  systemd.network = {
    enable = true;
    wait-online.anyInterface = true;
    networks = {
      "20-enp2s0" = {
        matchConfig.Name = "enp2s0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = false;
        };
      };
    };
  };

  networking = {
    firewall.interfaces = {
      enp2s0 = {
        allowedTCPPorts = [ ];
        allowedUDPPorts = [
          443 # WireGuard
        ];
      };
      lan = {
        allowedTCPPorts = [
          22 # SSH
          53 # DNSmasq
          5001 # Docker Registry pull-through cache
          9100 # node-exporter
          9153 # node-exporter for DNSmasq
          9586 # node-exporter for WireGuard
        ];
        allowedUDPPorts = [
          53 # DNSmasq
          67 # DNSmasq-dhcp
          69 # DNSmasq-tftp
        ];
      };
      wg0 = {
        allowedTCPPorts = [
          22 # SSH
          53 # DNSmasq
        ];
        allowedUDPPorts = [
          53 # DNSmasq
        ];
      };
    };

    firewall.extraCommands = ''
      # ---- Force DNS through router ----
      iptables -t nat -A PREROUTING -i lan -m iprange --src-range 10.0.1.2-10.0.1.7 -p udp --dport 53 -j REDIRECT --to-ports 53
      iptables -t nat -A PREROUTING -i lan -m iprange --src-range 10.0.1.2-10.0.1.7 -p tcp --dport 53 -j REDIRECT --to-ports 53
      iptables -t nat -A PREROUTING -i lan -m iprange --src-range 10.0.1.150-10.0.1.254 -p udp --dport 53 -j REDIRECT --to-ports 53
      iptables -t nat -A PREROUTING -i lan -m iprange --src-range 10.0.1.150-10.0.1.254 -p tcp --dport 53 -j REDIRECT --to-ports 53

      # ---- Block DNS-over-TLS ----
      iptables -A FORWARD -i lan -o enp2s0 -m iprange --src-range 10.0.1.2-10.0.1.7 -p tcp --dport 853 -j REJECT
      iptables -A FORWARD -i lan -o enp2s0 -m iprange --src-range 10.0.1.150-10.0.1.254 -p tcp --dport 853 -j REJECT

      # ---- Block DNS-over-HTTPS ----
      iptables -A FORWARD -i lan -o enp2s0 -m iprange --src-range 10.0.1.2-10.0.1.7 -d 8.8.4.4 -j REJECT
      iptables -A FORWARD -i lan -o enp2s0 -m iprange --src-range 10.0.1.2-10.0.1.7 -d 8.8.8.8 -j REJECT
      iptables -A FORWARD -i lan -o enp2s0 -m iprange --src-range 10.0.1.2-10.0.1.7 -d 1.1.1.1 -j REJECT
      iptables -A FORWARD -i lan -o enp2s0 -m iprange --src-range 10.0.1.2-10.0.1.7 -d 9.9.9.9 -j REJECT
      iptables -A FORWARD -i lan -o enp2s0 -m iprange --src-range 10.0.1.150-10.0.1.254 -d 8.8.4.4 -j REJECT
      iptables -A FORWARD -i lan -o enp2s0 -m iprange --src-range 10.0.1.150-10.0.1.254 -d 8.8.8.8 -j REJECT
      iptables -A FORWARD -i lan -o enp2s0 -m iprange --src-range 10.0.1.150-10.0.1.254 -d 1.1.1.1 -j REJECT
      iptables -A FORWARD -i lan -o enp2s0 -m iprange --src-range 10.0.1.150-10.0.1.254 -d 9.9.9.9 -j REJECT
    '';
    bridges.lan = {
        interfaces = [ "enp1s0" ];
    };
    interfaces.lan = {
        ipv4.addresses = [
            { address = "10.0.1.1"; prefixLength = 24; }
        ];
    };
    nat = {
      enable = true;
      internalInterfaces = [
        "lan"
        "wg0"
      ];
      externalInterface = "enp2s0";
      forwardPorts = [
        {
          # minecraft
          sourcePort = 25565;
          proto = "tcp";
          destination = "10.0.1.31:25565";
        }
        #{
        #  # HOMM3
        #  sourcePort = 8766;
        #  proto = "tcp";
        #  destination = "10.0.1.61:8766";
        #}
        #{
        #  # HOMM3
        #  sourcePort = 8766;
        #  proto = "udp";
        #  destination = "10.0.1.61:8766";
        #}
        #{
        #  # HOMM3
        #  sourcePort = 27015;
        #  proto = "tcp";
        #  destination = "10.0.1.61:27015";
        #}
        #{
        #  # HOMM3
        #  sourcePort = 27015;
        #  proto = "udp";
        #  destination = "10.0.1.61:27015";
        #}
        #{
        #  # HOMM3
        #  sourcePort = 27016;
        #  proto = "tcp";
        #  destination = "10.0.1.61:27016";
        #}
        #{
        #  # HOMM3
        #  sourcePort = 27016;
        #  proto = "udp";
        #  destination = "10.0.1.61:27016";
        #}
        {
          # plex
          sourcePort = 32400;
          proto = "tcp";
          destination = "10.0.1.30:32400";
        }
        {
          # qbit
          sourcePort = 9500;
          proto = "tcp";
          destination = "10.0.1.38:9500";
        }
        {
          # syncthing
          sourcePort = 22000;
          proto = "tcp";
          destination = "10.0.1.33:22000";
        }
        {
          # syncthing
          sourcePort = 22000;
          proto = "udp";
          destination = "10.0.1.33:22000";
        }
      ];
    };
    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.0.2.1/24" ];
        listenPort = 443;
        privateKeyFile = "/opt/wireguard/wg-private.key";
        peers = [
        { # GL-Inet
          publicKey = "h/LU8/EF3f1QcPa+thUUfgcWvMPaPyhdJUxIEb8G1kI=";
          allowedIPs = [ "10.0.2.2/32" ];
          persistentKeepalive = 60;
        }
        { # Laptop
          publicKey = "hW6rycb0yug7eq3NUloXUDE+dYlDcINd2FuBBPCPflc=";
          allowedIPs = [ "10.0.2.3/32" ];
          persistentKeepalive = 60;
        }
        { # Phone
          publicKey = "f5EOS4Imm9H4CJup/SCvQjocPKM7Givd/UOcAbMjg2Q=";
          allowedIPs = [ "10.0.2.4/32" ];
          persistentKeepalive = 60;
        }
        { # Tablet
          publicKey = "tx8eAr/FqoXWFmZfBRwP8hWTjY7js42/85sdrsm293I=";
          allowedIPs = [ "10.0.2.5/32" ];
          persistentKeepalive = 60;
        }
        { # OCI-ARM
          publicKey = "EeS/nzG4GDVeJnKoyKjcj2V9P44EUiu+aGeRcx4x6zc=";
          allowedIPs = [ "10.0.2.6/32" ];
          persistentKeepalive = 60;
        }
        { # ADSB
          publicKey = "fTZHXZL0gc3evEeINw+tBTYweL5hf6AeVI+/4pW7zHA=";
          allowedIPs = [ "10.0.2.7/32" ];
          persistentKeepalive = 60;
        }
        { # RemoteADSB
          publicKey = "K02QD6qlpKWrGVg7/zcfVD0e+/t2ixjdxkJqYNJ7siY=";
          allowedIPs = [ "10.0.2.8/32" ];
          persistentKeepalive = 60;
        }
        { # Tablet#L
          publicKey = "Z+XcV1r15nk6vcrTQgt2ZwBrGM/9k+Y0/QnhgVRpdGk=";
          allowedIPs = [ "10.0.2.9/32" ];
          persistentKeepalive = 60;
        }
        { # Tablet#O
          publicKey = "zXpjKL3eDJSs5P4bLVxl+k4H9uEHCkyGJ3o7cPVrSVI=";
          allowedIPs = [ "10.0.2.10/32" ];
          persistentKeepalive = 60;
        }
        { # Away-NAS
          publicKey = "Vr5FiTWitjqTKcHTmFjcyRd0TYyii2rVZuJCwxiDcWw=";
          allowedIPs = [ "10.0.2.11/32" ];
          persistentKeepalive = 60;
        }
        { # hiddenBox
          publicKey = "Imupq72alW84SfzxytChGYPty64loe3srAb1y+M3jjA=";
          allowedIPs = [ "10.0.2.12/32" "10.10.0.0/24" "10.255.0.0/16" ];
          persistentKeepalive = 60;
        }
        ];
      };
    };
  };
  services = {
    avahi = {
      enable = true;
      reflector = true;
      allowInterfaces = [
        "lan"
        "wg0"
      ];
    };
    dnsmasq = {
      enable = true;
      settings = {
        enable-tftp = true;
        tftp-root = "/opt/netboot";
        dhcp-match = [
          "set:bios,60,PXEClient:Arch:00000"
          "set:efi64,60,PXEClient:Arch:00007"
          "set:efi64-2,60,PXEClient:Arch:00009"
          "set:efi64-3,60,PXEClient:Arch:0000B"
        ];
        dhcp-boot = [
          "tag:bios,netboot.xyz.kpxe"
          "tag:efi64,netboot.xyz.efi"
          "tag:efi64-2,netboot.xyz.efi"
          "tag:efi64-3,netboot.xyz-arm64.efi"
        ];
      };
    };
    prometheus.exporters.dnsmasq = {
      enable = true;
    };
    openssh = {
      openFirewall = false;
    };
    resolved = {
      enable = false;
    };
    prometheus.exporters.wireguard = {
      enable = true;
    };
  };

  systemd.services.netboot-xyz-update = {
    description = "Download/update netboot.xyz boot files";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "netboot-xyz-update" ''
        mkdir -p /opt/netboot
        for f in netboot.xyz.kpxe netboot.xyz-undionly.kpxe netboot.xyz.efi netboot.xyz-snp.efi netboot.xyz-arm64.efi; do
          ${pkgs.curl}/bin/curl -fsSL -o /opt/netboot/$f \
            https://github.com/netbootxyz/netboot.xyz/releases/latest/download/$f
        done
      '';
    };
  };

  systemd.timers.netboot-xyz-update = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      OnBootSec = "5min";
      Persistent = true;
    };
  };
}
