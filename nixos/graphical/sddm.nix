{
  config,
  lib,
  pkgs,
  selfPkgs,
  ...
}:
let
  cfg = config.licht.graphical.sddm;
in
{
  options.licht.graphical.sddm = {
    enable = lib.mkEnableOption "sddm" // {
      default = config.licht.graphical.plasma5.enable || config.licht.graphical.plasma6.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    services.displayManager.sddm = {
      package = pkgs.kdePackages.sddm;
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-mocha";
      settings = {
        Theme = {
          CursorTheme = "Vimix-white-cursors";
        };
      };
    };

    environment.systemPackages = [
      (pkgs.catppuccin-sddm.override {
        flavor = config.catppuccin.flavor;
        font = "Noto Sans";
        fontSize = "9";
        background = "${selfPkgs.topographical-catppuccin}";
        loginBackground = true;
      })
      pkgs.noto-fonts
      pkgs.vimix-cursors
    ];
  };
}
