{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    xnode-nextjs-template.url = "github:Openmesh-Network/xnode-nextjs-template";
  };

  outputs =
    {
      self,
      nixpkgs,
      xnode-nextjs-template,
      ...
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.container = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit xnode-nextjs-template;
        };
        modules = [
          (
            { xnode-nextjs-template, ... }:
            {
              imports = [
                xnode-nextjs-template.nixosModules.default
              ];

              boot.isContainer = true;

              services.xnode-nextjs-template = {
                enable = true;
              };

              networking = {
                firewall.allowedTCPPorts = [
                  3000
                ];

                useHostResolvConf = nixpkgs.lib.mkForce false;
              };

              services.resolved.enable = true;

              system.stateVersion = "25.05";
            }
          )
        ];
      };
    };
}
