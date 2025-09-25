{
  inputs = {
    xnode-manager.url = "github:Openmesh-Network/xnode-manager";
    xnode-nextjs-template.url = "github:Openmesh-Network/xnode-nextjs-template"; # "path:..";
    nixpkgs.follows = "xnode-nextjs-template/nixpkgs";
  };

  outputs = inputs: {
    nixosConfigurations.container = inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
      };
      modules = [
        inputs.xnode-manager.nixosModules.container
        {
          services.xnode-container.xnode-config = {
            host-platform = ./xnode-config/host-platform;
            state-version = ./xnode-config/state-version;
            hostname = ./xnode-config/hostname;
          };
        }
        inputs.xnode-nextjs-template.nixosModules.default
        {
          services.xnode-nextjs-template.enable = true;
        }
      ];
    };
  };
}
