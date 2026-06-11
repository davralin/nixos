{ config, pkgs, ... }:

{
  # Enable node-exporter
  services.prometheus.exporters.node.enable = true;
}
