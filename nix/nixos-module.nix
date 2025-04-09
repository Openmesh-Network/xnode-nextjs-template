{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.xnode-nextjs-template;
  xnode-nextjs-template = pkgs.callPackage ./package.nix { };
in
{
  options = {
    services.xnode-nextjs-template = {
      enable = lib.mkEnableOption "Enable the nextjs app";

      hostname = lib.mkOption {
        type = lib.types.str;
        default = "0.0.0.0";
        example = "127.0.0.1";
        description = ''
          The hostname under which the app should be accessible.
        '';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        example = 3000;
        description = ''
          The port under which the app should be accessible.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to open ports in the firewall for this application.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.xnode-nextjs-template = { };
    users.users.xnode-nextjs-template = {
      isSystemUser = true;
      group = "xnode-nextjs-template";
    };

    systemd.services.xnode-nextjs-template = {
      wantedBy = [ "multi-user.target" ];
      description = "Nextjs App.";
      after = [ "network.target" ];
      environment = {
        HOSTNAME = cfg.hostname;
        PORT = toString cfg.port;
      };
      serviceConfig = {
        ExecStart = "${lib.getExe xnode-nextjs-template}";
        User = "xnode-nextjs-template";
        Group = "xnode-nextjs-template";
        CacheDirectory = "nextjs-app";
      };
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };
}
