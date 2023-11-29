{
  description = "My NixOS configuration";

  outputs = {
    self,
    nixpkgs,
    home-manager,
    flake-parts,
    flake-utils,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;}
    {
      flake = {
        nixosConfigurations = {
          jnbnixos = nixpkgs.lib.nixosSystem {
            system = flake-utils.lib.system.x86_64-linux;

            specialArgs = inputs;

            modules = [
              ./hosts/jnbnixos
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.licht = import ./home;
                home-manager.extraSpecialArgs =
                  inputs
                  // {
                    ctp = {
                      flavor = "mocha";
                      accent = "pink";
                    };
                  };
              }
            ];
          };
        };
      };

      systems = flake-utils.lib.defaultSystems;

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            alejandra
            just
            nil
            nix-output-monitor
            nvd
          ];
        };

        formatter = pkgs.alejandra;
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    flake-utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://cache.nixos.org/"
    ];

    extra-substituters = [
      "https://nix-community.cachix.org"
    ];

    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
