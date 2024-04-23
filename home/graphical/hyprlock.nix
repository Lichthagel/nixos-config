{
  config,
  osConfig,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.licht.graphical.hyprlock;
in
{
  imports = [ inputs.hyprlock.homeManagerModules.default ];

  options.licht.graphical.hyprlock = {
    enable = lib.mkEnableOption "hyprlock" // {
      default = config.licht.graphical.hyprland.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.licht.graphical.hyprland.enable;
        message = "hyprland is required";
      }
      {
        assertion = osConfig.security.pam.services ? hyprlock;
        message = "hyprlock pam service is required";
      }
    ];

    programs.hyprlock = {
      enable = true;

      package = pkgs.hyprlock;

      general = {
        grace = 5;
      };

      backgrounds = [
        {
          path = "${pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/rose-pine/wallpapers/main/rose_pine_contourline.png";
            sha256 = "sha256-8OQCXMy27IImp1Oc/X4i14/8k9XjuuU+6clh0rRcAQY=";
          }}";
        }
      ];
    };
  };
}
