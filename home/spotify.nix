{
  ctp,
  pkgs,
  spicetify-nix,
  ...
}: let
  spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
in {
  home.packages = with pkgs; [
    # spotify
    spotifyd
    spotify-tui
    # spicetify-cli
  ];

  imports = [
    spicetify-nix.homeManagerModule
  ];

  programs.spicetify = {
    enable = true;

    theme =
      spicePkgs.themes.catppuccin
      // {
        src = pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "spicetify";
          rev = "d3c4b697f1739149684e36977a1502f88c344b3a";
          sha256 = "sha256-VxkgW9qF1pmKnP7Ei7gobF0jVB1+qncfFeykWoXMRCo=";
        };
      };
    colorScheme = ctp.flavor;
  };
}
