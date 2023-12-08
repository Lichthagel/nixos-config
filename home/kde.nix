{
  pkgs,
  ctp,
  ...
}: let
  vimix-cursors = import ../packages/vimix-cursors.nix {inherit pkgs;};
in {
  home.packages = [
    (pkgs.catppuccin-kde.override {
      flavour = [ctp.flavor];
      accents = [ctp.accent];
      winDecStyles = ["classic"];
    })
    (pkgs.catppuccin-papirus-folders.override {
      inherit (ctp) flavor accent;
    })
    pkgs.capitaine-cursors
    vimix-cursors
    (pkgs.catppuccin-gtk.override {
      variant = ctp.flavor;
      accents = [ctp.accent];
    })
  ];

  home.pointerCursor = {
    name = "Vimix Cursors - White";
    # size = 32;
    package = vimix-cursors;
    gtk.enable = true;
    x11.enable = true;
  };
}
