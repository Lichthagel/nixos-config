{ self, pkgs, ... }:
{
  imports = [ self.homeModules.full ];

  home.packages = with pkgs; [
    calibre
    anki
    qbittorrent
    libreoffice-qt
  ];
}
