{ pkgs, ... }:

{
  services.garage = {
    enable = true;
    package = pkgs.garage_2;
    settings = {
      rpc_secret_file = "/var/lib/garage/rpc-secret";
      replication_factor = 1;
      rpc_bind_addr = "127.0.0.1:3901";
      rpc_public_addr = "127.0.0.1:3901";
      s3_api = {
        api_bind_addr = "127.0.0.1:3900";
        s3_region = "garage";
        advertise_endpoint = "http://127.0.0.1:3900";
        advertise_path_style = true;
      };
    };
  };
}
