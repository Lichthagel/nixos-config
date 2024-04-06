{
  self,
  inputs,
  lib,
  ...
}:
{
  flake = {
    nixosConfigurations =
      let
        ctpBase = (builtins.fromTOML (builtins.readFile (self + /config.toml))).catppuccin;
        mkArgs = system: {
          inherit self inputs;
          selfPkgs = self.packages.${system};
          unstablePkgs = inputs.nixpkgs-unstable.legacyPackages.${system};
          ctp = rec {
            inherit (ctpBase) accent flavor;

            accentCapitalized = palette.${flavor}.name;
            flavorCapitalized = palette.${flavor}.colors.${accent}.name;

            palette = lib.importJSON (
              builtins.fetchurl {
                url = "https://raw.githubusercontent.com/catppuccin/palette/563cdbccc813ae6716ef8242391e6f9dca8d7596/palette.json";
                sha256 = "sha256:1vzg1x2f1j869ggpsjixi4wdw58zxv8641d04vv33ijmdj1d5p8c";
              }
            );
          };
        };
        mkHost =
          { hostName, system }:
          lib.nixosSystem {
            inherit system;

            specialArgs = mkArgs system;

            modules = [
              inputs.home-manager.nixosModules.home-manager
              inputs.sops-nix.nixosModules.sops
              inputs.catppuccin.nixosModules.catppuccin
              {
                networking.hostName = hostName;
                catppuccin = {
                  # accent = ctpBase.accent;
                  flavour = ctpBase.flavor;
                };
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.licht = {
                  imports = [
                    (self + /home)
                    (self + /hosts/${hostName}/home.nix)
                  ];
                };
                home-manager.extraSpecialArgs = mkArgs system;
              }
              (self + /nixos)
              (self + /hosts/${hostName})
            ];
          };
        mkHosts =
          hosts:
          builtins.listToAttrs (
            map (host: {
              name = host.hostName;
              value = mkHost host;
            }) hosts
          );
      in
      mkHosts [
        {
          hostName = "jdnixos";
          system = "x86_64-linux";
        }
        {
          hostName = "jnbnixos";
          system = "x86_64-linux";
        }
      ];
  };
}
